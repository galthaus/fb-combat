
require 'test/unit'
require 'utils.rb'
require 'global.rb'

class TestUtils < Test::Unit::TestCase

    def test_roll
        1000.times do
          r = Utils.roll
          assert (r >= 1 && r <= 20)
        end
    end

    def test_roll_mock
        $mock_die = [ 5, 100 ].reverse!
        assert_equal 5, Utils.roll
        assert_equal 100, Utils.roll
        assert_equal [], $mock_die
        $mock_die = nil
    end

    def skill_test_valid(r1, r2, target, autotest, advantaged, success, crit, answer)
        $mock_die = [ r2, r1 ]

        as, ac, aa = Utils.skill_test(target, autotest, advantaged)

        assert_equal success, as, "success: #{r1} #{r2} #{target}"
        assert_equal crit, ac, "crit: #{r1} #{r2} #{target}"
        assert_equal answer, aa, "answer: #{r1} #{r2} #{target}"

        $mock_die = nil
    end

    def test_skill_test
        # Test no auto and no advantaged
        (1..20).each do |r1|
            (-3..25).each do |target|
                answer = r1 <= target ? "" : "failed "
                answer = "crit " if r1 <= target / 3
                skill_test_valid(r1, -1, target, false, false, r1 <= target, r1 <= target / 3, answer)
            end
        end

        # Test autotest and no advantage
        (1..20).each do |r1|
            (-3..25).each do |target|
                success = (r1 != 20 && (r1 <= target || r1 == 1))
                crit = (r1 != 20 && (r1 <= target / 3))
                answer = success ? "" : "failed "
                answer = "crit " if crit
                answer = "auto-success " if (r1 == 1 && r1 > target)
                answer = "auto-fail " if (r1 == 20 && r1 <= target)
                skill_test_valid(r1, -1, target, true, false, success, crit, answer)
            end
        end

        # Test advantage and no autotest
        (1..20).each do |r1|
          (1..20).each do |r2|
            (-3..25).each do |target|
                success = r1 <= target || r2 <= target
                crit = r1 <= target / 3 || r2 <= target / 3
                answer = success ? "" : "failed "
                answer = "crit " if crit
                answer = "advantaged " + answer if ((r1 > target && r2 <= target) || (r1 > target / 3 && r2 <= target / 3))
                skill_test_valid(r1, r2, target, false, true, success, crit, answer)
            end
          end
        end

        # Test advantage and no autotest
        (1..20).each do |r1|
          (1..20).each do |r2|
            (-3..25).each do |target|
                crit = success = false
                answer = "failed "
                if r1 <= target
                    success = true
                    answer = ""
                end
                if r1 <= target / 3
                    crit = true
                    answer = "crit "
                end
                if !success && r1 == 1
                    success = true
                    answer = "auto-success "
                end
                if success && r1 == 20
                    success = crit = false
                    answer = "auto-fail "
                end
                if !success && r2 <= target
                    success = true
                    answer = "advantaged "
                end
                if !crit && r2 <= target / 3
                    crit = true
                    answer = "advantaged crit "
                end
                if !success && r2 == 1
                    success = true
                    answer = "advantaged auto-success "
                end
                if success && r1 == 20 && r2 == 20
                    success = crit = false
                    answer = "advantaged auto-fail "
                end
                skill_test_valid(r1, r2, target, true, true, success, crit, answer)
            end
          end
        end
    end

    def test_min
        assert_equal 1, Utils.min(1)
        assert_equal 1, Utils.min(1,1)
        assert_equal 1, Utils.min(2,1)
        assert_equal 1, Utils.min(1,2)
        assert_equal 1, Utils.min(1,2,3)
        assert_equal 1, Utils.min(1,3,2)
        assert_equal 1, Utils.min(2,1,3)
        assert_equal 1, Utils.min(2,3,1)
        assert_equal 1, Utils.min(3,1,2)
        assert_equal 1, Utils.min(3,2,1)
    end

    def test_max
        assert_equal 1, Utils.max(1)
        assert_equal 1, Utils.max(1,1)
        assert_equal 2, Utils.max(2,1)
        assert_equal 2, Utils.max(1,2)
        assert_equal 3, Utils.max(1,2,3)
        assert_equal 3, Utils.max(1,3,2)
        assert_equal 3, Utils.max(2,1,3)
        assert_equal 3, Utils.max(2,3,1)
        assert_equal 3, Utils.max(3,1,2)
        assert_equal 3, Utils.max(3,2,1)
    end

    def test_abs
        assert_equal 3, Utils.abs(-3)
        assert_equal 3, Utils.abs(3)
        assert_equal 0, Utils.abs(-0)
        assert_equal 0, Utils.abs(0)
    end

    def validate_det_loc(r1, r2, target, answer)
        $mock_die = [ r2, r1 ]
        assert_equal answer, Utils.determine_location(target), "loc test: #{r1} #{r2}"
        $mock_die = nil
    end

    def test_determine_location
        validate_det_loc(1, 1, :head, :head)
        validate_det_loc(1, 2, :head, :head)
        validate_det_loc(2, 2, :head, :head)
        validate_det_loc(20, 1, :head, :head)
        validate_det_loc(1, 20, :head, :head)
        validate_det_loc(20, 2, :head, :head)
        validate_det_loc(2, 20, :head, :head)

        validate_det_loc(3, 20, :head, :right_arm)
        validate_det_loc(3, 15, :head, :right_arm)
        validate_det_loc(20, 3, :head, :right_arm)
        validate_det_loc(15, 3, :head, :right_arm)
    end

    def test_quality_bonus
        assert_equal Utils.weapon_quality_bonus(true), Global::HIGH_QUALITY_BONUS
        assert_equal Utils.weapon_quality_bonus(false), 0
    end

    def test_weapon_attack_bonus
        assert_equal Utils.weapon_attack_bonus("longsword"), 1
        assert_equal Utils.weapon_attack_bonus("rapier"), 2
        assert_equal Utils.weapon_attack_bonus("fred"), 0
        assert_equal Utils.weapon_attack_bonus("unknown"), 0
    end

    def test_weapon_defense_bonus
        assert_equal Utils.weapon_defense_bonus("longsword"), 1
        assert_equal Utils.weapon_defense_bonus("rapier"), 2
        assert_equal Utils.weapon_defense_bonus("fred"), 0
        assert_equal Utils.weapon_defense_bonus("unknown"), 0
    end

    def test_weapon_defense_penalty
        assert_equal Utils.weapon_defense_penalty("longsword"), 1
        assert_equal Utils.weapon_defense_penalty("rapier"), 2
        assert_equal Utils.weapon_defense_penalty("fred"), 0
        assert_equal Utils.weapon_defense_penalty("unknown"), 0
    end

end

