#!/bin/bash

set -e

zig build bench -Drelease-fast=true

cd benchmark

echo 'Generating Benchmark Data...'
source gen_data.sh
echo 'Data Generated'

python3 bars.py
echo 'Created Benchmark Images in benchmark/image'

cd -