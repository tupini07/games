(ns clorog.web-core)

(defn browser-loop []
  (println "Do something")
  (.requestAnimationFrame js/window browser-loop))

(defn init []
  (.log js/console "yolo")
  ;; start browser loop
  (browser-loop)
  (js/setTimeout #(.log js/console "he123321") 1000))

