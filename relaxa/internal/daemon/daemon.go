package daemon

import (
	"context"
	"log"
	"net"
	"os"
	"os/exec"
	"time"

	"github.com/henriquepw/relaxa/internal/audio"
	"github.com/henriquepw/relaxa/internal/compositor"
	"github.com/henriquepw/relaxa/internal/config"
	"github.com/henriquepw/relaxa/internal/gamepad"
	"github.com/henriquepw/relaxa/internal/steam"
	"github.com/henriquepw/relaxa/internal/tv"
)

type request struct {
	cmd     string
	gamepad *gamepad.Gamepad // who triggered the combo, so it can rumble
	reply   chan string
}

type daemon struct {
	cfg       config.Config
	comp      compositor.Compositor
	prevAudio audio.State
	tv        tv.TV
	inTV      bool
	tvMissing int
}

func Run() error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}

	comp, err := compositor.Detect()
	if err != nil {
		return err
	}

	d := &daemon{
		cfg:  cfg,
		comp: comp,
		tv:   tv.New(cfg.TV.ADB, cfg.TV.MAC, cfg.TV.HDMIPort),
	}

	requests := make(chan request)
	err = gamepad.Watch(cfg.Gamepad.Vendor, cfg.Gamepad.Combo, cfg.Gamepad.Hold, func(g *gamepad.Gamepad) {
		requests <- request{cmd: "toggle", gamepad: g}
	})
	if err != nil {
		return err
	}

	os.Remove(socketPath())
	ln, err := net.Listen("unix", socketPath())
	if err != nil {
		return err
	}

	defer ln.Close()
	go serve(ln, requests)

	poll := time.NewTicker(10 * time.Second)
	defer poll.Stop()
	for {
		select {
		case req := <-requests:
			reply := d.handle(req)
			if req.reply != nil {
				req.reply <- reply
			}
		case <-poll.C:
			if d.inTV && d.tvOff() {
				log.Print("TV desligou, voltando pro modo PC")
				d.leaveTV(nil)
			}
		}
	}
}

func (d *daemon) handle(req request) string {
	want := d.inTV
	switch req.cmd {
	case "toggle":
		want = !d.inTV
	case "tv":
		want = true
	case "pc":
		want = false
	case "status":
	default:
		return "error: unknown command: " + req.cmd
	}

	if want && !d.inTV {
		d.enterTV(req.gamepad)
	}
	if !want && d.inTV {
		d.leaveTV(req.gamepad)
	}

	if d.inTV {
		return "tv"
	}
	return "pc"
}

func (d *daemon) enterTV(g *gamepad.Gamepad) {
	if g != nil {
		g.Rumble(1)
	}

	ctx, cancel := context.WithTimeout(context.Background(), d.cfg.TV.WakeTimeout)
	defer cancel()
	if err := d.tv.Wake(ctx); err != nil {
		d.fail(err)
	}

	if prev, err := audio.Current(d.cfg.Audio.Card); d.must(err) {
		d.prevAudio = prev
	}
	d.must(steam.Stop())

	d.must(d.comp.Enable(d.cfg.Outputs.TV))
	for _, out := range d.cfg.Outputs.PC {
		d.must(d.comp.Disable(out))
	}

	audioState := audio.State{Sink: d.cfg.Audio.TVSink, Profile: d.cfg.Audio.TVProfile}
	d.must(audio.Use(d.cfg.Audio.Card, audioState))

	for _, name := range d.cfg.Close.Processes {
		exec.Command("pkill", "-x", name).Run()
	}
	for _, app := range d.cfg.Close.Flatpaks {
		exec.Command("flatpak", "kill", app).Run()
	}

	d.must(steam.StartGamescope(d.cfg.Gamescope))
	d.inTV = true
	d.tvMissing = 0
}

func (d *daemon) leaveTV(g *gamepad.Gamepad) {
	if g != nil {
		g.Rumble(2)
	}
	d.must(steam.Stop())
	steam.StopGamescope()

	for _, out := range d.cfg.Outputs.PC {
		d.must(d.comp.Enable(out))
	}
	d.must(d.comp.Disable(d.cfg.Outputs.TV))
	if d.prevAudio != (audio.State{}) {
		d.must(audio.Use(d.cfg.Audio.Card, d.prevAudio))
	}

	d.must(steam.StartSilent())
	d.must(d.tv.Sleep())
	d.inTV = false
}

// tvOff reports whether the TV was turned off with its own remote. No adb
// reply for 3 polls in a row also counts as off.
func (d *daemon) tvOff() bool {
	awake, err := d.tv.Awake()
	if err != nil {
		d.tvMissing++
		return d.tvMissing >= 3
	}

	d.tvMissing = 0
	return !awake
}

func (d *daemon) must(err error) bool {
	if err != nil {
		d.fail(err)
	}
	return err == nil
}

func (d *daemon) fail(err error) {
	log.Print(err)
	exec.Command("notify-send", "relaxa", err.Error()).Run()
}
