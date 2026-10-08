//go:build tools

// Keep golang.org/x/mobile in go.mod and go.sum: newer gomobile versions
// refuse to bind unless the bind library resolves from the bound module.
package tools

import _ "golang.org/x/mobile/bind"
