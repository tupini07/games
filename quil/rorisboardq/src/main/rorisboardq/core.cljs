(ns rorisboardq.core
  (:require [quil.core :as q :include-macros true]
            [quil.middleware :as m]))



(defn setup []
  (println "Setting up sketch...")
  ; Set frame rate to 30 frames per second.
  (q/frame-rate 30)
  ; Set color mode to HSB (HSV) instead of default RGB.
  (q/color-mode :rgb)
  ; setup function returns initial state. It contains
  ; circle color and position.
  {:inputs 0})

(defn- update-input [state]
  (if-let [_key (and (q/key-pressed?)
                     (q/key-as-keyword))]
    (update state :inputs inc)
    state))

(defn update-state [state]
  (-> state
      (update-input)))

(defn draw-state [state]
  ; Clear the sketch by filling it with light-grey color.
  (q/background 240)
  ; Set circle color.
  (q/fill (:color state) 255 255)

  (q/ellipse 0 0 100 100))
  ; Calculate x and y coordinates of the circle.
  ;; (let [angle (:angle state)
  ;;       x (* 150 (q/cos angle))
  ;;       y (* 150 (q/sin angle))]
  ;;   ; Move origin point to the center of the sketch.
  ;;   (q/with-translation [(/ (q/width) 2)
  ;;                        (/ (q/height) 2)]
  ;;     ; Draw the circle.
  ;;     (q/ellipse x y 100 100))))



(defn init []
  (println "Hello world!")
  (q/defsketch rorisboard
    :host "rorisboard"
    :size [700 550]

    ; setup function called only once, during sketch initialization.
    :setup setup
    ; update-state is called on each iteration before draw-state.
    :update update-state
    :draw draw-state
    ; This sketch uses functional-mode middleware.
    ; Check quil wiki for more info about middlewares and particularly
    ; fun-mode.
    :middleware [m/fun-mode]))
