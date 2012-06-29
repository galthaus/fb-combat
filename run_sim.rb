if $0 == __FILE__

require 'person'
require 'comsim'

t1 = Time.now
$verbose = ARGV[2] == "true" rescue false
$print_flow = ARGV[1] == "true" rescue false
$iter_count = ARGV[0].to_i rescue 1000

p1 = Person.new("Alex")
p2 = Person.new("Fred")

cs = ComSim.new(p1, p2, 
                { :attack_location => Global::ARMOR_SLOT_ROLLS.keys },
                { :attack_location => [:head] })
cs.run_combos

t2 = Time.now
puts "In #{t2-t1} seconds"

end

