# title:   game title
# author:  game developer, email, etc.
# desc:    short description
# site:    website link
# license: MIT License (change this to your license of choice)
# version: 0.1
# script:  ruby

module Btn
  # https://github.com/nesbox/TIC-80/wiki/key-map
  UP = 0
  DOWN = 1
  LEFT = 2
  RIGHT = 3
  A = 4
  B = 5
  X = 6
  Y = 7
end

module Color
  # PICO-8 color palette
  BLACK = 0
  DARK_BLUE = 1
  DARK_PURPLE = 2
  DARK_GREEN = 3
  BROWN = 4
  DARK_GREY = 5
  LIGHT_GREY = 6
  WHITE = 7
  RED = 8
  ORANGE = 9
  YELLOW = 10
  GREEN = 11
  BLUE = 12
  LAVENDER = 13
  PINK = 14
  LIGHT_PEACH = 15
end

# ----------------------------------------------------------------

class Coroutine < Enumerator
  attr_reader :status

  def initialize(&block)
    @status = :created
    super(&block)
  end

  def resume
    @status = :running
    self.next
  rescue StopIteration
    @status = :dead
    nil
  end

  def self.new_moving_coro(obj, target_x, target_y, speed_per_tick = 2)
    Coroutine.new do |y|
      loop do
        dx = target_x - obj.x
        dy = target_y - obj.y
        distance = Math.sqrt(dx**2 + dy**2)

        if distance < speed_per_tick
          obj.x = target_x
          obj.y = target_y
          break
        end

        angle = Math.atan2(dy, dx)
        obj.x += Math.cos(angle) * speed_per_tick
        obj.y += Math.sin(angle) * speed_per_tick
        y << true
      end
    end
  end
end

class Map
  @@pror = 534_534

  def initialize
    @potato = 34
  end

  def hehe(hehe)
    trace "hehe: #{hehe} - #{@potato} -- #{@@pror}"
  end
end

class Entity
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def update; end

  def draw; end
end

class Player < Entity
  def update
    if @moving_coro.nil?
      delta_x = -8 if btnp Btn::LEFT
      delta_x = +8 if btnp Btn::RIGHT
      delta_y = -8 if btnp Btn::UP
      delta_y = +8 if btnp Btn::DOWN

      # TODO don't allow diagonal movement

      if delta_x || delta_y
        @moving_coro = Coroutine.new_moving_coro(
          self, @x + (delta_x || 0), @y + (delta_y || 0)
        )
      end
    else
      @moving_coro.resume
      trace "End pos: (#{@x}, #{@y})" if @moving_coro.status == :dead
      @moving_coro = nil if @moving_coro.status == :dead
    end
  end

  def draw
    spr 256, @x, @y, 0
  end
end

# ----------------------------------------------------------------

$player = Player.new(8, 8)

def potato(hehe)
  print hehe
end

trace "Running with Ruby: #{RUBY_VERSION}"

eeee = Coroutine.new do |y|
  q = 100
  loop do
    y << q # yield

    q += 1

    break if q > 105
  end

  trace 'done'
end

trace "Status: #{eeee.status}"
trace "resume: #{eeee.resume} - Status: #{eeee.status}"
trace "resume: #{eeee.resume} - Status: #{eeee.status}"
trace "resume: #{eeee.resume} - Status: #{eeee.status}"
trace "resume: #{eeee.resume} - Status: #{eeee.status}"
trace "resume: #{eeee.resume} - Status: #{eeee.status}"
trace "resume: #{eeee.resume} - Status: #{eeee.status}"
trace "resume: #{eeee.resume} - Status: #{eeee.status}"
trace "resume: #{eeee.resume} - Status: #{eeee.status}"
trace "Status: #{eeee.status}"

def TIC
  cls Color::BLACK
  $player.update
  $player.draw
end

# <SPRITES>
# 000:0000aa00000000a00aaa00aa000000a000a0000000a0aa0000a0a00000000000
# </SPRITES>

# <WAVES>
# 000:00000000ffffffff00000000ffffffff
# 001:0123456789abcdeffedcba9876543210
# 002:0123456789abcdef0123456789abcdef
# </WAVES>

# <SFX>
# 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
# </SFX>

# <TRACKS>
# 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
# </TRACKS>

# <PALETTE>
# 000:0000001d2b537e2553008751ab52365f574fc2c3c7fff1e8ff004dffa300ffec2700e43629adff83769cff77a8ffccaa
# </PALETTE>
