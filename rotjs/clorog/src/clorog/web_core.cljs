(ns clorog.web-core
  (:require [clorog.level-manager :as level-manager]
            [rot-js :as ROT]))

(defonce display (ROT/Display. (clj->js {:width 70
                                         :height 44
                                         :bg "purple"
                                         :fontFamily "droid sans mono, monospace"
                                         :forceSquareRatio true
                                         :tileColorize true})))

(defonce level (level-manager/load-level 0))


(defn browser-loop []
  (.clear display)

  (.drawText display 1 1 "Welcome!" "white")

  (doseq [[pos data] level]
    (let [[x y] pos
          {:keys [char color]} data]

      (.draw display x y char color)))

  (.requestAnimationFrame js/window browser-loop))


(defn init []
  (println "Appending display")

  (js/document.body.appendChild (.getContainer display))

  ;; start browser loop
  (browser-loop))

