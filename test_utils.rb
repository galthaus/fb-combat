
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

        assert_equal success, as, "success: #{r1} #{target}"
        assert_equal crit, ac, "crit: #{r1} #{target}"
        assert_equal answer, aa, "answer: #{r1} #{target}"

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

        # Test autotest
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

        # Test advantage

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

