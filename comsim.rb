
require 'yaml'
require 'person'
require 'fight'
require 'utils'
require 'global'

class ComSim

    def initialize(p1, p2, s1v = nil, s2v = nil)
        @person1 = p1
        @person2 = p2
        @s1variants = s1v
        @s2variants = s2v
    end

    def run_combos
        if @s1variants
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
        else
            s1people = [[:base]]
        end
        if @s2variants
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
        else
            s2people = [[:base]]
        end

        puts "Running #{s1people.size * s2people.size} Combos: #{s1people.size} X #{s2people.size}"
        s1people.each do |s1v|
            @person1.apply_variants(s1v)
            s2people.each do |s2v|
                @person2.apply_variants(s2v)
                puts "Comparing #{s1v.inspect} to #{s2v.inspect}"
                run_fight(@person1, @person2)
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
        puts "W: (#{p1win}/#{p2win}/#{count}) " +
             "R: (#{round_long}/#{round_total.to_f/count.to_f}/#{round_small}) " +
             "E: (D: #{death_count}/R: #{resigned_count}/K: #{knock_out_count})"
    end

end


