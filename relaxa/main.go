// relaxa switches the PC between PC mode (monitor) and TV mode (couch gaming).
package main

import (
	"fmt"
	"os"

	"github.com/henriquepw/relaxa/internal/daemon"
)

const help = `uso: relaxa <comando>

comandos:
  daemon   roda o daemon (lê os controles e escuta o socket)
  toggle   alterna entre modo PC e modo TV
  tv       entra no modo TV
  pc       volta pro modo PC
  status   mostra o modo atual
  help     mostra esta ajuda`

func main() {
	cmd := "help"
	if len(os.Args) > 1 {
		cmd = os.Args[1]
	}

	var err error
	switch cmd {
	case "help":
		fmt.Println(help)
	case "daemon":
		err = daemon.Run()
	case "toggle", "tv", "pc", "status":
		var reply string
		if reply, err = daemon.Send(cmd); err == nil {
			fmt.Println(reply)
		}
	default:
		fmt.Fprintf(os.Stderr, "relaxa: comando desconhecido: %s\n\n%s\n", cmd, help)
		os.Exit(2)
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, "relaxa:", err)
		os.Exit(1)
	}
}
