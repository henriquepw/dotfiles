package tv

import "net"

func wakeOnLAN(mac string) error {
	hw, err := net.ParseMAC(mac)
	if err != nil {
		return err
	}

	packet := make([]byte, 0, 102)
	for range 6 {
		packet = append(packet, 0xff)
	}
	for range 16 {
		packet = append(packet, hw...)
	}

	conn, err := net.Dial("udp", "255.255.255.255:9")
	if err != nil {
		return err
	}
	defer conn.Close()

	_, err = conn.Write(packet)
	return err
}
