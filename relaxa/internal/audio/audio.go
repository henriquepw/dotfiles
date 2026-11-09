package audio

import (
	"encoding/json"
	"fmt"
	"os/exec"
	"strings"

	"github.com/henriquepw/relaxa/internal/proc"
)

// State is what gets restored when leaving TV mode.
type State struct {
	Sink    string
	Profile string
}

func Current(card string) (State, error) {
	sink, err := exec.Command("pactl", "get-default-sink").Output()
	if err != nil {
		return State{}, err
	}
	profile, err := activeProfile(card)
	return State{Sink: strings.TrimSpace(string(sink)), Profile: profile}, err
}

// Use switches the card profile before the sink, since the HDMI sink only
// exists while its profile is active.
func Use(card string, s State) error {
	if err := proc.Run("pactl", "set-card-profile", card, s.Profile); err != nil {
		return err
	}
	return proc.Run("pactl", "set-default-sink", s.Sink)
}

func activeProfile(card string) (string, error) {
	out, err := exec.Command("pactl", "-f", "json", "list", "cards").Output()
	if err != nil {
		return "", err
	}
	var cards []struct {
		Name          string `json:"name"`
		ActiveProfile string `json:"active_profile"`
	}
	if err := json.Unmarshal(out, &cards); err != nil {
		return "", err
	}
	for _, c := range cards {
		if c.Name == card {
			return c.ActiveProfile, nil
		}
	}
	return "", fmt.Errorf("placa de áudio %s não encontrada", card)
}
