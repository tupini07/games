;; check interpreter name to see if we're love in a love env or not
(tset _G :is-love (-> arg
                      (. -2)
                      (string.find "love")
                      (~= nil)))

;; load love2d definitions if we're not in a love process
(when (not _G.is-love)
  ;; (let [current-dir (io.popen "cd")
  ;;       dir-path (current-dir:read "*l")]
  ;;   (local io (require :io))
  ;;   (tset package :path (.. dir-path "/?.lua;" package.path))
  ;;   )

  ;; when we're running in a love2d process, _G.love is aleady set
  (tset _G :love (let [lapi (require :lib.love-api.love_api)
                       dummy-fn (fn [] {})]
                   (collect [_ module (ipairs lapi.modules)]
                     (if (~= module.name nil)
                         (values module.name (collect [_ fn-desc (ipairs module.functions)]
                                               (values fn-desc.name dummy-fn)))))))
  )
