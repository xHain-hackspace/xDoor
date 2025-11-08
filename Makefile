# variables
host=xdoor

# environment
export MIX_ENV = prod
export MIX_TARGET = rpi3
export XDOOR_HOST = ${host}

setup:
	mix archive.install hex nerves_bootstrap

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
	SSH_OPTIONS="-p 23" ./upload.sh ${host}.lan.xhain.space

deps-get:
	mix local.hex --force ;\
	mix local.rebar --force ;\
	mix deps.get

deps-update:
	mix deps.update --all

shell:
	ssh -p 23 admin@${host}.lan.xhain.space

console: 
	MIX_TARGET=host MIX_ENV=dev iex -S mix

clean:
	mix clean
	mix nerves.clean --all
	mix deps.clean --all

logs:
	ssh admin@${host} logs 

lock-state-changes:
	ssh admin@${host} lock_state_changes

logins:
	ssh admin@${host} logins
