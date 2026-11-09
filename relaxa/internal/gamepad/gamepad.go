package gamepad

import (
	"encoding/binary"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sync"
	"time"
	"unsafe"

	"golang.org/x/sys/unix"
)

// evdev, from linux/input.h and linux/input-event-codes.h
const (
	evKey     = 0x01
	evFF      = 0x15
	ffRumble  = 0x50
	eviocgid  = 0x80084502
	eviocsff  = 0x40304580
	eviocrmff = 0x40044581
)

var buttons = map[string]uint16{
	"BTN_SOUTH":  0x130,
	"BTN_EAST":   0x131,
	"BTN_NORTH":  0x133,
	"BTN_WEST":   0x134,
	"BTN_TL":     0x136,
	"BTN_TR":     0x137,
	"BTN_TL2":    0x138,
	"BTN_TR2":    0x139,
	"BTN_SELECT": 0x13a,
	"BTN_START":  0x13b,
	"BTN_MODE":   0x13c,
	"BTN_THUMBL": 0x13d,
	"BTN_THUMBR": 0x13e,
}

type inputEvent struct {
	Sec, Usec int64
	Type      uint16
	Code      uint16
	Value     int32
}

type inputID struct {
	Bustype, Vendor, Product, Version uint16
}

type ffEffect struct {
	Type      uint16
	ID        int16
	Direction uint16
	Trigger   [2]uint16
	Replay    struct{ Length, Delay uint16 }
	_         [2]byte
	Strong    uint16
	Weak      uint16
	_         [28]byte
}

type Gamepad struct {
	f *os.File
}

// Rumble vibrates the gamepad n times. Gamepads without force feedback are
// ignored.
func (g *Gamepad) Rumble(n int) {
	effect := ffEffect{Type: ffRumble, ID: -1, Strong: 0xc000, Weak: 0xc000}
	effect.Replay.Length = 150
	fd := g.f.Fd()
	if _, _, errno := unix.Syscall(unix.SYS_IOCTL, fd, eviocsff, uintptr(unsafe.Pointer(&effect))); errno != 0 {
		return
	}
	defer unix.Syscall(unix.SYS_IOCTL, fd, eviocrmff, uintptr(effect.ID))

	play := inputEvent{Type: evFF, Code: uint16(effect.ID), Value: 1}
	for i := range n {
		if i > 0 {
			time.Sleep(300 * time.Millisecond)
		}
		binary.Write(g.f, binary.NativeEndian, play)
	}

	time.Sleep(150 * time.Millisecond)
}

// Watch reads every device from the vendor and calls onCombo when the combo is
// held for hold. Gamepads turned on later are picked up by the periodic scan.
func Watch(vendor uint16, combo []string, hold time.Duration, onCombo func(*Gamepad)) error {
	codes := make(map[uint16]bool, len(combo))
	for _, name := range combo {
		code, ok := buttons[name]
		if !ok {
			return fmt.Errorf("botão desconhecido: %s", name)
		}
		codes[code] = true
	}

	var mu sync.Mutex
	open := map[string]bool{}
	go func() {
		for {
			paths, _ := filepath.Glob("/dev/input/event*")
			for _, path := range paths {
				mu.Lock()
				seen := open[path]
				mu.Unlock()
				if seen {
					continue
				}

				g, err := openGamepad(path, vendor)
				if err != nil {
					continue
				}

				mu.Lock()
				open[path] = true
				mu.Unlock()

				go func() {
					readCombo(g, codes, hold, onCombo)
					g.f.Close()
					mu.Lock()
					delete(open, path)
					mu.Unlock()
				}()
			}

			time.Sleep(2 * time.Second)
		}
	}()
	return nil
}

func openGamepad(path string, vendor uint16) (*Gamepad, error) {
	f, err := os.OpenFile(path, os.O_RDWR, 0)
	if err != nil {
		return nil, err
	}
	var id inputID
	if _, _, errno := unix.Syscall(unix.SYS_IOCTL, f.Fd(), eviocgid, uintptr(unsafe.Pointer(&id))); errno != 0 || id.Vendor != vendor {
		f.Close()
		return nil, fmt.Errorf("%s: não é do vendor %04x", path, vendor)
	}
	return &Gamepad{f: f}, nil
}

// readCombo runs until the device goes away.
func readCombo(g *Gamepad, codes map[uint16]bool, hold time.Duration, onCombo func(*Gamepad)) {
	pressed := map[uint16]bool{}
	var timer *time.Timer
	for {
		var ev inputEvent
		if err := binary.Read(g.f, binary.NativeEndian, &ev); err != nil {
			if timer != nil {
				timer.Stop()
			}
			log.Printf("%s: %v", g.f.Name(), err)
			return
		}

		if ev.Type != evKey || !codes[ev.Code] {
			continue
		}

		pressed[ev.Code] = ev.Value != 0

		all := true
		for code := range codes {
			all = all && pressed[code]
		}

		switch {
		case all && timer == nil:
			timer = time.AfterFunc(hold, func() { onCombo(g) })
		case !all && timer != nil:
			timer.Stop()
			timer = nil
		}
	}
}
