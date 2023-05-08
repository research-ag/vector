MOPS_PKGS=$(shell mops sources)

all: vector vectorClass

vector:
	moc $(MOPS_PKGS) -wasi-system-api vector.mo && wasmtime vector.wasm

vectorClass:
	moc $(MOPS_PKGS) -wasi-system-api vectorClass.mo && wasmtime vectorClass.wasm