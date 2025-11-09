# variables
host=xdoor
secrets_file=secrets.yml

# environment
export MIX_ENV = prod
export MIX_TARGET = rpi3
export XDOOR_HOST = ${host}

setup:
	mix archive.install hex nerves_bootstrap

generate-secrets:
	mkdir -p secrets priv/host_key
	sops -d --extract '["mqtt_password"]' ${secrets_file} > secrets/mqtt_pw
	sops -d --extract '["authorized_keys_pub_pem"]' ${secrets_file} > priv/authorized_keys_pub.pem
	sops -d --extract '["${host}"]["ssh_key"]["pub"]' ${secrets_file} > priv/host_key/ssh_host_ed25519_key.pub
	sops -d --extract '["${host}"]["ssh_key"]["priv"]' ${secrets_file} > priv/host_key/ssh_host_ed25519_key

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
