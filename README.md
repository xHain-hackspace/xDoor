# xDoor

## Description

Operates the door of the xHain using ssh as authentication. After successful ssh login (`open@xdoor` or `close@xdoor`) the lock motor is triggered via gpio.

It is build in elixir using the [nevers-framework](https://hexdocs.pm/nerves/getting-started.html) and runs on any rapsberry-pi.

## Authorized Keys

The authentication is done via an `authorized_keys` file. This file is regularly pulled from a server to allow remote updates. The signature of that file is verified against the public key in `priv/authorized_keys_pub.pem`. See `lib/xdoor/authorized_keys.ex` for implementation details.

# Building

Elixir `1.9` or greater is required to build and flash the xdoor firmware. This repo contains a `.tool-versions` for [asdf](https://asdf-vm.com). Running 
```
asdf install
``` 
should install everything required.

## SSH host_key

The host_key for the ssh server is expected to lie in `priv/host_key/`. It can be generated with 
```
 ssh-keygen -t ed25519 -f ./priv/host_key/ssh_host_ed25519_key
```
Beware that regenerating this will prompt all clients to re-authenticate the fingerprint of the host.

## Makefile 

There are make target for all relevant operations. The most important ones are

* `make deps-get burn-complete`: Get all dependencies, build the firmware image and flash to inserted sd-card. It tries to auto-detect the sd-card and asks for confirmation before flashing.
* `make push`: Build firmware and update existing system via ssh. The `authorized_keys` for this are defined in `config/target.exs`. 
* `make console`: open an iex console prompt on the running system for debugging.


# Hardware

## Used hardware for the locking mechanism
* Equiva Doorlock
<img href=https://www.eq-3.de/assets/images/3/Eqiva-Bluethooth-Smart-Tuerschlossantrieb-V-oS_142950A0_stiwa-b947e9f2.png></img>

    * solder 2 cables (yellow and white) to the buttons, yellow is close, white is open 
<img src=pic1.jpg></img>

    * solder 2 cables (red and black) to connect the power-supply, if you don't want to rely on batteries. ST6 is GND, ST5 is battery voltage. There's a voltage regulator on the board, so a resistor is not necessary to get from 5V down to 4.5V. 
<img src=pic2.jpg></img>

    * Cut this trace to disable the bluetooth chip by disconnecting power. This way no one has to connect 8 fake profiles to the door. 
<img src=pic3.jpg></img>

    * drill a hole into tha case for the cables


* Locking cylinder
    * Standard cylinder - important: needs to be lockable with keys on both sides in the cylinder
