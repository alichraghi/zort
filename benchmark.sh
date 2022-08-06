#!/usr/bin/env sh

set -e

zig build bench -Drelease-fast=true

zig_bench_path="./zig-out/bin/run_bench"

${zig_bench_path} tim pdq quick radix msb_radix twin std_block_merge comb shell
