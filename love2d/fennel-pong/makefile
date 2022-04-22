VERSION=0.1.0
NAME=exo
URL=https://technomancy.itch.io/exo-encounter-667
AUTHOR="Phil Hagelberg and Dan Larkin"
DESCRIPTION="A game of exploration."

LIBS := $(wildcard lib/*)
LUA := $(wildcard *.lua)
SRC := $(wildcard *.fnl)
OUT := $(patsubst %.fnl,%.lua,$(SRC))

run: $(OUT) ; love .

count: ; cloc *.fnl --force-lang=clojure

check: $(OUT)
	grep '.\{81\}' *fnl || true
	luacheck --std luajit+love+fennel $(OUT)

clean: ; rm -rf releases/* $(OUT)
cleansrc: ; rm -rf $(OUT)

%.lua: %.fnl ; lua lib/fennel --compile --correlate $< > $@

LOVEFILE=releases/$(NAME)-$(VERSION).love

$(LOVEFILE): $(LUA) $(OUT) $(LIBS) assets text
	mkdir -p releases/
	find $^ -type f | LC_ALL=C sort | env TZ=UTC zip -r -q -9 -X $@ -@

love: $(LOVEFILE)

# platform-specific distributables

REL="$(PWD)/love-release.sh" # https://p.hagelb.org/love-release.sh
FLAGS=-a "$(AUTHOR)" --description $(DESCRIPTION) \
	--love 11.1 --url $(URL) --version $(VERSION) --lovefile $(LOVEFILE)

releases/$(NAME)-$(VERSION)-x86_64.AppImage: $(LOVEFILE)
	cd appimage && ./build.sh 11.1 $(PWD)/$(LOVEFILE)
	mv appimage/game-x86_64.AppImage $@

releases/$(NAME)-$(VERSION)-macos.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -M
	mv releases/EXO_encounter-667-macos.zip $@

releases/$(NAME)-$(VERSION)-win.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -W32
	mv releases/EXO_encounter-667-win32.zip $@

linux: releases/$(NAME)-$(VERSION)-x86_64.AppImage
mac: releases/$(NAME)-$(VERSION)-macos.zip
windows: releases/$(NAME)-$(VERSION)-win.zip

uploadlinux: releases/$(NAME)-$(VERSION)-x86_64.AppImage
	butler push $^ technomancy/exo-encounter-667:linux
uploadmac: releases/$(NAME)-$(VERSION)-macos.zip
	butler push $^ technomancy/exo-encounter-667:mac
uploadwindows: releases/$(NAME)-$(VERSION)-win.zip
	butler push $^ technomancy/exo-encounter-667:windows

upload: uploadlinux uploadmac uploadwindows
