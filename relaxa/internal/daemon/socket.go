package daemon

import (
	"bufio"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strings"
)

func socketPath() string {
	return filepath.Join(os.Getenv("XDG_RUNTIME_DIR"), "relaxa.sock")
}

// Send sends a command to the daemon and returns its reply.
func Send(cmd string) (string, error) {
	conn, err := net.Dial("unix", socketPath())
	if err != nil {
		return "", fmt.Errorf("daemon não está rodando: %w", err)
	}
	defer conn.Close()

	if _, err := fmt.Fprintln(conn, cmd); err != nil {
		return "", err
	}
	reply, err := bufio.NewReader(conn).ReadString('\n')
	if err != nil {
		return "", err
	}
	reply = strings.TrimSpace(reply)
	if msg, ok := strings.CutPrefix(reply, "error: "); ok {
		return "", fmt.Errorf("%s", msg)
	}
	return reply, nil
}

func serve(ln net.Listener, requests chan<- request) {
	for {
		conn, err := ln.Accept()
		if err != nil {
			return
		}
		go func() {
			defer conn.Close()
			line, err := bufio.NewReader(conn).ReadString('\n')
			if err != nil {
				return
			}
			req := request{cmd: strings.TrimSpace(line), reply: make(chan string, 1)}
			requests <- req
			fmt.Fprintln(conn, <-req.reply)
		}()
	}
}
