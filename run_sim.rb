if $0 == __FILE__

require 'person'
require 'comsim'

t1 = Time.now
$verbose = ARGV[2] == "true" rescue false
$print_flow = ARGV[1] == "true" rescue false
$iter_count = ARGV[0].to_i rescue 1000

p1 = Person.new("Alex")
p2 = Person.new("Fred")

context = {
    :attack_base => 8,
    :parry_base => 7,
    :evade_base => 6,
    :ab_at_mult => 1.0, # Attack Base Attacker Experience Multiplier
    :ab_de_mult => 1.0, # Attack Base Defender Experience Multiplier
    :pb_at_mult => 1.0, # Parry Base Attacker Experience Multiplier
    :pb_de_mult => 1.0, # Parry Base Defender Experience Multiplier
    :eb_at_mult => 1.0, # Evade Base Attacker Experience Multiplier
    :eb_de_mult => 1.0, # Evade Base Defender Experience Multiplier
    :counter_bonus => 1,
    :scratch => 1,
    :reaction_parry_penalty => 6
}

# NOTE: Actions lists are:
# Attack type should be :slash, :parry for these:
#   [ stun, parry ]
#   [ stun, evade ]
#   [ stun, attack ]
#   [ stun, counter ]
#   [ counter, parry ]
#   [ counter, evade ]
#   [ counter, attack ]
#   [ parry, attack ]
#   [ evade, attack ]
# Attack type should be lunge for these:
#   [ attack ] # Lunge case 
# 


# Big Run
compare = { 
    :attack_location => [ :chest ], # Or build subsets :chest, :flank, :right_arm, :right_leg, :left_arm, :left_leg
    :default_actions => [ [:attack, :counter] ], # Default action (:counter, :parry, :attack, :evade)
    :stun_action => [ :parry ], # Action to take when stunned
    :default_attack_type => [ :thrust ], # Attack type: :slash, :lunge, :thrust
    :counter_attack_type => [ :thrust ], # Attack type to use on counter: :slash, :thrust
    :endurance => (10..10), # Endurance 
    :dexterity => (13..13), # Dexterity
    :hit_points => (12..12), # (X..Y) means X to Y inclusive  (X...Y) means X to Y-1.
    :expertise => [10,12,14,16,18,20,22,24], # Can use above syntax or just comma separated numbers
    :weapon => ["longsword", "rapier"], # longsword, rapier, sabre, (one day pistol, 2h sword, club)
    :high_quality_weapon => [ true ], # true or false if weapons are HQ
    :offhand_weapon => [:main_gauche], # :main_gauche, :good_stuff, :OK_stuff in a list
    :style => [ :french ], # styles are: :italian, :french, :spanish
    :attack_guess => [{ :right => true }]  # This line means the defender always guesses right!
#    :attack_guess => [{ :wrong => true }]  # This line means the defender always guesses wrong!
#    :attack_guess => [{:choices => { :slash => 30, :lunge => 30, :thrust => 40 }}]  # This line means the defender guess in those percentages!
}
compare1 = compare

cs = ComSim.new(p1, p2, context, compare, compare1)
cs.run_combos

t2 = Time.now
puts "In #{t2-t1} seconds" if @debug

end

