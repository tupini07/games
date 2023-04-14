(ns clorog.rotjs
  (:require [rot-js :as ROT]))

(defonce DISPLAY (ROT/Display. (clj->js {:width 60
                                         :height 60
                                         :bg "black"
                                         :fontFamily "droid sans mono, monospace"
                                         :forceSquareRatio true
                                         :tileColorize true})))

(defn draw
  ([x y char fg bg] (.draw DISPLAY x y char fg bg))
  ([x y char fg] (draw x y char fg nil))
  ([x y char] (draw x y char nil nil)))

(defn draw-text
  ([x y text fg bg] (.drawText DISPLAY x y text fg bg))
  ([x y text fg] (draw-text x y text fg nil))
  ([x y text] (draw-text x y text nil nil)))

(defn clear
  ([] (.clear DISPLAY))
  ([color] (.clear DISPLAY color)))