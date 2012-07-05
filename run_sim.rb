if $0 == __FILE__

require 'person'
require 'comsim'

t1 = Time.now
$verbose = ARGV[2] == "true" rescue false
$print_flow = ARGV[1] == "true" rescue false
$iter_count = ARGV[0].to_i rescue 1000

p1 = Person.new("Alex")
p2 = Person.new("Fred")

# Big Run
compare = { 
#    :attack_location => Global::ARMOR_SLOT_ROLLS.keys, 
    :attack_location => [ :chest ],
    :hit_points => (12..12),
    :expertise => [10,12,14,16,18,20,22,24],
    :weapon => ["longsword", "rapier"],
    :style => [ :french ],
    :attack_guess => [{ :right => true }]  # This line means the defender always guesses right!
#    :attack_guess => [{ :wrong => true }]  # This line means the defender always guesses wrong!
#    :attack_guess => [{:choices => { :slash => 30, :lunge => 30, :thrust => 40 }}]  # This line means the defender guess in those percentages!
}
compare1 = compare

#compare = {
#    :expertise => [ 24 ],
#    :style => [ :french ]
#}
#compare1 = {
#    :style => [ :italian ]
#}

cs = ComSim.new(p1, p2, compare, compare1)
cs.run_combos

t2 = Time.now
puts "In #{t2-t1} seconds"

end

