
require 'yaml'
require 'person'
require 'utils'
require 'global'

class Fight
    attr_accessor :sideA
    attr_accessor :sideB

    def initialize(side1, side2)
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
           val = x.dexterity <=> y.dexterity 
           return val unless val == 0
           val = x.expertise <=> y.expertise 
           return val unless val == 0
           x.temp_random <=> y.temp_random
        }
    end

    # GREG: Undo tail recursion one day.
    def do_attack(attacker, defender, is_counter = false, counter_count = 0)
        puts "#{attacker.name} #{is_counter ? "counters" : "attacks"} #{defender.name}" if $print_flow
        attack_type = attacker.attack_type
        attack_type = attacker.counter_attack_type if is_counter

        # If fencing, guess and award advantage.
        advantage = defender.guess_attack(attacker) == attack_type ? :defender : :attacker

        # Attack defender
        hc = is_counter ? attacker.counter_chance(defender) : attacker.hit_chance(defender)

        hit, crit, action_mod = Utils.skill_test(hc, true, advantage == :attacker)
        puts "  #{attacker.name} #{crit ? "critical " : ""}#{action_mod}#{attack_type} #{defender.name}" if $print_flow and hit

        # Hit then defend
        if hit
            if defender.defending?
                action = "parried" if defender.parrying?
                action = "evaded" if defender.evading?
                dc = defender.parry_chance(attacker) if defender.parrying?
                dc = defender.evade_chance(attacker) if defender.evading?
            else
                # Reaction Parry - if possible
                action = "reaction parried"
                dc = defender.parry_chance(attacker) - 6 # GREG: Formula for this
            end

            val, dcrit, action_mod = Utils.skill_test(dc, true, advantage == :defender)
            hit = !val
            puts "  #{defender.name} #{action_mod}#{action} #{attacker.name}" if $print_flow
        else
            puts "  #{attacker.name} misses #{defender.name}" if $print_flow
        end

        # Do damage
        if hit
            action = "damages"
            dam = 2
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
        round = 1

        while Fight.side_active?(@sideA) and Fight.side_active?(@sideB)
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
            round += 1
        end

        round
    end

end

