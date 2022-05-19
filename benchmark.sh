#!/usr/bin/env sh

set -e

zig build bench -Drelease-fast=true

zig_bench_path="./zig-out/bin/run_bench"

${zig_bench_path} comb heap quick radix shell std_block_merge tim tail twin 
