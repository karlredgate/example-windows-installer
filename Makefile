
# Create an entry in .ssh/config for this hostname
SERVER := aws-server-hostname
BUCKET := s3://redgates/windows/
EVERYONE:=http://acs.amazonaws.com/groups/global/AllUsers 

default: install

install: build
	scp -q PowerShell/install.exe $(SERVER):
	ssh $(SERVER) 'aws s3 cp install.exe $(BUCKET) --grants read=uri=$(EVERYONE)'

.PHONY: build
build: dependencies installer

installer:
	make -C PowerShell
	@echo Build complete

dependencies:
	@echo Check build dependencies

clean:
	make -C PowerShell clean
	rm -rf install.exe
