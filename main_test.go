package main

import "testing"

func TestHello(t *testing.T) {
	for _, tc := range []struct{ name, want string }{
		{"world", "Hello world!"},
		{"Александр", "Hello Александр!"},
		{"", "Hello !"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			if got := hello(tc.name); got != tc.want {
				t.Fatalf("hello(%q) = %q, want %q", tc.name, got, tc.want)
			}
		})
	}
}
