(ns rorisboard.app 
  (:require [pixi.js :as pixi]))

(defn init []
  (println "Initializing")
  (def app (pixi/Application.))
  (js/document.body.appendChild (.-view app))
  (println "Hello World"))
