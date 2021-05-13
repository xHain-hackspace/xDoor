# xDoor

## Description

Operate the door of the x-hain (or any other space) using ssh as authentication. After successful ssh-authentication the lock motor is triggered via gpio.

It is build in elixir using the [nevers-framework](https://hexdocs.pm/nerves/getting-started.html) and runs on any rapsberry-pi.

## Authentication

The authentication is done via an `authorized_keys` file. All keys in that file will be able to open and close the door. The file is taken from `./priv/authorized_keys/authorized_key`. In a future version this list will be updated dynamically from an external source.

# Building

Elixir `1.9` or greater is required to build and flash the xdoor firmware. This repo contains a `.tool-versions` for [asdf](https://asdf-vm.com). Running 
```
asdf install
``` 
should install everything required.

## Secrets

The wifi-credentials and any other target specific configs are contained in the `./secrets` file that is (for obvious reasons) not committed to git. Here is an example with all the required values:

```
export MIX_TARGET=rpi0 #https://hexdocs.pm/nerves/targets.html
export NERVES_NETWORK_SSID=xHain
export NERVES_NETWORK_PSK=password
export PI_HOST_NAME=xdoor.lan.xhain.space #required for flashing via ssh
```

## SSH host_key

The host_key for the ssh server is expect to lie in `priv/host_key/`. It can be generated with 
```
 ssh-keygen -t ed25519 -f ./priv/host_key/ssh_host_ed25519_key
```
Beware that regenerating this will prompt all clients to re-authenticate the fingerprint of the host.

## Makefile 

There are make target for all relevant operations. The most important ones are

* `make deps-get burn-complete`: Get all dependencies, build the firmware image and flash to inserted sd-card. It tries to auto-detect the sd-card and asks for confirmation before flashing.
* `make push`: Build firmware and update existing system via ssh. The `authorized_keys` for this are defined in `config/target.exs`. By default they are taken from the machine that first build the image.
* `make console`: open an iex console prompt on the running system for debugging.


# Hardware

## Used hardware for the locking mechanism
* Equiva Doorlock
<img href=https://www.eq-3.de/assets/images/3/Eqiva-Bluethooth-Smart-Tuerschlossantrieb-V-oS_142950A0_stiwa-b947e9f2.png></img>

** solder 2 cables (yellow and white) to the buttons
<img src=pic1.jpg></img>

** solder 2 cables (red and black) to connect the power-supply, if you don't want to rely on batteries.
<img src=pic2.jpg></img>

** drill a hole into tha case for the cables


* Locking cylinder

** Standard cylinder - important: needs to be lockable with keys on both sides in the cylinder