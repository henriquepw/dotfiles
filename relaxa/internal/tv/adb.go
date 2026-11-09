package tv

import (
	"context"
	"fmt"
	"net"
	"os/exec"
	"strings"
	"time"
)

// ADB controls an Android TV through adb over the network.
type ADB struct {
	Addr     string
	MAC      string
	HDMIPort int
}

func (t ADB) Wake(ctx context.Context) error {
	// in deep standby the TV only comes back to the network with Wake-on-LAN
	if err := wakeOnLAN(t.MAC); err != nil {
		return err
	}

	for {
		if t.adb("connect", t.Addr) == nil && t.keyevent("KEYCODE_WAKEUP") == nil {
			break
		}

		select {
		case <-ctx.Done():
			return fmt.Errorf("TV não respondeu ao adb em %s", t.Addr)
		case <-time.After(time.Second):
		}
	}

	return t.keyevent(fmt.Sprintf("KEYCODE_TV_INPUT_HDMI_%d", t.HDMIPort))
}

func (t ADB) Sleep() error {
	return t.keyevent("KEYCODE_SLEEP")
}

func (t ADB) Awake() (bool, error) {
	out, err := t.output("shell", "dumpsys", "power")
	if err != nil {
		return false, err
	}

	return strings.Contains(out, "mWakefulness=Awake"), nil
}

func (t ADB) keyevent(key string) error {
	return t.adb("shell", "input", "keyevent", key)
}

func (t ADB) adb(args ...string) error {
	_, err := t.output(args...)
	return err
}

func (t ADB) output(args ...string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if args[0] != "connect" {
		args = append([]string{"-s", t.Addr}, args...)
	}

	out, err := exec.CommandContext(ctx, "adb", args...).CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("adb %s: %w: %s", strings.Join(args, " "), err, out)
	}

	// adb connect exits with 0 even when it fails
	if args[0] == "connect" && !strings.Contains(string(out), "connected") {
		return "", fmt.Errorf("adb connect: %s", out)
	}

	return string(out), nil
}

func wakeOnLAN(mac string) error {
	hw, err := net.ParseMAC(mac)
	if err != nil {
		return err
	}

	packet := make([]byte, 0, 102)
	for range 6 {
		packet = append(packet, 0xff)
	}

	for range 16 {
		packet = append(packet, hw...)
	}

	conn, err := net.Dial("udp", "255.255.255.255:9")
	if err != nil {
		return err
	}
	defer conn.Close()

	_, err = conn.Write(packet)
	return err
}
