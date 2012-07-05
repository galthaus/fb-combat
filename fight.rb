
require 'yaml'
require 'person'
require 'utils'
require 'global'

class Fight
    attr_accessor :sideA
    attr_accessor :sideB

    def initialize(side1, side2, ctx = nil)
        @context = ctx || {}
        @context[:attack_base] = Global::ATTACK_BASE_DEFAULT unless @context[:attack_base]
        @context[:parry_base] = Global::PARRY_BASE_DEFAULT unless @context[:parry_base]
        @context[:evade_base] = Global::EVADE_BASE_DEFAULT unless @context[:evade_base]
        @context[:counter_bonus] = Global::COUNTER_BONUS_DEFAULT unless @context[:counter_bonus]
        @context[:reaction_parry_penalty] = Global::REACTION_PARRY_PENALTY unless @context[:reaction_parry_penalty]
        @context[:scratch] = Global::SCRATCH_DEFAULT unless @context[:scratch]
        @sideA = side1
        @sideA.each { |x| x.side = "A" }
        @sideB = side2
        @sideB.each { |x| x.side = "B" }
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
        value += attacker.expertise
        value -= defender.expertise
        value += Utils.weapon_quality_bonus(attacker.high_quality_weapon)
        value += Utils.weapon_attack_bonus(attacker.weapon)
        value += Utils.style_attack_bonus(attacker.style, attacker.attack_type)
        value
    end

    def parry_chance(attacker, defender)
        value = @context[:parry_base]
        value += attacker.expertise
        value -= defender.expertise
        value += Utils.weapon_quality_bonus(attacker.high_quality_weapon)
        value += Utils.weapon_defense_bonus(attacker.weapon)
        value -= Utils.weapon_defense_penalty(defender.weapon)
        value += Utils.offhand_weapon_parry_bonus(attacker.style, attacker.offhand_weapon) unless attacker.lose_offhand_bonus
        value
    end

    def evade_chance(attacker, defender)
        value = @context[:evade_base]
        value += attacker.expertise
        value -= defender.expertise
        value
    end

    def counter_chance(attacker, defender)
        value = hit_chance(attacker, defender)
        value += @context[:counter_bonus]
        value
    end

    # GREG: Undo tail recursion one day.
    def do_attack(attacker, defender, is_counter = false, counter_count = 0)
        puts "#{attacker.name} #{is_counter ? "counters" : "attacks"} #{defender.name}" if $print_flow
        attack_type = attacker.attack_type
        attack_type = attacker.counter_attack_type if is_counter

        # If fencing, guess and award advantage.
        advantage = defender.guess_attack(attacker) == attack_type ? :defender : :attacker
        if advantage == :attacker
            puts "  #{attacker.name} (attacker) has advantage" if $print_flow
        else
            puts "  #{defender.name} (defender) has advantage" if $print_flow
        end

        # Attack defender
        hc = is_counter ? counter_chance(attacher, defender) : hit_chance(attacker, defender)

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
                # GREG: Formula for this
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
            dam = 2
            dam += @context[:scratch] if attacker.weapon_type == :fencing or attacker.weapon_type == :heavy
            action = "crits" if crit
            dam += Utils.roll("1d4") if crit
            location = attacker.get_location(defender)
            loc = Utils.determine_location(location)
            puts "  #{attacker.name} targets the #{location}" if $print_flow
            puts "  #{attacker.name} #{action} #{defender.name} to the #{loc}" if $print_flow
            defender.take_damage(loc, dam)
        end

        # If missed and defender has counter, start the counters!!
        if !hit and defender.countering?
            do_attack(defender, attacker, true, counter_count + 1)
        end
    end

    def run
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

