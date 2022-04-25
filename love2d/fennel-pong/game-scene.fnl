(local utils (require :utils))
(local controller (require :controller))

(local player-height 70)
(local player-width 20)

(var ball nil)
(var player1 nil)
(var player2 nil)
(var game-info nil)

;; update stuff

(fn update-player [dt player up-key down-key]
  (let [dt-speed (* game-info.speed dt)]
    (if (controller.is-key-down up-key)
        (set player.pos.y (- player.pos.y dt-speed)))
    (if (controller.is-key-down down-key)
        (set player.pos.y (+ player.pos.y dt-speed)))))

(fn update-ball [])

;; Draw stuff

(fn draw-hud []
  (lg.print (.. "P1: " player1.score) 10 10)
  (let [p2-score-txt (.. "P2: " player2.score)
        p2-score-x (- (lg.getWidth) (utils.get-text-width-px p2-score-txt))]
    (lg.print p2-score-txt p2-score-x 10)
    ;; TODO draw rectangle under scores to prevent player overlapping (maybe slightly transparent?)
    ))

(fn draw-player [player]
  (lg.rectangle :fill player.pos.x player.pos.y player-width player-height))

(fn draw-ball [])

(fn activate []
  (set ball {:pos {:x 0 :y 0} :vel {:x 0 :y 0}})
  (set player1 {:pos {:x 20 :y 10} :score 0})
  (set player2 {:pos {:x 680 :y 10} :score 0})
  (set game-info {:speed 200 :played-games 0}))

;; when module is reloaded we need to re-activate. Don't know if there's
;; a better way to do it. Maybe with globals?
(activate)

{: activate
 :draw (fn draw []
         (draw-hud)
         (draw-player player1)
         (draw-player player2)
         (draw-ball))
 :update (fn update [dt set-mode]
           (update-player dt player1 :w :s)
           (update-player dt player2 :up :down)
           (update-ball))}
