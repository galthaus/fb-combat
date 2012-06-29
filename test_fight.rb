
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


end

