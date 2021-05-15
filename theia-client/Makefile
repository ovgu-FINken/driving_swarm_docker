output/driving-swarm-ide-linux.tar.gz: resources *.go go.* *.json
	go run github.com/asticode/go-astilectron-bundler/astilectron-bundler -l
	cd output/linux* && ./driving-swarm-ide --download-dependencies
	tar cvzf output/driving-swarm-ide-linux.tar.gz output/linux*/*

output/driving-swarm-ide-windows.exe: resources *.go go.* *.json
	go run github.com/asticode/go-astilectron-bundler/astilectron-bundler -w
	cp output/windows*/driving-swarm-ide.exe output/driving-swarm-ide-windows.exe

output/driving-swarm-ide-macos.dmg: resources *.go go.* *.json
	go run github.com/asticode/go-astilectron-bundler/astilectron-bundler -d
	create-dmg --volname "Driving Swarm IDE" --icon "driving-swarm-ide.app" darwin-amd64

clean:
	rm -rf output
