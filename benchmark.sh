#!/usr/bin/env sh

set -e

zig build bench -Drelease-fast=true

echo 'Generating Benchmark Data...'
zig_bench_path="./zig-out/bin/run_bench"
datapath="benchmark/data/exec_time.json"
${zig_bench_path} std_block_merge quick tim comb shell heap radix twin > ${datapath}
echo 'Data Generated'

cd benchmark

python3 bars.py
echo 'Created Benchmark Images in benchmark/image'

cd -
