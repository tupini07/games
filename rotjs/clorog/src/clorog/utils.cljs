(ns clorog.utils
  (:require [cljs.core.async.interop :refer [<p!]]
            [clojure.core.async :refer [go]]))

(defn get-raw-text-from-asset
  "Loads a text file from the assets folder and calls the callback with the text"
  [path callback]
  (go
    (let [response (<p! (js/fetch (str "assets/" path)))
          text (<p! (.text response))]
      (callback text))))