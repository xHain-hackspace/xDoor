export MIX_ENV = prod

burn-complete: ensure-secrets
	. ./secrets ;\
	echo "Setting WiFi SSID: $${NERVES_NETWORK_SSID}" ;\
	mix firmware ;\
	mix firmware.burn --task complete

burn-upgrade: ensure-secrets
	. ./secrets ;\
	echo "Setting WiFi SSID: $${NERVES_NETWORK_SSID}" ;\
	mix firmware ;\
	mix firmware.burn --task upgrade

push: ensure-secrets
	. ./secrets ;\
	echo "Setting WiFi SSID: $${NERVES_NETWORK_SSID}" ;\
	mix firmware &&\
	rm -f upload.sh &&\
	mix firmware.gen.script &&\
	./upload.sh $${PI_HOST_NAME}

deps-get: ensure-secrets
	. ./secrets ;\
	mix local.hex --force ;\
	mix local.rebar --force ;\
	mix deps.get

deps-update: ensure-secrets
	. ./secrets ;\
	mix deps.update --all

shell: ensure-secrets
	. ./secrets ;\
	./ssh_console.sh $${PI_HOST_NAME}

console: 
	MIX_ENV=dev iex -S mix

clean:
	mix clean
	mix nerves.clean --all
	mix deps.clean --all

logs:
	ssh admin@xdoor logs 

lock-state-changes:
	ssh admin@xdoor lock_state_changes

ensure-secrets:
	@if [ ! -f "secrets" ]; then echo "No secrets file. See README"; exit 1; fi
