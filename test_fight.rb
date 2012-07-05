
require 'test/unit'
require 'person.rb'
require 'fight.rb'
require 'utils.rb'
require 'global.rb'


class TestFight < Test::Unit::TestCase

    def test_fight_side_active
        assert_equal false, Fight.side_active?(nil)
        assert_equal false, Fight.side_active?([])
        assert_equal true, Fight.side_active?([Person.new])
    end

    def test_chance_functions
        p1 = Person.new("Fred", {:expertise => 10})
        p2 = Person.new("James", {:expertise => 10})
        f = Fight.new([p1], [p2])
        assert_equal 10, f.hit_chance(p1, p2)
        assert_equal 10, f.hit_chance(p2, p1)
        assert_equal 11, f.parry_chance(p1, p2)
        assert_equal 11, f.parry_chance(p2, p1)
        assert_equal 6, f.evade_chance(p1, p2)
        assert_equal 6, f.evade_chance(p2, p1)
        assert_equal 11, f.counter_chance(p1, p2)
        assert_equal 11, f.counter_chance(p2, p1)
        # This could be more, but not now.  It is enough for simple tests.
    end

end

