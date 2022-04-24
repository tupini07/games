(local controller (require :controller))
(var counter 0)

{:draw (fn draw []
         (love.graphics.print "Welcome to the intro scene!" 10 10)
         (love.graphics.print "Press X to start :)" 10 50)
         (love.graphics.print "Or press Z to restart counter" 10 75)
         (let [s-width (love.graphics.getWidth)
               s-height (love.graphics.getHeight)
               counter-str (.. "Counter: " counter)
               counter-width (* 8 (counter-str:len))
               counter-x (- s-width counter-width)]
           (love.graphics.print counter-str counter-x 10)
           (love.graphics.setColor 0 1 0)
           (love.graphics.line counter-x 26 (+ counter-x (- counter-width 16))
                               26)))
 :update (fn update [dt set-mode]
           (set counter (+ counter 1))
           ;; zero counter if pressed z
           (if (controller.is-key-just-pressed :z)
               (set counter 0))
           (if (controller.is-key-just-pressed :x)
               (set-mode :game-scene)))}
