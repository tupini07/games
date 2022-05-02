(import-macros um :utils-macros)
(local controller (require :controller))
(var counter 0)

{
  :name "intro"
    :draw (fn draw []
         (_G.love.graphics.print "Welcoaame to the intro scene!" 10 10)
         (_G.love.graphics.print "Press X to start :)" 10 50)
         (_G.love.graphics.print "Or press Z to restart counter" 10 75)
         (let [s-width (_G.love.graphics.getWidth)
               s-height (_G.love.graphics.getHeight)
               counter-str (.. "Counter: " counter)
               counter-width (* 8 (counter-str:len))
               counter-x (- s-width counter-width)]
           (_G.love.graphics.print counter-str counter-x 10)
           (um.set-color-hex-rgb "00ff00")
           (_G.love.graphics.line counter-x 26 (+ counter-x (- counter-width 16))
                               26)))
 :update (fn update [dt set-mode]
           (set counter (+ counter 1))
           ;; zero counter if pressed z
           (if (controller.is-key-just-pressed :z)
               (set counter 0))
           (if (controller.is-key-just-pressed :x)
               (set-mode :game)))}