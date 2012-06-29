

class Utils

    def self.roll(dice = "1d20")
        return $mock_die.pop if $mock_die and $mock_die.size > 0
        count = dice.split("d")[0].to_i
        die = dice.split("d")[1].to_i

        answer = 0
        count.times { answer += rand(die)+1 }
        answer
    end

    def self.skill_test(target, autotest, advantaged, die = "1d20")
        action = "failed "
        success = false
        crit = false

        r1 = Utils.roll(die)
        success = true if r1 <= target
        crit = true if r1 <= target / 3
        action = "" if success
        action = "crit " if crit
        if advantaged and !crit
            r2 = Utils.roll(die)
            action = "advantaged " if !success and r2 <= target
            success = true if r2 <= target
            action = "advantaged crit " if !crit and r2 <= target / 3
            crit = true if r2 <= target / 3
        end
        if autotest
            if !success and r1 == 1
                success = true
                action = "auto-success "
            end
            if !success and r2 == 1 and advantaged
                success = true
                action = "advantaged auto-success "
            end
            if success and r1 == 20 and !advantaged
                success = false
                crit = false
                action = "auto-fail "
            end
            if success and r1 == 20 and r2 == 20 and advantaged
                success = false
                crit = false
                action = "advantaged auto-fail "
            end
        end
        [success, crit, action]
    end

    def self.min(*args)
        args.min
    end

    def self.max(*args)
        args.max
    end

    def self.abs(v)
        v < 0 ? -v : v
    end

    def self.determine_location(location)
        r1 = Utils.roll
        r2 = Utils.roll

        bestdiff = 100000
        bestloc = :tail
        Global::ARMOR_SLOT_ROLLS.each do |k,v|
            if v[:lo] <= r1 and v[:hi] >= r1
                return location if location == k
                diff = Utils.min(Utils.abs(v[:lo] - r1), Utils.abs(v[:hi] - r1))
                if diff < bestdiff
                    bestdiff = diff
                    bestloc = k
                end
            end
            if v[:lo] <= r2 and v[:hi] >= r2
                return location if location == k
                diff = Utils.min(Utils.abs(v[:lo] - r2), Utils.abs(v[:hi] - r2))
                if diff < bestdiff
                    bestdiff = diff
                    bestloc = k
                end
            end

        end
        bestloc
    end

    def self.weapon_quality_bonus(b)
        b ? Global::HIGH_QUALITY_BONUS : 0
    end

    def self.weapon_attack_bonus(weap)
        if Global::WEAPON_BONUS_ATTACK[weap]
            Global::WEAPON_BONUS_ATTACK[weap]
        else
            Global::WEAPON_BONUS_ATTACK["unknown"]
        end
    end

    def self.weapon_defense_bonus(weap)
        if Global::WEAPON_BONUS_DEFENSE[weap]
            Global::WEAPON_BONUS_DEFENSE[weap]
        else
            Global::WEAPON_BONUS_DEFENSE["unknown"]
        end
    end

    def self.weapon_defense_penalty(weap)
        if Global::WEAPON_PENALTY_DEFENSE[weap]
            Global::WEAPON_PENALTY_DEFENSE[weap]
        else
            Global::WEAPON_PENALTY_DEFENSE["unknown"]
        end
    end

end


