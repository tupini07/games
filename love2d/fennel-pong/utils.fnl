{
 :table-contains-value
 (fn [tbl val]
   (each [_ tval (pairs tbl)]
     (when (= val tval)
       (lua "return true"))))
}
