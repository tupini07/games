(ns clorog.game-map
  (:require [clorog.rotjs :as rotjs]))

(defn- is-tile-walkable? [glyph]
  (condp = glyph
    (char " ") true
    \. true
    false))

(defn- get-entity-type-for-glyph [glyph]
  (condp = glyph
    \g :goblin
    \G :goblin-big
    (char " ") :empty
    :unknown))

(defn transform-tile-list-to-game-map
  "Aggregate all cell items into a single map"
  [rex-cells]
  (->> rex-cells
       (reduce (fn [acc cell]
                 (let [cellx (:col cell)
                       celly (:row cell)
                       glyph (:char cell)

                       ;; value will be the whole cell map WITHOUT col and
                       ;; row since those are already part of the "key"
                       cell-payload (dissoc cell [:col :row])

                       ;; add entity type
                       cell-payload (assoc cell-payload
                                           :type
                                           (get-entity-type-for-glyph glyph))

                       ;; add whether the tile is walkable or not
                       cell-payload (assoc cell-payload
                                           :walkable
                                           (is-tile-walkable? glyph))]

                   (assoc acc [cellx celly] cell-payload)))
               {})))

#_(transform-tile-list-to-map [{:col 0 :row 0 :other 2}
                               {:col 1 :row 1 :other 2}])

(defn draw-game-map [state]
  (let [gamemap (:map state)]
    (doseq [[[x y] {:keys [char fg bg]}] gamemap]
      (rotjs/draw x y char fg bg))))


