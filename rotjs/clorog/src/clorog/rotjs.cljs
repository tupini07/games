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
  "Draws text on the screen. If wrap-width is nil, it will wrap
   to the screen width."
  ([x y text wrap-width] (.drawText DISPLAY x y text wrap-width))
  ([x y text] (draw-text x y text nil)))

(defn clear
  ([] (.clear DISPLAY))
  ([color] (.clear DISPLAY color)))