package main

import (
	"log"

	"github.com/hajimehoshi/ebiten/v2"
)

type Process interface {
	update(dt float64)
	draw(screen *ebiten.Image)
}

var allProcesses = make([]Process, 0)

func addProcess(p Process) {
	allProcesses = append(allProcesses, p)
}

func removeProcess(p Process) {
	for i, proc := range allProcesses {
		if proc == p {
			log.Printf("Removing process %#v\n", p)
			allProcesses[i] = allProcesses[len(allProcesses)-1]
			allProcesses = allProcesses[:len(allProcesses)-1]

			return
		}
	}
}
