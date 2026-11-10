package tv

import (
	"context"
	"fmt"
	"net/url"
	"os"
	"os/exec"
	"strings"
	"time"
)

const serverPort = "5038"

// adb controls an Android TV through adb over the network.
type adb struct {
	Addr  string
	MAC   string
	Input string // TvInputInfo id, listed by `dumpsys tv_input`
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
		// connection that only goes away when the server restarts
		_, _ = t.output("kill-server")

		select {
		case <-ctx.Done():
			return fmt.Errorf("TV did not answer adb at %s: %w", t.Addr, err)
		case <-time.After(time.Second):
		}
	}

	// some TVs (TCL) ignore KEYCODE_TV_INPUT_HDMI_N, but every Android TV opens
	// the input through its passthrough uri
	_, err := t.output("shell", "am", "start", "-a", "android.intent.action.VIEW",
		"-d", "content://android.media.tv/passthrough/"+url.PathEscape(t.Input))
	return err
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

	if args[0] != "connect" && args[0] != "kill-server" {
		args = append([]string{"-s", t.Addr}, args...)
	}

	cmd := exec.CommandContext(ctx, "adb", args...)
	// own adb server, so restarting it doesn't drop the user's devices
	cmd.Env = append(os.Environ(), "ANDROID_ADB_SERVER_PORT="+serverPort)
	out, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("adb %s: %w: %s", strings.Join(args, " "), err, out)
	}

	// adb connect exits with 0 even when it fails
	if args[0] == "connect" && !strings.Contains(string(out), "connected") {
		return "", fmt.Errorf("adb connect: %s", out)
	}

	return string(out), nil
}
