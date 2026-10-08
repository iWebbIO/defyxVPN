// Package android is a build-time stand-in for the private DXcore engine.
//
// The upstream app (UnboundTechCo/defyxVPN) compiles against a private
// DXcore AAR that is only downloadable with access to
// UnboundTechCo/DXcore-private. This stub mirrors the exact API surface the
// app's Kotlin code calls (see android/app/src/main/kotlin), so the fork can
// produce an installable APK from public sources via `gomobile bind`.
//
// The stub simulates the connection progress events the Dart side listens
// for, so the UI flow (connect -> analyzing -> connected) works end to end.
// The VpnService tunnel establishment and split tunneling app filters in the
// Kotlin layer are real; only the underlying proxy engine is not.
package android

import (
	"fmt"
	"sync"
	"time"
)

// ProgressListener mirrors the gomobile-generated interface the app implements.
type ProgressListener interface {
	OnProgress(msg string)
}

// CrashListener mirrors the app's crash callback interface.
type CrashListener interface {
	OnCrash(functionName, errorMessage, stackTrace string)
}

var (
	mu       sync.Mutex
	progress ProgressListener
	crash    CrashListener
)

// SetProgressListener registers the listener that receives progress events.
func SetProgressListener(l ProgressListener) {
	mu.Lock()
	progress = l
	mu.Unlock()
}

// SetCrashCallback registers the Go panic callback. A nil listener clears it.
func SetCrashCallback(l CrashListener) {
	mu.Lock()
	crash = l
	mu.Unlock()
}

func emit(msg string) {
	mu.Lock()
	l := progress
	mu.Unlock()
	if l != nil {
		l.OnProgress(msg)
	}
}

// StartVPN simulates the engine connection sequence. The real implementation
// establishes the proxy core; here we only emit the progress events the
// Flutter side parses in VPN._handleVPNUpdates.
func StartVPN(cacheDir, flowLine, pattern string, deepScan, healthCheck bool) {
	fmt.Println("stub StartVPN", cacheDir, len(flowLine), pattern, deepScan, healthCheck)
	go func() {
		emit("Data: Config Numbers: 3")
		emit("Data: Config index: 1")
		emit("Data: VPN connecting")
		emit("Data: Config label: Stub Engine")
		time.Sleep(500 * time.Millisecond)
		emit("Data: Config index: 2")
		time.Sleep(500 * time.Millisecond)
		emit("Data: Config index: 3")
		time.Sleep(300 * time.Millisecond)
		emit("Data: VPN connected")
	}()
}

// StopVPN stops the engine and notifies the UI.
func StopVPN() bool {
	fmt.Println("stub StopVPN")
	go func() {
		emit("Data: VPN stopped")
	}()
	return true
}

// StartT2S attaches the TUN file descriptor to the (absent) tun2socks core.
func StartT2S(tunfd int, bindAddress string) {
	fmt.Println("stub StartT2S", tunfd, bindAddress)
}

// StopT2S detaches the TUN device.
func StopT2S() {
	fmt.Println("stub StopT2S")
}

// StartTun2socks is the error-returning variant used by the iOS extension.
func StartTun2socks(tunfd int, bindAddress string) error {
	fmt.Println("stub StartTun2socks", tunfd, bindAddress)
	return nil
}

// StopTun2socks stops the tun2socks instance.
func StopTun2socks() {
	fmt.Println("stub StopTun2socks")
}

// Stop is a no-op.
func Stop() bool {
	fmt.Println("stub Stop")
	return false
}

// MeasurePing reports a plausible fixed latency.
func MeasurePing() int {
	return 42
}

// GetFlag reports the exit country flag code.
func GetFlag() string {
	return "xx"
}

// SetAsnName is a no-op.
func SetAsnName() {
	fmt.Println("stub SetAsnName")
}

// SetTimeZone acknowledges the timezone update.
func SetTimeZone(timeDiff float32) bool {
	fmt.Println("stub SetTimeZone", timeDiff)
	return true
}

// GetFlowLine fetches the flowline; the stub has none.
func GetFlowLine(isTest bool, token string) string {
	fmt.Println("stub GetFlowLine", isTest, len(token))
	return ""
}

// GetCachedFlowLine returns the cached flowline; the stub has none.
func GetCachedFlowLine() string {
	fmt.Println("stub GetCachedFlowLine")
	return ""
}

// DecodeAndVerifyFlowline validates a flowline blob; the stub accepts none.
func DecodeAndVerifyFlowline(flowLine string) string {
	fmt.Println("stub DecodeAndVerifyFlowline", len(flowLine))
	return ""
}

// Log forwards a log line.
func Log(message string) {
	fmt.Println(message)
}

// SetCacheDir prepares the engine cache directory.
func SetCacheDir(cacheDir string) {
	fmt.Println("stub SetCacheDir", cacheDir)
}

// Login authenticates a premium account; the stub rejects all.
func Login(email, password string) string {
	fmt.Println("stub Login", email)
	return ""
}

// LoginByCode authenticates via login code; the stub rejects all.
func LoginByCode(code string) string {
	fmt.Println("stub LoginByCode", len(code))
	return ""
}
