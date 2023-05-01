(ns rorisboard.app
  (:require cljsjs.pixi))

(defn update-state [state delta])

(defn draw-state [state app])

(defn tick [app state timestamp-previous timestamp-now]
  (let [delta (/ (- timestamp-now timestamp-previous) 1000)]
    (println "delta" delta)

    (update-state state delta)
    (draw-state state app)

    ;; queue new update 
    (js/requestAnimationFrame
     (partial tick
              app
              state
              timestamp-now))))

(defn init []

  (println "Initializing")
  (def papp (js/PIXI.Application. (clj->js {:resizeTo js/window
                                            :autoResize true})))
  (js/document.body.appendChild (.-view papp))

  (-> papp
      .-stage
      (.addChild (doto (js/PIXI.Graphics.)
                   (.beginFill 0xFFFFFF)
                   (.drawRect 0 0 100 100)
                   (.endFill))))

  ;; start ticks
  (tick papp
        {}
        0
        (js/performance.now))
  ;; (def xx (js/PIXI.Texture.))
  )

