(local controller (require :controller))

(var ball nil)
(var player1 nil)
(var player2 nil)
(var game-info nil)

(fn update-player [dt player up-key down-key])
(fn update-ball [])

(fn draw-hud [])
(fn draw-player [player])
(fn draw-ball [])

(fn activate []
  (set ball {:pos {:x 0 :y 0} :vel {:x 0 :y 0}})
  (set player1 {:pos {:x 0 :y 0} :score 0})
  (set player2 {:pos {:x 0 :y 0} :score 0})
  (set game-info {:ball-speed 1 :played-games 0}))

;; when module is reloaded we need to re-activate. Don't know if there's
;; a better way to do it. Maybe with globals?
(activate)

{: activate
 :draw (fn draw []
         (love.graphics.print "Welcome to the game scene!" 10 10)
         (draw-hud)
         (draw-player player1)
         (draw-player player2)
         (draw-ball))
 :update (fn update [dt set-mode]
           (update-player dt player1 :w :s)
           (update-player dt player2 :up :down)
           (update-ball))}
