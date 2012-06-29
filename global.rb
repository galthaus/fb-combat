
class Global
    DAMAGE_DEFAULT = 0
    HIT_POINTS_DEFAULT = 14
    EXPERTISE_DEFAULT = 14
    ENDURANCE_DEFAULT = 12
    DEXTERITY_DEFAULT = 12

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

    COMBAT_STYLE_DEFAULT = "French"
    COMBAT_STYLE_LIST = [ "French", "Italian", "Spanish" ]

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

