//go:build wasm

package memory

import (
	"strconv"
	"syscall/js"

	"github.com/tupini07/moto-tomo/logging"
)

func Save(key string, val any) {
	logging.Debugf("Saving %s to localStorage as %v", key, val)
	js.Global().Get("localStorage").Call("setItem", key, val)
}

func GetInt(key string) (int, bool) {
	val := js.Global().Get("localStorage").Call("getItem", key)
	logging.Debugf("Got %s from localStorage as %v", key, val)

	if val.IsNull() || val.IsUndefined() {
		return 0, false
	}

	ival, err := strconv.Atoi(val.String())
	if err != nil {
		logging.Debugf("Failed to convert %v to int: %s", val, err)
		return 0, false
	}

	return ival, true
}
