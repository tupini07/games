# title:   game title
# author:  game developer, email, etc.
# desc:    short description
# site:    website link
# license: MIT License (change this to your license of choice)
# version: 0.1
# script:  ruby

def TIC
  for y in -68..67 do
    for x in -120..119 do
      # 16 colors in pallet divided by 2pi
      mm = 16 / (2 * Math::PI)
      angle = (Math.atan2(y, x) + Math::PI) * mm

      dist = time / 10 / Math.sqrt(x * x + y * y + 1)

      c = angle + dist
      pix(120 + x, 68 + y, c)
    end
  end
end

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
# 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
# </PALETTE>
