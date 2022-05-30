(local utils (require :utils))

(var just-pressed-keys [])

(fn register-keypress [key]
  (table.insert just-pressed-keys key))

(fn remove-just-pressed-keys []
  (set just-pressed-keys []))

(fn is-key-just-pressed [key]
  (utils.table-contains-value just-pressed-keys key))

(fn is-key-down [key]
  (love.keyboard.isDown key))

{: register-keypress
 : remove-just-pressed-keys
 : is-key-just-pressed
 : is-key-down}
