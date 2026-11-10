// relaxa switches the PC between PC mode (monitor) and TV mode (couch gaming).
package main

import (
	"fmt"
	"os"

	"github.com/henriquepw/relaxa/internal/daemon"
)

const help = `usage: relaxa <command>

commands:
  daemon   run the daemon (reads the gamepads and listens on the socket)
  toggle   switch between PC mode and TV mode
  tv       enter TV mode
  pc       go back to PC mode
  status   show the current mode
`

func main() {
	cmd := "help"
	if len(os.Args) > 1 {
		cmd = os.Args[1]
	}

	var err error
	switch cmd {
	case "daemon":
		err = daemon.Run()
	case "toggle", "tv", "pc", "status":
		var reply string
		if reply, err = daemon.Send(cmd); err == nil {
			fmt.Println(reply)
		}
	default:
		fmt.Print(help)
	}

	if err != nil {
		fmt.Fprintln(os.Stderr, "relaxa:", err)
		os.Exit(1)
	}
}
