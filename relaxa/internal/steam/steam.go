package steam

import (
	"fmt"
	"os/exec"
	"slices"
	"time"

	"github.com/henriquepw/relaxa/internal/proc"
)

func running(name string) bool {
	return exec.Command("pgrep", "-x", name).Run() == nil
}

// Stop shuts steam down and waits for it to exit, so it can be restarted in a
// different mode.
func Stop() error {
	if !running("steam") {
		return nil
	}

	if err := proc.Run("steam", "-shutdown"); err != nil {
		return err
	}

	for range 30 {
		if !running("steam") {
			return nil
		}
		time.Sleep(500 * time.Millisecond)
	}

	return fmt.Errorf("steam não fechou a tempo")
}

// StartGamescope opens steam in Big Picture inside gamescope.
func StartGamescope(args []string) error {
	args = slices.Concat(args, []string{"--", "steam", "-gamepadui", "steam://open/bigpicture"})
	return proc.Spawn("gamescope", args...)
}

func StopGamescope() {
	exec.Command("pkill", "-x", "gamescope").Run()
}

func StartSilent() error {
	return proc.Spawn("steam", "-silent")
}
