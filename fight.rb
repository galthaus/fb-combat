
require 'yaml'
require 'person'
require 'utils'
require 'global'

class Fight
    attr_accessor :sideA
    attr_accessor :sideB
    attr_accessor :stats

    def initialize(side1, side2, ctx = nil)
        @context = ctx || {}
        @context[:attack_base] = Global::ATTACK_BASE_DEFAULT unless @context[:attack_base]
        @context[:ab_at_mult] = Global::AB_AT_MULT_DEFAULT unless @context[:ab_at_mult]
        @context[:ab_de_mult] = Global::AB_DE_MULT_DEFAULT unless @context[:ab_de_mult]
        @context[:parry_base] = Global::PARRY_BASE_DEFAULT unless @context[:parry_base]
        @context[:pb_at_mult] = Global::PB_AT_MULT_DEFAULT unless @context[:pb_at_mult]
        @context[:pb_de_mult] = Global::PB_DE_MULT_DEFAULT unless @context[:pb_de_mult]
        @context[:evade_base] = Global::EVADE_BASE_DEFAULT unless @context[:evade_base]
        @context[:eb_at_mult] = Global::EB_AT_MULT_DEFAULT unless @context[:eb_at_mult]
        @context[:eb_de_mult] = Global::EB_DE_MULT_DEFAULT unless @context[:eb_de_mult]
        @context[:counter_bonus] = Global::COUNTER_BONUS_DEFAULT unless @context[:counter_bonus]
        @context[:reaction_parry_penalty] = Global::REACTION_PARRY_PENALTY unless @context[:reaction_parry_penalty]
        @context[:scratch] = Global::SCRATCH_DEFAULT unless @context[:scratch]
        @context[:crit_damage] = Global::CRIT_DAMAGE_DEFAULT unless @context[:crit_damage]
        @sideA = side1
        @sideA.each { |x| x.side = "A" }
        @sideB = side2
        @sideB.each { |x| x.side = "B" }
        @stats = {:sideA_hit_count => 0, :sideB_hit_count => 0}
    end

    def self.side_active?(side)
        return false unless side
        side.each do |op|
            return true if op.active?
        end
        false
    end

    def sort_combatants(dudes)
        dudes.each { |x| x.roll_temp_random }
        dudes.sort! { |x,y|
           val = x.temp_random <=> y.temp_random
           tval = x.expertise <=> y.expertise 
           val = tval unless tval == 0
           tval = x.dexterity <=> y.dexterity 
           val = tval unless tval == 0
           val
        }
    end

    def hit_chance(attacker, defender)
        value = @context[:attack_base]
        value += (attacker.expertise * @context[:ab_at_mult]).to_i
        value -= (defender.expertise * @context[:ab_de_mult]).to_i
        value += Utils.weapon_quality_bonus(attacker.high_quality_weapon)
        value += Utils.weapon_attack_bonus(attacker.weapon)
        value += Utils.style_attack_bonus(attacker.style, attacker.attack_type)
        value
    end

    def parry_chance(defender, attacker)
        value = @context[:parry_base]
        value += (defender.expertise * @context[:pb_de_mult]).to_i
        value -= (attacker.expertise * @context[:pb_at_mult]).to_i
        value += Utils.weapon_quality_bonus(attacker.high_quality_weapon)
        value += Utils.weapon_defense_bonus(attacker.weapon)
        value -= Utils.weapon_defense_penalty(defender.weapon)
        value += Utils.offhand_weapon_parry_bonus(attacker.style, attacker.offhand_weapon) unless attacker.lose_offhand_bonus
        value
    end

    def evade_chance(defender, attacker)
        value = @context[:evade_base]
        value += (defender.expertise * @context[:eb_de_mult]).to_i
        value -= (attacker.expertise * @context[:eb_at_mult]).to_i
        value
    end

    def counter_chance(attacker, defender)
        value = hit_chance(attacker, defender)
        value += @context[:counter_bonus]
        value
    end

    def calculate_damage(attacker, attack_type, defender, crit)
        dam = 0
        dam += @context[:scratch] if attacker.weapon_type == :fencing or attacker.weapon_type == :heavy
        dam += Utils.roll(@context[:crit_damage]) if crit
        dam += Utils.damage_style_type(attacker.style, attack_type)
        dam += Utils.damage_weapon_type(attacker.weapon, attack_type)
        dam
    end

    # GREG: Undo tail recursion one day.
    def do_attack(attacker, defender, is_counter = false, counter_count = 0)
        puts "#{attacker.name} #{is_counter ? "counters" : "attacks"} #{defender.name}" if $print_flow
        attack_type = attacker.attack_type
        attack_type = attacker.counter_attack_type(defender) if is_counter

        # If fencing, guess and award advantage.
        advantage = defender.guess_attack(attacker) == attack_type ? :defender : :attacker
        if advantage == :attacker
            puts "  #{attacker.name} (attacker) has advantage" if $print_flow
        else
            puts "  #{defender.name} (defender) has advantage" if $print_flow
        end

        # Attack defender
        hc = is_counter ? counter_chance(attacker, defender) : hit_chance(attacker, defender)

        hit, crit, action_mod = Utils.skill_test(hc, true, advantage == :attacker)
        puts "  #{attacker.name} #{crit ? "critical " : ""}#{action_mod}#{attack_type} #{defender.name}" if $print_flow and hit

        # Hit then defend
        if hit
            if defender.defending?
                action = "parried" if defender.parrying?
                action = "evaded" if defender.evading?
                dc = parry_chance(defender, attacker) if defender.parrying?
                dc = evade_chance(defender, attacker) if defender.evading?
            else
                # Reaction Parry - if possible
                action = "reaction parried"
                dc = parry_chance(defender, attacker) - @context[:reaction_parry_penalty] 
            end

            val, dcrit, action_mod = Utils.skill_test(dc, true, advantage == :defender)
            hit = !val
            puts "  #{defender.name} (#{dc}) #{action_mod}#{action} #{attacker.name} (#{hc})" if $print_flow
        else
            puts "  #{attacker.name} (#{hc}) misses #{defender.name}" if $print_flow
        end

        # Do damage
        if hit
            action = "damages"
            action = "crits" if crit
            dam = calculate_damage(attacker, attack_type, defender, crit)
            location = attacker.get_location(defender)
            loc = Utils.determine_location(location)
            puts "  #{attacker.name} targets the #{location}" if $print_flow
            puts "  #{attacker.name} #{action} #{defender.name} to the #{loc}" if $print_flow
            d = defender.take_damage(loc, dam, @context[:scratch])
            if d > 0
                @stats[:first_blood] = attacker.side unless @stats[:first_blood]
                hurt_side = defender.side == "A" ? :sideA_hit_count : :sideB_hit_count
                @stats[hurt_side] += 1
            end
        end

        # If missed and defender has counter, start the counters!!
        if !hit and defender.countering?
            do_attack(defender, attacker, true, counter_count + 1)
        end
    end

    def run
        # Reset stats
        @stats = {:sideA_hit_count => 0, :sideB_hit_count => 0}
        round = 0

        while Fight.side_active?(@sideA) and Fight.side_active?(@sideB)
            round += 1
            puts "Start Round #{round}" if $verbose

            # Get actions
            @sideA.each { |x| x.get_actions(@sideB) }
            @sideB.each { |x| x.get_actions(@sideA) }

            Global::WEAPON_TYPE_LIST.each do |phase|
                puts "Round #{round}/#{phase}" if $verbose

                # Get dudes actiing in this phase
                dudes = @sideA.select{|x| x.weapon_type == phase and x.attacking? }
                dudes << @sideB.select{|x| x.weapon_type == phase and x.attacking? }
                dudes.flatten!

                # Order attacks
                dudes = sort_combatants(dudes)

                # Do the attacks in order
                dudes.each do |attacker|
                    next unless attacker.attacking?  # Make sure we haven't been stunned.
                    do_attack(attacker, attacker.opponent)
                end
            end

            puts "End Round #{round}" if $verbose
        end

        round
    end

end

