package mangohud

import (
	"net"

	"github.com/henriquepw/relaxa/internal/uinput"
)

// Toggle shows or hides the hud of the running game. It needs `control=mangohud`
// in MangoHud.conf, which makes the vulkan layer listen on an abstract socket.
func Toggle() error {
	conn, err := net.Dial("unix", "@mangohud")
	if err != nil {
		return err
	}
	defer conn.Close()

	_, err = conn.Write([]byte(":hud;"))
	return err
}

// ToggleFPSLimit presses the toggle_fps_limit keybind from MangoHud.conf, since
// the control socket has no command for it.
func ToggleFPSLimit(kb *uinput.Keyboard) error {
	return kb.Tap(uinput.KeyLeftAlt, uinput.Key7)
}
