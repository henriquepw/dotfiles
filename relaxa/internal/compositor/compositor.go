package compositor

import (
	"fmt"
	"os"
)

type Compositor interface {
	Enable(output string) error
	Disable(output string) error
}

func Detect() (Compositor, error) {
	switch desktop := os.Getenv("XDG_CURRENT_DESKTOP"); desktop {
	case "mango":
		return Mango{}, nil
	default:
		return nil, fmt.Errorf("unsupported compositor: %q", desktop)
	}
}
