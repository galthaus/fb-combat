
require 'yaml'
require 'global'
require 'utils'

class Person
    attr_accessor :name
    attr_accessor :armor
    attr_accessor :damage
    attr_accessor :start_damage
    attr_accessor :hit_points
    attr_accessor :endurance
    attr_accessor :dexterity
    attr_accessor :expertise
    attr_accessor :weapon
    attr_accessor :offhand_weapon
    attr_accessor :style
    attr_accessor :high_quality_weapon
    attr_accessor :actions
    attr_accessor :attack_location
    attr_accessor :attack_guess
    attr_accessor :default_attack_type
    attr_reader :died
    attr_reader :resigned
    attr_reader :knocked_out
    attr_reader :stunned
    attr_reader :lose_offhand_bonus
    attr_reader :temp_random
    attr_reader :opponent
    attr_reader :attack_type
    attr_accessor :side

    def initialize(n = "Fred", options = {})
        @name = n

        @armor = options[:armor]
        unless @armor
            @armor = {}
            Global::ARMOR_SLOT_ROLLS.keys.each do |x|
                @armor[x] = (options[:armor_default] || Global::ARMOR_DEFAULT)
            end
        end
        @damage = options[:damage]
        unless @damage
            @damage = {}
            Global::ARMOR_SLOT_ROLLS.keys.each do |x|
                @damage[x] = (options[:damage_default] || Global::DAMAGE_DEFAULT)
            end
        end
        @start_damage = @damage.clone
        @hit_points = options[:hit_points] || Global::HIT_POINTS_DEFAULT
        @expertise = options[:expertise] || Global::EXPERTISE_DEFAULT
        @endurance = options[:endurance] || Global::ENDURANCE_DEFAULT
        @dexterity = options[:dexterity] || Global::DEXTERITY_DEFAULT
        @style = options[:style] || Global::COMBAT_STYLE_DEFAULT
        @attack_location = options[:attack_location] || Global::ATTACK_LOCATION_DEFAULT
        @weapon = options[:weapon] || Global::WEAPON_DEFAULT
        @offhand_weapon = options[:offhand_weapon] || Global::OFFHAND_WEAPON_DEFAULT
        @high_quality_weapon = options[:high_quality_weapon]
        @high_quality_weapon = Global::HIGH_WEAPON_QUALITY_DEFAULT if @high_quality_weapon.nil?
        @attack_guess = options[:attack_guess] || Global::ATTACK_GUESS_DEFAULT 
        @default_attack_type = options[:attack_type] || Global::ATTACK_TYPE_DEFAULT 
        reset
    end

    def apply_variants(vars)
        vars.each do |a|
            return if a == :base
            a.each do |k,v|
              eval("@#{k} = v")
            end
        end
    end

    def total_damage
        @damage.values.inject(0, :+)
    end

    def end_check
        r = Utils.roll
        value = Utils.roll <= @endurance
        puts "Player #{name}: End check: #{r} #{@endurance} #{value}" if $debug
        value = $end_check_override_value if $end_check_override
        value
    end

    def take_damage(loc, d)
        # Handle Damage
        d -= armor[loc]
        d = Global::SCRATCH_DEFAULT if d < Global::SCRATCH_DEFAULT

        puts "#{@name} takes #{d} in the #{loc}" if $print_flow
        @damage[loc] += d

        # Check for died
        @died = @died || @hit_points <= total_damage

        # Check for resigned/stunned/offhand fail
        case loc
            when :head
                @stunned = @stunned || (d >= 2) 
                @knocked_out = @knocked_out || (@hit_points / 2) == @damage[loc] 
                @died = @died || (@hit_points / 2) < @damage[loc] 
            when :left_arm
                @lose_offhand_bonus = false if d >= 3 and !end_check
                @lose_offhand_bonus = @lose_offhand_bonus || (@hit_points / 2) <= @damage[loc] 
            when :right_arm
                @resigned = @resigned || !end_check if d >= 3
                @resigned = @resigned || (@hit_points / 2) <= @damage[loc] 
            when :left_leg
                @resigned = @resigned || !end_check if d >= 3
                @resigned = @resigned || (@hit_points / 2) <= @damage[loc] 
            when :right_leg
                @resigned = @resigned || !end_check if d >= 3
                @resigned = @resigned || (@hit_points / 2) <= @damage[loc] 
            when :chest
                @stunned = true if d >= 4
                @knocked_out = @knocked_out || (@hit_points / 2) <= @damage[loc] 
            when :flank
                @stunned = true if d >= 4
                @knocked_out = @knocked_out || (@hit_points / 2) <= @damage[loc] 
        end 

        @knocked_out = @resigned = false if @died  # We died - not the rest of the things

        @actions = [] unless active?
        @actions = [] if @stunned
    end

    def guess_attack(opponent)
        if opponent.weapon_type == :fencing
            right = @attack_guess[:right] rescue false
            wrong = @attack_guess[:wrong] rescue false
            return opponent.attack_type if right
            return :fred if wrong

            choices = @attack_guess[:choices] rescue nil
            return :fred unless choices
            count = choices.values.inject(0, :+)
            roll = Utils.roll("1d#{count}")
            sum = 0
            choices.sort { |x,y| x.to_s <=> y.to_s }.each do |k,v|
                return k if roll <= v
                roll -= v
            end
            return :fred
        end
        return opponent.weapon_type
    end

    def get_actions(opponents = nil)
       # GREG: Define two actions - assume toe to toe - options are:
       #   [ stun, parry ]
       #   [ stun, evade ]
       #   [ stun, attack ]
       #   [ stun, counter ]
       #   [ attack ] # Lunge case
       #   [ counter, parry ]
       #   [ counter, evade ]
       #   [ counter, attack ]
       #   [ parry, attack ]
       #   [ evade, attack ]
       if @stunned
           @actions = [ :stun, :parry ]
           @stunned = false
       else
           @actions = [ :attack, :parry ]
       end
       @opponent = opponents.first rescue nil
       @attack_type = @default_attack_type
    end

    def parrying?
      @actions.include?(:parry)
    end

    def evading?
      @actions.include?(:evade)
    end

    def attacking?
      @actions.include?(:attack)
    end

    def countering?
      @actions.include?(:counter)
    end

    def defending?
      parrying? || evading?
    end

    def striking?
      @attack_type == :heavy
    end

    def slashing?
      @attack_type == :slash
    end

    def thrusting?
      @attack_type == :thrust
    end

    def lunging?
      @attack_type == :thrust
    end

    def active?
        !@died and !@knocked_out and !@resigned
    end

    def counter_attack_type(opponent)
        @default_attack_type
    end

    def get_location(opponent)
        # GREG: Choose this one day
        @attack_location
    end

    def reset
        @actions = []
        @stunned = false
        @resigned = false
        @knocked_out = false
        @died = false
        @lose_offhand_bonus = false
        @damage = @start_damage.clone
    end

    def weapon_type
        Global::WEAPON_TYPE[@weapon] || :brawling rescue :brawling
    end

    def roll_temp_random
        @temp_random = Utils.roll("1d100000000")
    end

    def dump(file)
        File.open(file, 'w') {|f| f.write(YAML::dump(self))}
    end

    def self.load(file)
        YAML.load_file(file)
    end
end

