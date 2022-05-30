(fn set-color-hex-rgba [hex-str]
  (assert-compile (= (hex-str:len) 8)
                  (.. "Expect RGB color hex string of 8 characters, got '" hex-str "'."))
  (let [components (table.pack (hex-str:find "(%x%x)(%x%x)(%x%x)(%x%x)"))
        [_ _ rs gs bs as] components
        _  (if (= rs nil)
               (error (.. "There was an error converting '" hex-str "' to RGBA hex color")))
        r (/ (tonumber rs 16) 255)
        g (/ (tonumber gs 16) 255)
        b (/ (tonumber bs 16) 255)
        a (/ (tonumber as 16) 255)
        ]
    `(love.graphics.setColor ,r ,g ,b ,a)))

(fn set-color-hex-rgb [hex-str]
  (assert-compile (= (hex-str:len) 6)
                  (.. "Expect RGB color hex string of 6 characters, got '" hex-str "'."))
  (set-color-hex-rgba (.. hex-str "ff")))

{
 : set-color-hex-rgba
 : set-color-hex-rgb
 }
