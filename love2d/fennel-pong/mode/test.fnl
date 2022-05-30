(var counter 0)

{:name :test
 :draw (fn draw []
         (love.graphics.print "Testss ♌ scene:" 0 0)
         (love.graphics.print "Funnyst scene:" 30 100)
         (love.graphics.print (.. "Counter: " counter) 10 30))
 :update (fn update [dt set-mode]
           (set counter (+ counter 1)))}
