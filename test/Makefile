MOPS_PKGS=$(shell mops sources)

all: vector

vector:
	moc $(MOPS_PKGS) -wasi-system-api vector.mo && wasmtime vector.wasm
