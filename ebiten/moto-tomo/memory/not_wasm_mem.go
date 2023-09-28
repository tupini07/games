//go:build !wasm

package memory

func Save(key string, val any) {

}

func GetInt(key string) (int, bool) {
	return 0, false
}
