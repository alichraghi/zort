#!/bin/bash

set -e

algs=("quick" "comb" "shell" "heap" "merge" "radix" "block_merge")

zig_bench_path="../zig-out/bin/run_bench"

for i in "${!algs[@]}"; do
    algs[$i]="${zig_bench_path} ${algs[i]}"
done

datapath="data/exec_time.json"

touch ${datapath}
> ${datapath}

# echo hyperfine --export-json ${datapath} "${algs[@]}"
hyperfine --shell none --export-json ${datapath} "${algs[@]}"
