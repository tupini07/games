(ns clorog.logger)

(def is-release (atom false))

(defn set-is-release
  [value]
  {:pre [(boolean? value)]}
  (println "Logger: setting is-release to:" value)
  (reset! is-release value))

(defn log [& what]
  (when (not @is-release)
    (apply println what)))

#_(log "potato" "and " 3)