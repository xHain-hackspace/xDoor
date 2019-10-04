export MIX_ENV = prod

burn-complete: ensure-target
	. ./secrets_$(target) ;\
	echo "Setting WiFi SSID: $${NERVES_NETWORK_SSID}" ;\
	mix firmware ;\
	mix firmware.burn --task complete

burn-upgrade: ensure-target
	. ./secrets_$(target) ;\
	echo "Setting WiFi SSID: $${NERVES_NETWORK_SSID}" ;\
	mix firmware ;\
	mix firmware.burn --task upgrade

push: ensure-target
	. ./secrets_$(target) ;\
	echo "Setting WiFi SSID: $${NERVES_NETWORK_SSID}" ;\
	mix firmware &&\
	rm -f upload.sh &&\
	mix firmware.gen.script &&\
	./upload.sh $${PI_HOST_NAME}

deps-get: ensure-target
	. ./secrets_$(target) ;\
	mix deps.get

deps-update: ensure-target
	. ./secrets_$(target) ;\
	mix deps.update --all

console: ensure-target
	. ./secrets_$(target) ;\
	./ssh_console.sh $${PI_HOST_NAME}

local_console: 
	MIX_ENV=dev iex -S mix

clean:
	mix clean
	mix nerves.clean --all
	mix deps.clean --all

ensure-target:
	@if [ -z "$(target)" ]; then echo "The variabe 'target' needs to be defined"; exit 1; fi