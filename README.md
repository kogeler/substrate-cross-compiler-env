# substrate-cross-compiler-env

The scripts allow building a substrate node for amd64, aarch64(armv8 64bit) architectures.

## Preparing

```commandline
mkdir git
git clone https://github.com/paritytech/polkadot.git
```

## Build Docker images
```commandline
./build-env.sh bullseye aarch64
./build-env.sh bullseye amd64
./build-env.sh buster aarch64
./build-env.sh buster amd64
```

## Build
```commandline
./run-env.sh bullseye amd64
cd /git/polkadot
cargo build --release
exit
```

You can find results in `cargo_target_debian_*_*` folders.

## Useful cargo commands

### CPU optimizations

print all available CPUs
```commandline
rustc --target x86_64-unknown-linux-gnu --print target-cpus
rustc --target aarch64-unknown-linux-gnu --print target-cpus
```
Print the optimizations for CPUs
```commandline
rustc --target x86_64-unknown-linux-gnu -C target-cpu=x86-64-v3 --print cfg
rustc --target aarch64-unknown-linux-gnu -C target-cpu=apple-m1 --print cfg
# Print the optimizations for your CPU
rustc -C target-cpu=native --print cfg
```
Build a binary that optimized for CPUs
```commandline
RUSTFLAGS='-C target-cpu=x86-64-v3' cargo build --release --target x86_64-unknown-linux-gnu
RUSTFLAGS='-C target-cpu=cortex-a72' cargo build --release --target aarch64-unknown-linux-gnu
# Build a binary that optimized for your CPU
RUSTFLAGS='-C target-cpu=native' cargo build --release --target x86_64-unknown-linux-gnu
```

### Debug symbols

Build an optimzed binary with debug symbols
```commandline
cargo build --profile testnet
```