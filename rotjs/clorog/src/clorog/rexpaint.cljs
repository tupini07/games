(ns clorog.rexpaint)

(defrecord RexGlyph [row col char fg bg])

(defn parse-rexpaint 
  "Given an XML string exported by RexPaint it will return a list of maps 
   of the record type [[RexGlyph]]."
  [rex-xml]
  (let [parser (js/DOMParser.)
        doc (.parseFromString parser rex-xml "text/xml")
        get-inner-fn (fn [elem tag-name]
                       (-> (.getElementsByTagName elem tag-name)
                           (aget 0)
                           (.-innerHTML)))
        ;; tells us the size of the image, not used for now.
        ; width  (get-inner-fn doc "width")
        ; height (get-inner-fn doc "height")
        extract-cells-fn (fn [row] (.getElementsByTagName row "cell"))
        extract-cell-properties (fn [cell]
                                  {:char (char (-> (get-inner-fn cell "ascii")
                                                   (js/parseInt)))
                                   :fg (get-inner-fn cell "fgd")
                                   :bg (get-inner-fn cell "bkg")})

        rows (.getElementsByTagName doc "row")]
    (->> rows
         ;; for each row extract each of the cells as a column and generate a
         ;; a list of RexGlyphs
         (map-indexed (fn [row-i row]
                        (let [cells (extract-cells-fn row)]
                          (->> cells
                               ;; for each cell in the row extract a map of
                               ;; record [[RexGlyph]]
                               (map-indexed (fn [cell-i cell]
                                              (let [cell-properties (extract-cell-properties cell)]
                                                (map->RexGlyph (conj {:row row-i :col cell-i}
                                                                     cell-properties))))))))) 
         ;; here we have a list of lists, one for each row, so we flatten them
         ;; to end up with a `flat` list
         flatten)))


(comment
  ;; download rexpaint xml and try parsing
  (do
    (def a (atom nil))
    (-> (js/fetch "/assets/sfewr.xml")
        (.then (fn [response]
                 (.text response)))
        (.then #(reset! a (parse-rexpaint %))))))

