(ns clorog.rexpaint)


(defn parse-rexpaint [rex-xml]
  (let [parser (js/DOMParser.)
        doc (.parseFromString parser rex-xml "text/xml")
        get-inner-fn (fn [elem tag-name]
                       (-> (.getElementsByTagName elem tag-name)
                           (aget 0)
                           (.-innerHTML)))
        width  (get-inner-fn doc "width")
        height (get-inner-fn doc "height")
        extract-cells-fn (fn [row] (.getElementsByTagName row "cell"))
        extract-cell-properties (fn [cell]
                                  {:char (char (-> (get-inner-fn cell "ascii")
                                                   (js/parseInt)))
                                   :fg (get-inner-fn cell "fgd")
                                   :bg (get-inner-fn cell "bkg")})

        rows (.getElementsByTagName doc "row")]
    (println "Parsed width" width height)
    (->> rows
         (map-indexed (fn [row-i row]
                        (let [cells (extract-cells-fn row)]
                          (->> cells
                               (map-indexed (fn [cell-i cell]
                                              (let [cell-properties (extract-cell-properties cell)]
                                                (conj {:row row-i :col cell-i}
                                                      cell-properties))))))))
         flatten)))


(comment
  ;; download rexpaint xml and try parsing
  (def a (atom nil))
  (-> (js/fetch "/assets/sfewr.xml")
      (.then (fn [response]
               (.text response)))
      (.then #(reset! a (parse-rexpaint %)))))

