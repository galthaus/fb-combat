
require 'test/unit'
require 'person.rb'
require 'comsim.rb'
require 'utils.rb'
require 'global.rb'


class TestComSim < Test::Unit::TestCase

    def test_basic_comsim_fight
        $iter_count = 1
        cs = ComSim.new(Person.new("Greg"), Person.new("John"))
        cs.run_combos
    end

end

