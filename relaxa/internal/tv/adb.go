package tv

import (
	"context"
	"fmt"
	"os/exec"
	"strings"
	"time"
)

// adb controls an Android TV through adb over the network.
type adb struct {
	Addr     string
	MAC      string
	HDMIPort int
}

func (t adb) Wake(ctx context.Context) error {
	for {
		// in deep standby the TV only comes back to the network with
		// Wake-on-LAN, and a single packet can get lost
		if err := wakeOnLAN(t.MAC); err != nil {
			return err
		}

		_, err := t.output("connect", t.Addr)
		if err == nil {
			err = t.keyevent("KEYCODE_WAKEUP")
		}
		if err == nil {
			break
		}
		// after the TV sleeps, the adb server keeps a dead "offline"
		// connection that blocks reconnecting until it is dropped
		_, _ = t.output("disconnect", t.Addr)

		select {
		case <-ctx.Done():
			return fmt.Errorf("TV não respondeu ao adb em %s: %w", t.Addr, err)
		case <-time.After(time.Second):
		}
	}

	return t.keyevent(fmt.Sprintf("KEYCODE_TV_INPUT_HDMI_%d", t.HDMIPort))
}

func (t adb) Sleep() error {
	return t.keyevent("KEYCODE_SLEEP")
}

func (t adb) Awake() (bool, error) {
	out, err := t.output("shell", "dumpsys", "power")
	if err != nil {
		return false, err
	}

	return strings.Contains(out, "mWakefulness=Awake"), nil
}

func (t adb) keyevent(key string) error {
	_, err := t.output("shell", "input", "keyevent", key)
	return err
}

func (t adb) output(args ...string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if args[0] != "connect" && args[0] != "disconnect" {
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
