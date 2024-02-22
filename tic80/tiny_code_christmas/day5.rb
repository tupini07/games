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

      # 16 colors in pallet divided by 2pi, so we get enough "wedges" to show each color
      # (we want each to have a uniform size)
      mm = 16 / (2 * Math::PI)
      angle = (Math.atan2(y, x) + Math::PI) * mm * 6

      # the bigger the number on the left the nearer the center of the tunnel is to the screen
      dist = 1400 / Math.sqrt(x * x + y * y + 1)

      c = if dist > 60
            # show a plasma like pattern in the center circle
            m = 1.5
            t =  time / 10_000
            16 * (Math.sin(x / m + t) + Math.cos(y / m + t)) & 7
          elsif dist < 60 and dist > 57
            # dark-blue outline around the center pattern, so things don't look so messy
            8
          else
            # otherwise, show the expected tunnel thing

            # & with 11 is to get only blue and red colors in pallet
            (time / 500 + angle ^ time / 300 + dist) & 11
          end

      # draw pixel, centered on the "middle" of the screen, not on the origin which in tic80 is on the top left
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
