
require 'yaml'
require 'person'
require 'fight'
require 'utils'
require 'global'

class ComSim

    def initialize(p1, p2, s1v = nil, s2v = nil)
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
        @person1.apply_variants(s1const)
        @person2.apply_variants(s2const)
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
        header += ",W1,W2,Wcount,LR,AR,SR,D,U,R"
        puts header
        s1people.each do |s1v|
            s1line = ""
            if s1keys
                s1keys.each do |key|
                    s1v.each do |a|
                        a.each do |k,v|
                            s1line += "," if s1line != ""
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
                                s2line += "," if s2line != ""
                                s2line += "#{v}" if k == key
                            end
                        end
                    end
                end
                @person2.apply_variants(s2v)
                data = run_fight(@person1, @person2)
                answer = ""
                answer += s1line if s1line != ""
                answer += s2line if s2line != ""
                answer += data.join(",")
                puts answer
            end
        end
    end

    def run_fight(p1, p2)
        f = Fight.new([p1], [p2])

        p p1 if $verbose
        p p2 if $verbose

        round_small = 100000
        round_long = 0
        round_total = 0
        death_count = knock_out_count = resigned_count = 0
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
            death_count += 1 if p1.died or p2.died
            knock_out_count += 1 if p1.knocked_out or p2.knocked_out
            resigned_count += 1 if p1.resigned or p2.resigned
            histo[r-1] += 1 
        end
        index = 0
        count = 0
        histo.each do |x|
            index = count if x != 0
            count += 1
        end
        [p1win, p2win, count, round_long, round_total.to_f/count.to_f, round_small, death_count, knock_out_count, resigned_count, histo[0..index] ]
    end

end


