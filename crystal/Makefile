all: podman

buildah:
	export PATH=$PATH:/usr/sbin
	buildah build-using-dockerfile --tag zeromq-server

podman:
	podman build . --tag zeromq-server

crystal:
	shards build --release --no-debug

run:
	podman run -t -p 6666:6666 zeromq-server
