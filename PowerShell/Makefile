
GITHUB=git@github.com

default: dependencies build

.PHONY: build
build: example.exe
	@echo Build complete

example.exe: example.nsi Example/Example.psm1
	makensis example.nsi

dependencies:
	@echo Check build dependencies
	rpm --quiet --query mingw32-nsis
	rpm --quiet --query mingw32-nsiswrapper

clean:
	rm -rf example.exe
