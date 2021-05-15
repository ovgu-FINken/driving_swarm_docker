package main

import (
	"crypto/rand"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"time"

	"github.com/asticode/go-astikit"
	"github.com/asticode/go-astilectron"
	"github.com/asticode/go-astilectron-bootstrap"
	"github.com/gen2brain/dlgs"
	"github.com/jaypipes/ghw"

	_ "codeberg.org/momar/require_terminal_emulator"
)

var appTitle = "Eclipse Theia"
var logger = log.New(os.Stderr, "", 0)

func main() {
	if len(os.Args) > 1 && os.Args[1] == "--download-dependencies" {
		err := bootstrap.Run(bootstrap.Options{
			Asset:    Asset,
			AssetDir: AssetDir,
			RestoreAssets: RestoreAssets,
			AstilectronOptions: astilectron.Options{
				VersionAstilectron: "0.47.0",
				VersionElectron:    "12.0.5",
			},
			Windows: []*bootstrap.Window{},
			OnWait: func(a *astilectron.Astilectron, w []*astilectron.Window, m *astilectron.Menu, t *astilectron.Tray, tm *astilectron.Menu) error {
				os.Exit(0)
				return fmt.Errorf("--download-dependencies is set")
			},
		})
		if err != nil {
			panic(err)
		}
		return
	}

	res, err := http.Get("http://127.0.0.1:1900")
	if err == nil && res.StatusCode == 200 {
		if len(os.Args) > 1 && os.Args[1] != "--attach" {
			okay, err := dlgs.Question(appTitle, "Something is already running on port 1900. Attach to existing instance?", false)
			if err == nil && !okay {
				return
			}
		}
	} else {

		executable := "docker"
		prefix := []string{"--device=/dev/dri"}

		err := exec.Command("docker", "image", "inspect", "ovgudrivingswarm/development").Run()
		if err != nil && err.Error() == "exit status 1" {
			okay, err := dlgs.Question(appTitle, "Couldn't find ovgudrivingswarm/development image, it can be automatically downloaded in the background. Do you want to download it (> 2 GB)?", false)
			if failure(err, "Couldn't display dialog: %w") {
				return
			}
			if !okay {
				return
			}

			err = exec.Command("docker", "image", "pull", "ovgudrivingswarm/development").Run()
			if failure(err, "Couldn't pull image: %w") {
				return
			}
		} else if err != nil {
			logger.Println(err)
			failure(fmt.Errorf("Docker is required, but couldn't be found on your system. Is it in your $PATH environment?"), "%w")
			return
		}

		gpuInfo, err := ghw.GPU()
		if err != nil || gpuInfo == nil || len(gpuInfo.GraphicsCards) == 0 {
			okay, err := dlgs.Question(appTitle, "Couldn't detect graphics card. Continue without hardware acceleration?", false)
			if failure(err, "Couldn't display dialog: %w") {
				return
			}
			if !okay {
				return
			}
			prefix = []string{}
		} else {
			hasOther := false
			for _, gpu := range gpuInfo.GraphicsCards {
				if gpu.DeviceInfo.Vendor.Name != "NVIDIA Corporation" {
					hasOther = true
				}
			}
			for _, gpu := range gpuInfo.GraphicsCards {
				if gpu.DeviceInfo.Vendor.Name == "NVIDIA Corporation" {
					err := exec.Command("nvidia-docker", "version").Run()
					if err != nil {
						if hasOther {
							choice, okay, err := dlgs.List(appTitle, "Detected NVIDIA graphics card, but nvidia-docker isn't installed. How to continue?", []string{
								"Continue with internal GPU",
								"Continue without hardware acceleration",
								"Cancel",
							})
							if failure(err, "Couldn't display dialog: %w") {
								return
							}
							if !okay || choice == "Cancel" {
								return
							} else if choice == "Continue without hardware acceleration" {
								prefix = []string{}
							}
						} else {
							okay, err := dlgs.Question(appTitle, "Detected NVIDIA graphics card, but nvidia-docker isn't installed. Continue without hardware acceleration?", false)
							if failure(err, "Couldn't display dialog: %w") {
								return
							}
							if !okay {
								return
							}
							prefix = []string{}
						}
					} else {
						executable = "nvidia-docker"
						prefix = []string{"--gpus", "all", "--device=/dev/dri"}
					}
					break
				}
			}
		}

		workspace := ""
		if len(os.Args) > 1 {
			workspace = os.Args[1]
		} else {
			var okay bool
			workspace, okay, err = dlgs.File("Choose a Workspace - "+appTitle, "", true)
			if failure(err, "Couldn't display dialog: %w") {
				return
			}
			if !okay {
				return
			}
		}

		configDirOption := "-v"
		configDir, err := os.UserConfigDir()
		if err != nil {
			configDirOption = "-e"
			configDir = "ignore_ide_config_volume="
		}
		configDir += string(os.PathSeparator) + "driving-swarm-ide"
		err = os.MkdirAll(configDir, 0755)
		if err != nil {
			configDirOption = "-e"
			configDir = "ignore_ide_config_volume="
		}
		
		tempName := make([]byte, 4)
		_, _ = rand.Read(tempName)
		cmd := exec.Command(executable, append(append([]string{"run"}, prefix...),
			"--name", "rosdev-" + fmt.Sprintf("%x", tempName),
			"--rm", "-it", "-h", "rosdev",
			"-p", "127.0.0.1:1800:1800",
			"-p", "127.0.0.1:1900:1900",
			//"-p", "127.0.0.1:5900:5900",
			"-v", workspace + ":/home/docker/workspace",
			configDirOption, configDir + ":/home/docker/.theia",
			"ovgudrivingswarm/development")...)
		cmd.Stderr = os.Stderr
		cmd.Stdout = os.Stdout
		cmd.Stdin = os.Stdin
		err = cmd.Start()
		if failure(err, "Couldn't start container: %w") {
			return
		}
		defer func() {
			time.Sleep(1 * time.Second)
			logger.Println("Stopping container...")
			_ = exec.Command("docker", "rm", "--force", "rosdev-" + fmt.Sprintf("%x", tempName)).Run()
			_, _ = cmd.Process.Wait()
		}()
		go func() {
			state, _ := cmd.Process.Wait()
			if state.ExitCode() != 0 {
				failure(fmt.Errorf("Container process exited unexpectedly with status %d", cmd.ProcessState.ExitCode()), "%w")
				os.Exit(1)
			}
		}()

		time.Sleep(2 * time.Second)
		startTime := time.Now()
		running := false
		for !running {
			res, err := http.Get("http://127.0.0.1:1900")
			if err == nil && res.StatusCode == 200 {
				running = true
			} else if startTime.Add(180 * time.Second).Before(time.Now()) {
				failure(fmt.Errorf("Couldn't start Theia within 180 seconds -> quitting"), "%w")
				return
			}
		}
		time.Sleep(2 * time.Second)
	}

	err = bootstrap.Run(bootstrap.Options{
		Asset:    Asset,
		AssetDir: AssetDir,
		RestoreAssets: RestoreAssets,
		AstilectronOptions: astilectron.Options{
			AppName:            appTitle,
			AppIconDefaultPath: "resources/icon.png",
			AppIconDarwinPath:  "resources/icon.icns",
			VersionAstilectron: "0.47.0",
			VersionElectron:    "12.0.5",
		},
		Windows: []*bootstrap.Window{{
			Homepage: "http://127.0.0.1:1900",
			Options: &astilectron.WindowOptions{
				Title: astikit.StrPtr(appTitle),
				Height: astikit.IntPtr(720),
				Width:  astikit.IntPtr(1280),
			},
		}},
	})
	if failure(err, "Couldn't start Electron: %w") {
		return
	}
	logger.Println("Window closed, cleaning up...")
}

func failure(err error, wrap string) bool {
	if err != nil {
		err = fmt.Errorf(wrap, err)
		_, _ = dlgs.Error(appTitle, err.Error())
		logger.Println(err)
		return true
	}
	return false
}
