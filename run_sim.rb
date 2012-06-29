if $0 == __FILE__

require 'person'
require 'fight'

t1 = Time.now
$verbose = ARGV[2] == "true" rescue false
$print_flow = ARGV[1] == "true" rescue false
count = ARGV[0].to_i rescue 1000

p1 = Person.new("Alex")
p2 = Person.new("Fred")

Global::ARMOR_SLOT_ROLLS.keys.each do |slot|

p1.attack_location = slot       
f = Fight.new([p1], [p2])
round_small = 100000
round_long = 0
round_total = 0
death_count = knock_out_count = resigned_count = 0
p1win = p2win = 0
count.times do
    p1.reset
    p2.reset
    r = f.run
    round_long = r if r > round_long
    round_small = r if r < round_small
    round_total += r
    p1win += 1 if p1.active?
    p2win += 1 if p2.active?
    death_count += 1 if p1.died or p2.died
    knock_out_count += 1 if p1.knocked_out or p2.knocked_out
    resigned_count += 1 if p1.resigned or p2.resigned
end
puts ""
puts "#{p1.name} with #{p1.attack_location} as target"
puts "#{p2.name} with #{p2.attack_location} as target"
puts "Alex wins #{p1win} / Fred wins #{p2win} total: #{count}"
puts "Round Data: (#{round_long}/#{round_total.to_f/count.to_f}/#{round_small})"
puts "Ending Data: Died: #{death_count} Resigned: #{resigned_count}  KnockOut: #{knock_out_count}"

end

t2 = Time.now
puts "In #{t2-t1} seconds"

end

