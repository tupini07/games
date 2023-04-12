(ns clorog.level-manager
  (:require [clojure.core.async :refer [go]]
            [clorog.rexpaint :as rexpaint]
            [clorog.utils :as utils]))

(defn- dummy-level []
  (let [all-grid-positions (for [x (range 10 20)
                                 y (range 10 20)]
                             [x y])]
    (vec (map #(vector [(first %)
                        (second %)]
                       {:char \#
                        :color "red"})
              all-grid-positions))))



(defn load-level [level-num]
  (println "Loading level" level-num)

  (utils/get-raw-text-from-asset
   "sfewr.xml"
   (fn [text]
     (println "Got level, parsing.. Len " (count text))
     (rexpaint/parse-rexpaint text)))

  (condp = level-num
    "dummy" (dummy-level)
    0 (dummy-level)
    :else (throw (js/Error. "Unknown level"))))