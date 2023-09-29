package logging

import (
	"log"

	"github.com/tupini07/moto-tomo/constants"
)

func Debug(v ...any) {
	if constants.Debug {
		log.Println("[DEBUG] ", v)
	}
}

func Debugf(format string, v ...any) {
	if constants.Debug {
		log.Printf("[DEBUG] "+format, v...)
	}
}

func Info(v ...any) {
	if constants.Debug {
		log.Println("[INFO] ", v)
	}
}

func Infof(format string, v ...any) {
	if constants.Debug {
		log.Printf("[INFO] "+format, v...)
	}
}

func Warn(v ...any) {
	log.Println("[WARN] ", v)
}

func Warnf(format string, v ...any) {
	log.Printf("[WARN] "+format, v...)
}

func Error(v ...any) {
	log.Println("[ERROR] ", v)
}

func Errorf(format string, v ...any) {
	log.Printf("[ERROR] "+format, v...)
}
