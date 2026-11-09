package proc

import (
	"fmt"
	"os/exec"
	"syscall"
)

// Run runs the command and includes its output in the error.
func Run(name string, args ...string) error {
	out, err := exec.Command(name, args...).CombinedOutput()
	if err != nil {
		return fmt.Errorf("%s: %w: %s", name, err, out)
	}

	return nil
}

// Spawn starts the command in its own session without waiting for it, so it
// outlives the daemon.
func Spawn(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.SysProcAttr = &syscall.SysProcAttr{Setsid: true}
	if err := cmd.Start(); err != nil {
		return err
	}

	go cmd.Wait()
	return nil
}
