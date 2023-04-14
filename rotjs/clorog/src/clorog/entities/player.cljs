(ns clorog.entities.player
  (:require [clorog.rotjs :as rotjs]
            [clorog.logger :as logger]))

(defn- update-player-pos-in-state
  "Returns a new state with the position of the player updated if
   necessary."
  [state]
  (let [key (:last-input state)
        player (:player state)
        posx (:posx player)
        posy (:posy player)
        targetx (condp = key
                  "a" (dec posx)
                  "d" (inc posx)
                  posx)
        targety (condp = key
                  "w" (dec posy)
                  "s" (inc posy)
                  posy)
        game-map (:map state)
        thing-at-target (get game-map [targetx targety])]

    (logger/log "update-player-pos-in-state: Thing at target:"
                thing-at-target
                (= \space (.charAt (:char thing-at-target) 0))
                (int (.charAt (:char thing-at-target) 0))
                (type (:char thing-at-target)))

    (if (or (nil? thing-at-target)
            (not (:walkable thing-at-target)))

      ;; return unaltered state if we're trying to move outside of the map or on
      ;; a tile that is not empty
      state

      ;; otherwise update player position in state
      (-> state
          (assoc-in [:player :posx] targetx)
          (assoc-in [:player :posy] targety)))))


(defn pl-update [state]
  (-> state
      update-player-pos-in-state))

(defn pl-draw [state]
  (let [playerx (-> state :player :posx)
        playery (-> state :player :posy)]
    (rotjs/draw playerx playery "#")))