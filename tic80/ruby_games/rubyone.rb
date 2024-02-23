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
  def initialize(x, y)
    @x = x
    @y = y
  end

  def update; end

  def draw; end
end

class Player < Entity
  def update
    @x -= 1 if btn Btn::LEFT
    @x += 1 if btn Btn::RIGHT
    @y -= 1 if btn Btn::UP
    @y += 1 if btn Btn::DOWN
  end

  def draw
    spr 256, @x, @y, 14, 3, 0, 0, 2, 2
  end
end

# ----------------------------------------------------------------

$player = Player.new(96, 24)

def potato(hehe)
  print hehe
end

trace "Running with Ruby: #{RUBY_VERSION}"

# fiber = Fiber.new do
#   a = 1
#   loop do
#     potato 'hehe'
#     Fiber.yield a
#     a += 1
#   end
# end

# trace fiber.resume
# trace fiber.resume
# trace fiber.resume
# trace fiber.resume

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
