
class Global
    DAMAGE_DEFAULT = 0

    ENDURANCE_DEFAULT = 10
    DEXTERITY_DEFAULT = 13
    HIT_POINTS_DEFAULT = 12

    EXPERTISE_DEFAULT = 14

    ATTACK_BASE_DEFAULT = 8
    PARRY_BASE_DEFAULT = 7
    EVADE_BASE_DEFAULT = 6

    COUNTER_BONUS_DEFAULT = 1

    ARMOR_SLOTS = 7
    ARMOR_DEFAULT = 2
    ARMOR_SLOT_ROLLS = {
       :head => { :lo => 1, :hi => 2 },
       :right_arm => { :lo => 3, :hi => 5 },
       :chest => { :lo => 6, :hi => 10 },
       :left_arm => { :lo => 11, :hi => 12 },
       :flank => { :lo => 13, :hi => 16 },
       :left_leg => { :lo => 17, :hi => 18 },
       :right_leg => { :lo => 19, :hi => 20 }
    }
    ATTACK_LOCATION_DEFAULT = :head

    SCRATCH_DEFAULT = 1

    ATTACK_GUESS_DEFAULT = { 
        :right => false,
        :wrong => true, 
        :choices => {
            :lunge => 40,
            :slash => 30,
            :thrust => 30
        }
    }
    ATTACK_TYPE_DEFAULT = :slash

    COMBAT_STYLE_DEFAULT = :french
    COMBAT_STYLE_LIST = [ :french, :italian, :spanish, :none ]
    COMBAT_STYLE_ATTACK_BONUS = {
        :italian => { :thrust => 1, :lunge => 1 },
        :spanish => { :slash => 1 }
    }

    HIGH_WEAPON_QUALITY_DEFAULT = true
    HIGH_QUALITY_BONUS = 1

    # This is in combat resolution order.
    # Changing this changes combat order.
    WEAPON_TYPE_LIST = [:ranged, :heavy, :fencing, :brawling]
    WEAPON_TYPE = {
      "pistol" => :ranged,
      "longsword" => :fencing,
      "rapier" => :fencing,
      "2h sword" => :heavy,
      "club" => :brawling
    }

    OFFHAND_WEAPON_DEFAULT = :main_gauche
    OFFHAND_WEAPON_LIST = [ :main_gauche, :good_stuff, :OK_stuff ]
    OFFHAND_PARRY_BONUS = {
        :french => { :main_gauche => 3, :good_stuff => 2, :OK_stuff => 1 },
        :italian => { :good_stuff => 1 }
    }

    WEAPON_DEFAULT = "longsword"
    WEAPON_LIST = [ "longsword", "rapier", "2h sword" ]
    WEAPON_BONUS_ATTACK = {
        "unknown" => 0,
        "longsword" => 1,
        "rapier" => 2
    }
    WEAPON_BONUS_DEFENSE = {
        "unknown" => 0,
        "longsword" => 1,
        "rapier" => 2
    }
    WEAPON_PENALTY_DEFENSE = {
        "unknown" => 0,
        "longsword" => 1,
        "rapier" => 2
    }
end

