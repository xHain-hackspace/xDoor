export MIX_ENV = prod
export MIX_TARGET = rpi3


burn-complete:
	mix firmware ;\
	mix firmware.burn --task complete

burn-upgrade:
	mix firmware ;\
	mix firmware.burn --task upgrade

push:
	mix firmware &&\
	rm -f upload.sh &&\
	mix firmware.gen.script &&\
	SSH_OPTIONS="-p 23" ./upload.sh xdoor.lan.xhain.space

deps-get:
	mix local.hex --force ;\
	mix local.rebar --force ;\
	mix deps.get

deps-update:
	mix deps.update --all

shell:
	./ssh_console.sh xdoor.lan.xhain.space

console: 
	MIX_TARGET=host MIX_ENV=dev iex -S mix

clean:
	mix clean
	mix nerves.clean --all
	mix deps.clean --all

logs:
	ssh admin@xdoor logs 

lock-state-changes:
	ssh admin@xdoor lock_state_changes

logins:
	ssh admin@xdoor logins
