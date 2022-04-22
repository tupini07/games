(local controller (require :controller))

(var ball {})
(var player1 {})
(var player2 {})
(var game-info {})

(fn update-player [dt player up-key down-key])
(fn update-ball [])

(fn draw-hud [])
(fn draw-player [player])
(fn draw-ball [])

{
 :activate
 (fn activate []
   (set ball {:pos {:x 0 :y 0}
              :vel {:x 0 :y 0}})
   (set player1 {:pos {:x 0 :y 0}
                 :score 0})
   (set player2 {:pos {:x 0 :y 0}
                 :score 0})
   (set game-info {:ball-speed 1
                   :played-games 0}))

 :draw
 (fn draw []
   (love.graphics.print "Welcome to the game scene!" 10 10)
   (draw-hud)

   (draw-player player1)
   (draw-player player2)
   (draw-ball))


 :update
 (fn update [dt set-mode]
   (update-player dt player1 "w" "s")
   (update-player dt player2 "up" "down")
   (update-ball))


}
