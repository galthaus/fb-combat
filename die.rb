
@debug = false
@dice = [
  { :index => 0, :die => "d4",  :average => 2.5 },
  { :index => 1, :die => "d6",  :average => 3.5 },
  { :index => 2, :die => "d8",  :average => 4.5 },
  { :index => 3, :die => "d10", :average => 5.5 },
  { :index => 4, :die => "d12", :average => 6.5 },
  { :index => 5, :die => "d20", :average => 10.5 }
]

def max(a,b)
  a > b ? a : b
end


def largest(val)
  die = nil
  @dice.each do |d|
    return die if d[:average] > val
    die = d
  end
  die
end

def histo_init
  @dice.map { |a| 0 }
end


#
# flattest distro
# 1..N in range
#
def widest(value, free)
  ask_value = value
  histo = histo_init
  found_dice = 0
  die_count = 1
  addr = free
  if value == value.floor
    addr -= 1
    die_count += 1
  end
  value -= addr 

  start_value = value

  tv = value - 2.5 * max(0, (die_count - 1 - found_dice))
  puts "testing for = #{tv}" if @debug
  d = largest(tv)
  puts "Starting die = #{d.inspect}" if @debug
  while d
    value -= d[:average]
    found_dice += 1
    histo[d[:index]] += 1
    tv = value - 2.5 * max(0, (die_count - 1 - found_dice))
    puts "testing for = #{tv}" if @debug
    d = largest(tv)
    puts "next die = #{d.inspect}" if @debug
    puts "next value = #{value}" if @debug
    puts "next histo = #{histo.inspect}" if @debug
    if (value > 0 and d.nil?) or (value == 0 and d.nil? and die_count != found_dice)
      puts "Resetting adding dice: " if @debug
      found_dice = 0
      die_count += 2
      addr -= 2
      start_value = start_value + 2
      value = start_value
      histo = histo_init
      d = largest(value - 2.5 * (die_count - 1 - found_dice))
    end
  end
  value += addr
  print_die(histo, value, ask_value)
end

def print_die(histo, value, ask_value)
  sum = 0
  s = []
  histo.each_with_index do |v, i|
    next if v == 0
    s << "#{v}#{@dice[i][:die]}"
    sum = sum + @dice[i][:average] * v
  end

  other = ""
  unless value == 0
    sign = value < 0 ? "-" : "+"
    other = "#{sign}#{value.abs.to_i}"
  end

  sum = sum + value

  ans = "#{s.join('+')}#{other}"
  puts "BUSTED: #{ans} = #{sum} (#{ask_value})" if (sum != ask_value)
  ans
end


min=3.5
count=100

count.times do |i|
  value = min+i*0.5

  val50 = (value * 0.5).floor
  val25 = (value * 0.25).floor

  test = value == value.floor ? 5.0 : 2.5

  val50 = (value - test).floor if (value - val50 < test)
  val25 = (value - test).floor if (value - val25 < test)
  val50 = 0 if val50 < 0
  val25 = 0 if val25 < 0

  puts "#{value} #{val50} #{val25}" if @debug

  wide = widest(value, 0)
  middle = widest(value, val25)
  narrow = widest(value, val50)

  puts "#{value},#{narrow},#{middle},#{wide}"
end



