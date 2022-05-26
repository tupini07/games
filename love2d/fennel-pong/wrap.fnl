(tset package :path (.. "./?.lua;../?.lua;" package.path))


;; set love2d locals as mocks if we're not running inside a love2d env
;; e.g. when doing interactive development with fennel repl
(require "love2d-fnl-mock")

(tset _G :pp (fn [x]
               (let [fennel (require "lib.fennel")]
                 (-> x
                     fennel.view
                     print))))

(tset _G :lume (require "lib.lume"))


;; This module contains non-game-specific bits and mode-changing logic.
(if _G.is-love
    (tset _G :repl (require "lib.stdio")))

(local canvas (let [(w h) (_G.love.window.getMode)]
                (_G.love.graphics.newCanvas w h)))
(local controller (require :controller))

;; (local sound (require "sound"))

(var scale 1)
(var mode (require :mode.intro))

(fn set-mode [mode-name ...]
  (set mode (require (.. "mode." mode-name)))
  (when mode.activate
    (mode.activate ...)))

(fn safely [f]
   (if _G.is-love
    (xpcall f #(set-mode :error-mode mode.name $ (fennel.traceback)))
    (xpcall f)))

(fn love.load [args]
  (canvas:setFilter "nearest" "nearest")
  (when (~= :web (. args 1)) (_G.repl.start)))
  ;; (sound.play :temple)
  

(var debug-txt "")
(fn love.draw []
  (_G.love.graphics.setCanvas canvas)
  (_G.love.graphics.clear)
  (_G.love.graphics.setColor 1 1 1)
  (safely mode.draw)
  (_G.love.graphics.print debug-txt 11 305)
  (_G.love.graphics.setCanvas)
  (_G.love.graphics.setColor 1 1 1)
  (_G.love.graphics.draw canvas 0 0 0 scale scale))

(fn love.update [dt]
  (when mode.update
    (safely #(mode.update dt set-mode)))

  (if (controller.is-key-just-pressed "y")
      (set debug-txt "pottt"))

  (controller.remove-just-pressed-keys))


(fn love.keypressed [key scancode isrepeat]
  (controller.register-keypress key)
  ;; LIVE RELOADING
  (when (= "f5" key)
    (let [name (.. "mode." mode.name)]
      (let [old (require name)
            _ (tset package.loaded name nil)
            new (require name)]
        (when (= (type new) :table)
          (each [k v (pairs new)]
            (tset old k v))
          (each [k v (pairs old)]
            (when (not (. new k))
              (tset old k nil)))
          (tset package.loaded name old)))))

  (when (= "escape" key)
    (_G.love.event.quit)))
  

;; (fn love.keypressed [key]
;;   (if (and (= key "f11") (= scale 2))
;;       (let [(dw dh) (love.window.getDesktopDimensions)]
;;         (love.window.setMode dw dh {:fullscreen true :fullscreentype :desktop})
;;         (set scale (/ dh 225)))

;;       (= key "f11")
;;       (do
;;         (set scale 2)
;;         (love.window.setMode (* 720 scale) (* 450 scale)))

;;       (and
;;        (love.keyboard.isDown "lctrl" "rctrl" "capslock")
;;        (= key "q"))
;;       (love.event.quit)

;;       ;; (= key "f5") (set-mode :win)

;;       (love.keyboard.isDown "m")
;;       ;; (sound.toggle)

;;       :else
;;       (mode.keypressed key set-mode)))
