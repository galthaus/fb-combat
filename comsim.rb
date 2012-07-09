
require 'yaml'
require 'person'
require 'fight'
require 'utils'
require 'global'

class ComSim

    def initialize(p1, p2, ctx = nil, s1v = nil, s2v = nil)
        @context = ctx
        @person1 = p1
        @person2 = p2

        if s1v
          @s1constants = s1v.select {|k,v| v.to_a.size == 1 }
          @s1variants = s1v.select {|k,v| v.to_a.size != 1 }
        else
          @s1constants = nil
          @s1variants = nil
        end

        if s2v
          @s2constants = s2v.select {|k,v| v.to_a.size == 1 }
          @s2variants = s2v.select {|k,v| v.to_a.size != 1 }
        else
          @s2constants = nil
          @s2variants = nil
        end
    end

    def run_combos
        if @s1constants and @s1constants.size > 0
            vlist = []
            @s1constants.each do |k,v|
                 new_list = []
                 v.each do |x|
                      new_list << { k => x }
                 end
                 vlist << new_list
            end
            s1const = vlist.pop
            s1const = s1const.product(*vlist) unless vlist.empty?
            s1const = [s1const] if vlist.empty?
        else
            s1const = [[:base]]
        end
        if @s1variants and @s1variants.size > 0
            vlist = []
            @s1variants.each do |k,v|
                 new_list = []
                 v.each do |x|
                      new_list << { k => x }
                 end
                 vlist << new_list
            end
            s1people = vlist.pop
            s1people = s1people.product(*vlist) unless vlist.empty?
            s1people = [s1people] if vlist.empty?
        else
            s1people = [[:base]]
        end
        if @s2constants and @s2constants.size > 0
            vlist = []
            @s2constants.each do |k,v|
                 new_list = []
                 v.each do |x|
                      new_list << { k => x }
                 end
                 vlist << new_list
            end
            s2const = vlist.pop
            s2const = s2const.product(*vlist) unless vlist.empty?
            s2const = [s2const] if vlist.empty?
        else
            s2const = [[:base]]
        end
        if @s2variants and @s2variants.size > 0
            vlist = []
            @s2variants.each do |k,v|
                 new_list = []
                 v.each do |x|
                      new_list << { k => x }
                 end
                 vlist << new_list
            end
            s2people = vlist.pop
            s2people = s2people.product(*vlist) unless vlist.empty?
            s2people = [s2people] if vlist.empty?
        else
            s2people = [[:base]]
        end

        puts "Running #{s1people.size * s2people.size} Combos: #{s1people.size} X #{s2people.size}" if @debug
        if @context
            @context.each do |k,v|
                puts "#{k},#{v}"
            end
        end
        if s1const == [[:base]]
            puts "Player1,base"
        else
           s1const.first.each do |a|
               a.each do |k,v|
                   puts "Player1 #{k},#{v}"
               end
           end
        end
        if s2const == [[:base]]
            puts "Player2,base"
        else
           s2const.first.each do |a|
               a.each do |k,v|
                   puts "Player2 #{k},#{v}"
               end
           end
        end
        @person1.apply_variants(s1const.first)
        @person2.apply_variants(s2const.first)
        s1keys = s1people.first
        if s1keys == [:base]
            s1keys = nil
        else
            s1keys = s1keys.map {|x| x.keys }.flatten
            s1keys.sort! { |x,y| x.to_s <=> y.to_s}
        end
        s2keys = s2people.first
        if s2keys == [:base]
            s2keys = nil
        else
            s2keys = s2keys.map {|x| x.keys }.flatten
            s2keys.sort! { |x,y| x.to_s <=> y.to_s}
        end
        header = ""
        if s1keys
            header += "Player1 " + s1keys.join(",Player1 ")
        end
        if s2keys
            header += "," if header != ""
            header += "Player2 " + s2keys.join(",Player2 ")
        end
        header += ",W1,W2,Wcount,LR,AR,SR,D,U,R,divider,FBW,W0,W1,W2,W3+,L1,L2,L3+,divider"
        puts header
        s1people.each do |s1v|
            s1line = ""
            if s1keys
                s1keys.each do |key|
                    s1v.each do |a|
                        a.each do |k,v|
                            s1line += "," if s1line != "" and k == key
                            s1line += "#{v}" if k == key
                        end
                    end
                end
            end
            @person1.apply_variants(s1v)
            s2people.each do |s2v|
                s2line = ""
                if s2keys
                    s2keys.each do |key|
                        s2v.each do |a|
                            a.each do |k,v|
                                s2line += "," if s2line != "" and k == key
                                s2line += "#{v}" if k == key
                            end
                        end
                    end
                end
                @person2.apply_variants(s2v)
                data = run_fight(@person1, @person2)
                answer = ""
                answer += s1line + "," if s1line != ""
                answer += s2line + "," if s2line != ""
                answer += data.join(",")
                puts answer
            end
        end
    end

    def run_fight(p1, p2)
        f = Fight.new([p1], [p2], @context)

        p p1 if $verbose
        p p2 if $verbose

        round_small = 100000
        round_long = 0
        round_total = 0
        death_count = knock_out_count = resigned_count = 0
        win_hit0 = win_hit1 = win_hit2 = win_hit3 = 0
        lose_hit1 = lose_hit2 = lose_hit3 = 0
        first_blood_win = 0
        p1win = p2win = 0
        count = $iter_count
        histo = Array.new(250, 0)
        count.times do
            p1.reset
            p2.reset
            r = f.run
            round_long = r if r > round_long
            round_small = r if r < round_small
            round_total += r
            p1win += 1 if p1.active?
            p2win += 1 if p2.active?
            winningLetter = p1.active? ? "A" : "B"
            winningSide = p1.active? ? :sideA_hit_count : :sideB_hit_count
            losingSide = p2.active? ? :sideA_hit_count : :sideB_hit_count
            first_blood_win += 1 if winningLetter == f.stats[:first_blood]
            win_hit0 += 1 if f.stats[winningSide] == 0
            win_hit1 += 1 if f.stats[winningSide] == 1
            win_hit2 += 1 if f.stats[winningSide] == 2
            win_hit3 += 1 if f.stats[winningSide] > 2
            lose_hit1 += 1 if f.stats[losingSide] == 1
            lose_hit2 += 1 if f.stats[losingSide] == 2
            lose_hit3 += 1 if f.stats[losingSide] > 2
            death_count += 1 if p1.died or p2.died
            knock_out_count += 1 if p1.knocked_out or p2.knocked_out
            resigned_count += 1 if p1.resigned or p2.resigned
            histo[r-1] += 1 
        end
        index = 0
        tttcount = 0
        histo.each do |x|
            index = tttcount if x != 0
            tttcount += 1
        end
        [p1win, p2win, count, round_long, round_total.to_f/count.to_f, round_small, death_count, knock_out_count, resigned_count, "!", first_blood_win.to_f/count.to_f, win_hit0, win_hit1, win_hit2, win_hit3, lose_hit1, lose_hit2, lose_hit3, "!", histo[0..index] ]
    end

end


