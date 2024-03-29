(set package.path (.. "./?.lua;../?.lua;" package.path))

;; !! change when building for release
(set _G.is-debug true)
;; (set _G.is-debug false)

;; whether we're running in a real Love2d process or in REPL mode
(set _G.is-love (not= nil _G.love))

(local fennel (require :lib.fennel))
(set _G.lume (require :lib.lume))
(set _G.pp (fn [x]
             (-> x
                 fennel.view
                 print)))

;; This module contains non-game-specific bits and mode-changing logic.
(if _G.is-love
    (tset _G :repl (require :lib.stdio)))

(local love (require :love-api))
(local log (require :logger))

(local canvas (let [(w h) (love.window.getMode)]
                (love.graphics.newCanvas w h)))

(local controller (require :controller))

;; (local sound (require "sound"))

(var scale 1)
(var mode (require :mode.intro))

(fn set-mode [mode-name ...]
  (log.debug "switching to mode name:" mode-name)
  (set mode (require (.. :mode. mode-name)))
  (when mode.activate
    (mode.activate ...)))

(fn safely [f]
  (if _G.is-love
      (xpcall f #(set-mode :error-mode mode.name $ (fennel.traceback)))
      (xpcall f)))

(fn love.load [args]
  (canvas:setFilter :nearest :nearest)
  (when (not= :web (. args 1))
    (_G.repl.start)))

;; (sound.play :temple)

(set _G.debug-txt "")

(fn love.draw []
  (love.graphics.setCanvas canvas)
  (love.graphics.clear)
  (love.graphics.setColor 1 1 1)
  (safely mode.draw)
  (when (controller.is-key-down :y)
    (love.graphics.print _G.debug-txt 11 305))
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1)
  (love.graphics.draw canvas 0 0 0 scale scale))

(fn love.update [dt]
  (when mode.update
    (safely #(mode.update dt set-mode)))
  (when (controller.is-key-just-pressed :escape)
    (love.event.quit 0))
  (controller.remove-just-pressed-keys))

(fn love.keypressed [key scancode isrepeat]
  (controller.register-keypress key)
  ;; LIVE RELOADING
  ;; This is done by updating all "entries" of the current's mode table
  (when (= :f5 key)
      (let [name (.. :mode. mode.name)]
        (let [old (require name)
              _ (tset package.loaded name nil)
              new (require name)]
          (when (= (type new) :table)
            (each [k v (pairs new)]
              (tset old k v))
            (each [k v (pairs old)]
              (when (not (. new k))
                (tset old k nil)))
            (tset package.loaded name old))))))
