(ns clorog.level-manager
  (:require [clorog.game-map :as game-map]
            [clorog.logger :as logger]
            [clorog.rexpaint :as rexpaint]
            [clorog.utils :as utils]))

(defonce current-level (atom []))

(defn- dummy-level []
  (let [all-grid-positions (for [x (range 10 20)
                                 y (range 10 20)]
                             [x y])]
    (vec (map #(hash-map :row (first %)
                         :col (second %)
                         :char \#
                         :color "red")
              all-grid-positions))))


(defn load-level [level-num callback]
  (logger/log "Loading level" level-num)

  (utils/get-raw-text-from-asset
   (str "levels/" level-num ".xml")
   (fn [text]
     (logger/log "Got level '" level-num "' parsing.. Len " (count text))

     ;; parse rexpaint xml into CLJ datastructure
     (let [transformed (->> (rexpaint/parse-rexpaint text)
                            game-map/transform-tile-list-to-game-map)]

       ;; invoke original callback
       (callback transformed)

       ;; and set current-map atom
       (reset! current-level transformed))

     ;; once level is loaded, trigger a redraw to ensure all is good
     (->> (js/Event. "custom-request-redraw")
          (.dispatchEvent js/window))))

  (condp = level-num
    "dummy" (dummy-level)
    0 (dummy-level)
    :else (throw (js/Error. "Unknown level"))))