#!/usr/bin/env sh

set -e

zig build bench -Drelease-fast=true

zig_bench_path="./zig-out/bin/run_bench"

${zig_bench_path} std_block_merge quick tim comb shell heap radix twin
