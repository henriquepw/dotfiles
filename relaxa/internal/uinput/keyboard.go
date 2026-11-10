package uinput

import (
	"encoding/binary"
	"os"
	"time"
	"unsafe"

	"golang.org/x/sys/unix"
)

// from linux/uinput.h and linux/input-event-codes.h
const (
	uiSetEvbit  = 0x40045564
	uiSetKeybit = 0x40045565
	uiDevSetup  = 0x405c5503
	uiDevCreate = 0x5501

	evSyn = 0x00
	evKey = 0x01

	KeyLeftAlt = 56
	Key7       = 8
)

type inputEvent struct {
	Sec, Usec int64
	Type      uint16
	Code      uint16
	Value     int32
}

type uinputSetup struct {
	ID           [4]uint16
	Name         [80]byte
	FFEffectsMax uint32
}

// Keyboard is a virtual keyboard that can only press the keys it was created
// with.
type Keyboard struct {
	f *os.File
}

func NewKeyboard(keys ...uint16) (*Keyboard, error) {
	f, err := os.OpenFile("/dev/uinput", os.O_WRONLY, 0)
	if err != nil {
		return nil, err
	}
	fd := f.Fd()

	if err := ioctl(fd, uiSetEvbit, evKey); err != nil {
		f.Close()
		return nil, err
	}
	for _, key := range keys {
		if err := ioctl(fd, uiSetKeybit, uintptr(key)); err != nil {
			f.Close()
			return nil, err
		}
	}

	var setup uinputSetup
	setup.ID[0] = 0x06 // BUS_VIRTUAL
	copy(setup.Name[:], "relaxa")
	if err := ioctl(fd, uiDevSetup, uintptr(unsafe.Pointer(&setup))); err != nil {
		f.Close()
		return nil, err
	}
	if err := ioctl(fd, uiDevCreate, 0); err != nil {
		f.Close()
		return nil, err
	}

	return &Keyboard{f: f}, nil
}

// Tap presses the keys together and releases them. They stay down long enough
// for apps that poll the keyboard once per frame, like MangoHud.
func (k *Keyboard) Tap(keys ...uint16) error {
	for _, key := range keys {
		if err := k.emit(evKey, key, 1); err != nil {
			return err
		}
	}
	if err := k.emit(evSyn, 0, 0); err != nil {
		return err
	}

	time.Sleep(100 * time.Millisecond)

	for _, key := range keys {
		if err := k.emit(evKey, key, 0); err != nil {
			return err
		}
	}
	return k.emit(evSyn, 0, 0)
}

func (k *Keyboard) emit(typ, code uint16, value int32) error {
	return binary.Write(k.f, binary.NativeEndian, inputEvent{Type: typ, Code: code, Value: value})
}

func ioctl(fd, req, arg uintptr) error {
	if _, _, errno := unix.Syscall(unix.SYS_IOCTL, fd, req, arg); errno != 0 {
		return errno
	}
	return nil
}
