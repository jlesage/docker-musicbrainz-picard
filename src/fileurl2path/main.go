package main

import (
	"fmt"
	"net/url"
	"os"
	"path/filepath"
)

func fileURLToPath(raw string) (string, error) {
	u, err := url.Parse(raw)
	if err != nil {
		return "", err
	}
	if u.Scheme != "file" {
		return "", fmt.Errorf("not a file:// URL")
	}
	if u.Host != "" && u.Host != "localhost" {
		return "", fmt.Errorf("non-local host in file URL: %s", u.Host)
	}

	p, err := url.PathUnescape(u.EscapedPath())
	if err != nil {
		return "", err
	}
	if p == "" {
		p = "/"
	}
	return filepath.Clean(p), nil
}

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintln(os.Stderr, "usage: fileurl2path file:///path/to/file")
		os.Exit(2)
	}

	p, err := fileURLToPath(os.Args[1])
	if err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
	fmt.Println(p)
}
