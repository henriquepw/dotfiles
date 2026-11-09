package compositor

import "github.com/henriquepw/relaxa/internal/proc"

type Mango struct{}

func (Mango) Enable(output string) error {
	return proc.Run("mmsg", "dispatch", "enable_monitor,"+output)
}

func (Mango) Disable(output string) error {
	return proc.Run("mmsg", "dispatch", "disable_monitor,"+output)
}
