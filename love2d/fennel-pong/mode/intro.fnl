(import-macros um :utils-macros)
(local controller (require :controller))
(local love (require :love-api))

(var counter 0)

(local exports {:name :intro})

(fn exports.draw []
  (love.graphics.print "Welcoaame to the intro scene!" 10 10)
  (love.graphics.print "Press X to start :)" 10 50)
  (love.graphics.print "Or press Z to restart counter" 10 75)
  (let [s-width (love.graphics.getWidth)
        s-height (love.graphics.getHeight)
        counter-str (.. "Counter: " counter)
        counter-width (* 8 (counter-str:len))
        counter-x (- s-width counter-width)]
    (love.graphics.print counter-str counter-x 10)
    (um.set-color-hex-rgb :00ff00)
    (love.graphics.line counter-x 26 (+ counter-x (- counter-width 16)) 26)))

(fn exports.update [dt set-mode]
  (set counter (+ counter 1))
  ;; zero counter if pressed z
  (if (controller.is-key-just-pressed :z)
      (set counter 0))
  (if (controller.is-key-just-pressed :x)
      (set-mode :game)))

exports
