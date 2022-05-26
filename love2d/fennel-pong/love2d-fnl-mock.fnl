;; check interpreter name to see if we're love in a love env or not
(tset _G :is-love (-> arg
                      (. -2)
                      (string.find :love)
                      (not= nil)))

(var testy nil)

;; load love2d definitions if we're not in a love process
(when (not _G.is-love)
  ;; (let [current-dir (io.popen "cd")
  ;;       dir-path (current-dir:read "*l")]
  ;;   (local io (require :io))
  ;;   (tset package :path (.. dir-path "/?.lua;" package.path))
  ;;   )
  ;; when we're running in a love2d process, _G.love is aleady set
  (tset _G :love
        (let [lapi (require :lib.love-api.love_api)
              dummy-fn (fn []
                         "Dummy function. See official doc at https://love2d.org/wiki/love"
                         {})]
          (collect [_ module (ipairs lapi.modules)]
            (if (not= module.name nil)
                (values module.name
                        (collect [_ fn-desc (ipairs module.functions)]
                          (values fn-desc.name dummy-fn))))))))

;; this is an example of trying to create a macro that will in turn create
;; proper dummy functions for each of the love2d methos. Basically these dummy functions
;; should have a docstring inherited from the love_api, as well as a proper argument
;; list.
;; This effort didn't go anywhere but I'm leaving this here in case I ever pick it up
;; in the future.
;;
;; (macro make-dummy-function [[details]]
;;   (let [args [:qwe :asds :zs]]
;;     `(fn ,args
;;        ,args
;;        (.. "" (. ,details :description))
;;        {})))

;; (var xx (aaa [testy]))
;; (xx)
;; (macrodebug (aaa [testy]))
