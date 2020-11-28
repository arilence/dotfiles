# Rusts package manager
export PATH="$HOME/.cargo/bin:$PATH"

# rust-racer should automatically find the rust path, but this is slightly faster
export RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/src
