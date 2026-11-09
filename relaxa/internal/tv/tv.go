package tv

import "context"

type TV interface {
	// Wake turns the TV on and switches to the PC input.
	Wake(ctx context.Context) error
	Sleep() error
	Awake() (bool, error)
}
