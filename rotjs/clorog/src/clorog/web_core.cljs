(ns clorog.web-core
  (:require [clorog.entities.player :as player]
            [clorog.level-manager :as level-manager]
            [clorog.logger :as logger]
            [clorog.rotjs :as rotjs]
            [clorog.game-map :as game-map]))

(def state (atom {:player {:posx 0 :posy 0}
                  :map {}
                  :last-input nil}))

(defn- update-everything [input-key]
  (logger/log "update-everything: pressed key was" input-key)

  (swap! state #(assoc % :last-input input-key))

  (logger/log "state:" (-> @state
                           ;; remove map to prevent spam in log
                           (assoc :map "[...]")))

  (when (not (nil? input-key))
    (reset! state (-> @state
                      player/pl-update))))

(defn- draw-everything []
  (logger/log "draw-everything")
  (rotjs/clear)

  (rotjs/draw-text 1 1 "Welcome!" "white")

  ;; draw map
  (game-map/draw-game-map @state)

  ;; entities
  (-> @state
      player/pl-draw))

(defn on-keydown
  "Every time the user presses a key we want to clear the screen, 
   update all entities, and then re-draw everything"
  [event]
  ;; cancel JS event
  (.preventDefault event)

  ;; ignore repeat events
  (when (not event.repeat)
    (logger/log "on-keydown: running for key" event.key)

    (update-everything event.key)
    (draw-everything))
  ;; (.requestAnimationFrame js/window on-keypress)
  )


(defn init []
  (logger/set-is-release false)

  (logger/log "Appending display")

  (-> (js/document.getElementById "canvas-holder")
      (.appendChild (.getContainer rotjs/DISPLAY)))

  (level-manager/load-level
   0
   (fn [new-map]
     (swap! state (fn [old-state]
                    (assoc old-state :map new-map)))))

  ;; start browser loop
  (.addEventListener js/window "keydown" on-keydown)
  (.addEventListener js/window "custom-request-redraw" draw-everything))

