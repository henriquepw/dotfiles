package config

import (
	"os"
	"path/filepath"
	"time"

	"github.com/BurntSushi/toml"
)

type Config struct {
	Gamepad struct {
		Vendor   uint16
		Toggle   Combo
		MangoHud Combo
		FPSLimit Combo `toml:"fps_limit"`
	}
	TV struct {
		ADB         string
		MAC         string
		Input       string
		WakeTimeout time.Duration `toml:"wake_timeout"`
	}
	Outputs struct {
		TV string
		PC []string
	}
	Audio struct {
		Card      string
		TVProfile string `toml:"tv_profile"`
		TVSink    string `toml:"tv_sink"`
	}
	Gamescope []string
	Close     struct {
		Processes []string
		Flatpaks  []string
	}
}

type Combo struct {
	Combo []string
	Hold  time.Duration
}

func Load() (Config, error) {
	dir, err := os.UserConfigDir()
	if err != nil {
		return Config{}, err
	}

	var cfg Config
	_, err = toml.DecodeFile(filepath.Join(dir, "relaxa", "config.toml"), &cfg)

	return cfg, err
}
