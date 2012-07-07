
require 'test/unit'
require 'person.rb'
require 'global.rb'

$debug = false

class TestPerson < Test::Unit::TestCase

    def test_name
        p = Person.new
        assert_equal p.name, "Fred"
        p = Person.new("Greg")
        assert_equal p.name, "Greg"
    end

    def test_load_store
        p = Person.new
        p.dump("person_test.yml")

        p2 = Person.load("person_test.yml")
        assert_equal p.name, p2.name

        File.delete("person_test.yml")
    end

    def test_apply_variants
        p = Person.new
        p.apply_variants([{ :expertise => 25 }])
        assert_equal 25, p.expertise
        p.apply_variants([{ :expertise => 22 }, {:style => :fred}])
        assert_equal 22, p.expertise
        assert_equal :fred, p.style
        p.apply_variants([:base])
        assert_equal 22, p.expertise
        assert_equal :fred, p.style
    end

    def test_damage
        tdamage = {
            :head => Global::DAMAGE_DEFAULT,
            :right_leg => Global::DAMAGE_DEFAULT,
            :right_arm => Global::DAMAGE_DEFAULT,
            :left_leg => Global::DAMAGE_DEFAULT,
            :left_arm => Global::DAMAGE_DEFAULT,
            :chest => Global::DAMAGE_DEFAULT,
            :flank => Global::DAMAGE_DEFAULT
        }
        p = Person.new
        assert_equal tdamage, p.damage
        assert_equal tdamage, p.start_damage
        assert_equal Global::DAMAGE_DEFAULT * 7, p.total_damage

        tdamage = {
            :head => 12,
            :right_leg => 12,
            :right_arm => 12,
            :left_leg => 12,
            :left_arm => 12,
            :chest => 12,
            :flank => 12
        }
        p = Person.new("Fred", {:damage_default => 12})
        assert_equal tdamage, p.damage
        assert_equal tdamage, p.start_damage
        assert_equal 12*7, p.total_damage

        tdamage = {
            :head => 0,
            :right_leg => 1,
            :right_arm => 2,
            :left_leg => 3,
            :left_arm => 4,
            :chest => 5,
            :flank => 6
        }
        p = Person.new("Fred", {:damage => tdamage})
        assert_equal tdamage, p.damage
        assert_equal tdamage, p.start_damage
        assert_equal 21, p.total_damage
    end

    def test_armor
        p = Person.new
        tarmor = {
            :head => Global::ARMOR_DEFAULT,
            :right_leg => Global::ARMOR_DEFAULT,
            :right_arm => Global::ARMOR_DEFAULT,
            :left_leg => Global::ARMOR_DEFAULT,
            :left_arm => Global::ARMOR_DEFAULT,
            :chest => Global::ARMOR_DEFAULT,
            :flank => Global::ARMOR_DEFAULT
        }
        assert_equal tarmor, p.armor

        tarmor = {
            :head => 12,
            :right_leg => 12,
            :right_arm => 12,
            :left_leg => 12,
            :left_arm => 12,
            :chest => 12,
            :flank => 12
        }
        p = Person.new("Fred", {:armor_default => 12})
        assert_equal tarmor, p.armor

        tarmor = {
            :head => 0,
            :right_leg => 1,
            :right_arm => 2,
            :left_leg => 3,
            :left_arm => 4,
            :chest => 5,
            :flank => 6
        }
        p = Person.new("Fred", {:armor => tarmor})
        assert_equal tarmor, p.armor
    end

    def test_hitpoints
        p = Person.new
        assert_equal p.hit_points, Global::HIT_POINTS_DEFAULT

        p = Person.new("Fred", {:hit_points => 21})
        assert_equal 21, p.hit_points
    end

    def test_expertise
        p = Person.new
        assert_equal p.expertise, Global::EXPERTISE_DEFAULT

        p = Person.new("Fred", {:expertise => 21})
        assert_equal 21, p.expertise
    end

    def test_endurance
        p = Person.new
        assert_equal p.endurance, Global::ENDURANCE_DEFAULT

        p = Person.new("Fred", {:endurance => 21})
        assert_equal 21, p.endurance
    end

    def test_dexterity
        p = Person.new
        assert_equal p.dexterity, Global::DEXTERITY_DEFAULT

        p = Person.new("Fred", {:dexterity => 21})
        assert_equal 21, p.dexterity
    end

    def test_weapon
        p = Person.new
        assert_equal p.weapon, Global::WEAPON_DEFAULT

        Global::WEAPON_LIST.each do |weap|
            p = Person.new("Fred", {:weapon => weap})
            assert_equal weap, p.weapon
        end

        begin 
            p = Person.new("Fred", {:weapon=> "fred"})
            assert false
        rescue
            # Success!
        end
    end

    def test_weapon_qaulity
        p = Person.new
        assert_equal p.high_quality_weapon, Global::HIGH_WEAPON_QUALITY_DEFAULT

        p = Person.new("Fred", {:high_quality_weapon => true})
        assert_equal p.high_quality_weapon, true
        p = Person.new("Fred", {:high_quality_weapon => false})
        assert_equal p.high_quality_weapon, false
    end

    def validate_damage(p, slot, dam, res, died, unc, stunned, offhand)
        assert_equal p.damage[slot], dam, "Damage Slot"
        assert_equal p.resigned, res, "Resigned"
        assert_equal p.died, died, "Died"
        assert_equal p.knocked_out, unc, "knocked out"
        assert_equal p.stunned, stunned, "Stunned"
        assert_equal p.lose_offhand_bonus, offhand, "Offhand"
        active = p.active?
        if died or unc or res
            assert_equal p.active?, false 
        else
            assert_equal p.active?, true
        end
    end

    # Assume defaults
    def test_take_damage
        # Hit Head
        p = Person.new
        p.take_damage(:head, 1, 1)
        validate_damage(p, :head, 1, false, false, false, false, false)

        p = Person.new
        p.take_damage(:head, 2, 1)
        validate_damage(p, :head, 1, false, false, false, false, false)

        p = Person.new
        p.take_damage(:head, 3, 1)
        validate_damage(p, :head, 1, false, false, false, false, false)

        p = Person.new
        p.get_actions
        assert p.actions.size > 1
        p.take_damage(:head, 4, 1)
        validate_damage(p, :head, 2, false, false, false, true, false)
        assert p.actions.size == 0

        p = Person.new
        p.take_damage(:head, 5, 1)
        validate_damage(p, :head, 3, false, false, false, true, false)

        p = Person.new
        p.take_damage(:head, 6, 1)
        validate_damage(p, :head, 4, false, false, false, true, false)

        p = Person.new
        p.take_damage(:head, 7, 1)
        validate_damage(p, :head, 5, false, false, false, true, false)

        p = Person.new
        p.take_damage(:head, 8, 1)
        validate_damage(p, :head, 6, false, false, true, true, false)

        p = Person.new
        p.take_damage(:head, 9, 1)
        validate_damage(p, :head, 7, false, true, false, true, false)

        p = Person.new
        p.take_damage(:head, 1, 1)
        validate_damage(p, :head, 1, false, false, false, false, false)
        p.take_damage(:head, 1, 1)
        validate_damage(p, :head, 2, false, false, false, false, false)
        p.take_damage(:head, 1, 1)
        validate_damage(p, :head, 3, false, false, false, false, false)
        p.take_damage(:head, 1, 1)
        validate_damage(p, :head, 4, false, false, false, false, false)
        p.take_damage(:head, 1, 1)
        validate_damage(p, :head, 5, false, false, false, false, false)
        p.take_damage(:head, 1, 1)
        validate_damage(p, :head, 6, false, false, true, false, false)
        p.take_damage(:head, 1, 1)
        validate_damage(p, :head, 7, false, true, false, false, false)

        # Right Arm, Right Leg, and Left Leg work the same.
        [:left_leg, :right_leg, :right_arm].each do |slot|
            p = Person.new
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 1, false, false, false, false, false)
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 2, false, false, false, false, false)
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 3, false, false, false, false, false)
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 4, false, false, false, false, false)
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 5, false, false, false, false, false)
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 6, true, false, false, false, false)

            $end_check_override = true
            $end_check_override_value = false
            p = Person.new
            p.take_damage(slot, 5, 1)
            validate_damage(p, slot, 3, true, false, false, false, false)

            $end_check_override_value = true
            p = Person.new
            p.take_damage(slot, 5, 1)
            validate_damage(p, slot, 3, false, false, false, false, false)
            $end_check_override = false
        end

        # Flank and Chest are the same
        [:flank, :chest].each do |slot|
            p = Person.new
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 1, false, false, false, false, false)
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 2, false, false, false, false, false)
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 3, false, false, false, false, false)
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 4, false, false, false, false, false)
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 5, false, false, false, false, false)
            p.take_damage(slot, 1, 1)
            validate_damage(p, slot, 6, false, false, true, false, false)

            p = Person.new
            p.take_damage(slot, 6, 1)
            validate_damage(p, slot, 4, false, false, false, true, false)
        end

        # Left Arm
        slot = :left_arm
        p = Person.new
        p.take_damage(slot, 1, 1)
        validate_damage(p, slot, 1, false, false, false, false, false)
        p.take_damage(slot, 1, 1)
        validate_damage(p, slot, 2, false, false, false, false, false)
        p.take_damage(slot, 1, 1)
        validate_damage(p, slot, 3, false, false, false, false, false)
        p.take_damage(slot, 1, 1)
        validate_damage(p, slot, 4, false, false, false, false, false)
        p.take_damage(slot, 1, 1)
        validate_damage(p, slot, 5, false, false, false, false, false)
        p.take_damage(slot, 1, 1)
        validate_damage(p, slot, 6, false, false, false, false, true)

        $end_check_override = true
        $end_check_override_value = false
        p = Person.new
        p.take_damage(slot, 5, 1)
        validate_damage(p, slot, 3, false, false, false, false, false)

        $end_check_override_value = true
        p = Person.new
        p.take_damage(slot, 5, 1)
        validate_damage(p, slot, 3, false, false, false, false, false)
        $end_check_override = false
    end

    def test_weapon_type
        p1 = Person.new("James", {:weapon => "fred"})
        assert_equal :brawling, p1.weapon_type
        p1.weapon = "rapier"
        assert_equal :fencing, p1.weapon_type
        p1.weapon = nil
        assert_equal :brawling, p1.weapon_type
    end

    def test_roll_temp_random
        p1 = Person.new("James", {:weapon => "fred"})
        $mock_die = [ 5 ]
        assert_equal 5, p1.roll_temp_random
        $mock_die = nil
    end

    def test_attack_location
        p1 = Person.new("James", {:attack_location => :tail})
        assert_equal :tail, p1.get_location(p1)
    end

    def test_attack_type
        p1 = Person.new("James", {:attack_type => :tail})
        assert_equal :tail, p1.default_attack_type
        assert_equal nil, p1.attack_type
        p1.get_actions
        assert_equal :tail, p1.attack_type
        assert_equal false, p1.striking?
        assert_equal false, p1.thrusting?
        assert_equal false, p1.slashing?
        assert_equal false, p1.lunging?

        p1.attack_type = :slash
        assert_equal false, p1.striking?
        assert_equal false, p1.thrusting?
        assert_equal true, p1.slashing?
        assert_equal false, p1.lunging?

        p1.attack_type = :lunge
        assert_equal false, p1.striking?
        assert_equal false, p1.thrusting?
        assert_equal false, p1.slashing?
        assert_equal true, p1.lunging?

        p1.attack_type = :thrust
        assert_equal false, p1.striking?
        assert_equal true, p1.thrusting?
        assert_equal false, p1.slashing?
        assert_equal false, p1.lunging?

        p1.attack_type = :heavy
        assert_equal true, p1.striking?
        assert_equal false, p1.thrusting?
        assert_equal false, p1.slashing?
        assert_equal false, p1.lunging?
    end

    def actions_test(actions, att, deff, par, eva, cou)
        p1 = Person.new("James", {:attack_type => :slash, :actions => actions})
        p1.get_actions([p1])
        assert_equal att, p1.attacking?
        assert_equal deff, p1.defending?
        assert_equal par, p1.parrying?
        assert_equal eva, p1.evading?
        assert_equal cou, p1.countering?
    end

    def test_actions
        actions_test(nil, true, true, true, false, false)
        actions_test([:attack, :parry], true, true, true, false, false)
        actions_test([:parry, :attack], true, true, true, false, false)
        actions_test([:parry, :counter], false, true, true, false, true)
        actions_test([:attack, :counter], true, false, false, false, true)
        actions_test([:attack, :evade], true, true, false, true, false)
    end

    def test_stunned_actions
        p1 = Person.new("James", {:attack_type => :slash, :stun_action => :attack})
        p1.take_damage(:head, 5, 1)
        assert_equal true, p1.stunned
        p1.get_actions([p1])
        assert_equal [:stun, :attack], p1.actions
        assert_equal false, p1.stunned
    end

    def test_guess_attack
        a = Global::ATTACK_GUESS_DEFAULT
        a[:wrong] = false
        p1 = Person.new("James", {:weapon => "rapier", :attack_guess => a})
        $mock_die = [ 5 ]
        assert_equal :lunge, p1.guess_attack(p1)
        $mock_die = nil
        $mock_die = [ 45 ]
        assert_equal :slash, p1.guess_attack(p1)
        $mock_die = nil
        $mock_die = [ 95 ]
        assert_equal :thrust, p1.guess_attack(p1)
        $mock_die = nil
        $mock_die = [ 195 ]
        assert_equal :fred, p1.guess_attack(p1)
        $mock_die = nil

        p1 = Person.new("James", {:attack_guess => {:right => true}, :attack_type => :john})
        p1.get_actions(p1)
        $mock_die = [ 5 ]
        assert_equal :john, p1.guess_attack(p1)
        $mock_die = nil
        p1 = Person.new("James", {:attack_guess => {:wrong => true}, :attack_type => :john})
        p1.get_actions(p1)
        $mock_die = [ 5 ]
        assert_equal :fred, p1.guess_attack(p1)
        $mock_die = nil
        p1 = Person.new("James", {:attack_guess => {:right => false, :wrong => true}, :attack_type => :john})
        p1.get_actions(p1)
        $mock_die = [ 5 ]
        assert_equal :fred, p1.guess_attack(p1)
        $mock_die = nil
        p1 = Person.new("James", {:attack_guess => {:right => true, :wrong => true}, :attack_type => :john})
        p1.get_actions(p1)
        $mock_die = [ 5 ]
        assert_equal :john, p1.guess_attack(p1)
        $mock_die = nil

        p1 = Person.new("James", {:weapon => "club"})
        p1.get_actions(p1)
        assert_equal :brawling, p1.guess_attack(p1)
    end

    def test_counter_attack_type
        p1 = Person.new("James", {:counter_attack_type => :tail})
        assert_equal :tail, p1.counter_attack_type(p1)
    end

end

