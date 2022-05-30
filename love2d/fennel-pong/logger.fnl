(local exports {})

(fn concat-log-msgs [...]
  (table.concat [...] " "))

(fn exports.debug [...]
  (if _G.is-debug
      (print (.. "[DEBUG] " (concat-log-msgs ...)))))

exports
