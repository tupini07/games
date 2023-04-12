(ns clorog.rexpaint)

(defn parse-rexpaint [rex-xml]
  (let [parser (js/DOMParser.)
        doc (.parseFromString parser rex-xml "text/xml")
        get-inner-fn (fn [tag-name]
                       (->> (.getElementsByTagName doc tag-name)
                            (map #(.-innerHTML %))))
        width (first (get-inner-fn "width"))
        height (first (get-inner-fn "height"))]
    (println "Parsed width" width height))

  1)
