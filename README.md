# Zort

Implementation of 11 sorting algorithms in Zig

| Algorithm           | Custom Comparison | Zero Allocation |
| ------------------- | ----------------- | --------------- |
| Quick               | ✅                | ✅              |
| Insertion           | ✅                | ✅              |
| Selection           | ✅                | ✅              |
| Bubble              | ✅                | ✅              |
| Shell               | ✅                | ✅              |
| Comb                | ✅                | ✅              |
| Heap                | ✅                | ✅              |
| Merge               | ✅                | ❌              |
| Tim                 | ✅                | ❌              |
| Twin                | ✅                | ❌              |
| Radix (no negative) | ❌                | ❌              |

## Usage

```zig
const zort = @import("zort");

fn asc(a: u8, b: u8) bool {
    return a < b;
}

pub fn main() !void {
    var arr = [_]u8{ 9, 1, 4, 12, 3, 4 };
    try zort.quickSort(u8, &arr, asc);
}
```

## Benchmarks

### Raspberry Pi 4 with 8GB RAM

```mermaid
gantt
    title Sorting 10 million items
    dateFormat x
    axisFormat %S.%L
    ./zig-out/bin/run_bench std_block_merge : 0,9242
    ./zig-out/bin/run_bench quick : 0,6058
    ./zig-out/bin/run_bench tim : 0,1437
    ./zig-out/bin/run_bench comb : 0,8943
    ./zig-out/bin/run_bench shell : 0,14349
    ./zig-out/bin/run_bench heap : 0,28369
    ./zig-out/bin/run_bench radix : 0,5607
    ./zig-out/bin/run_bench twin : 0,6275
```

### Intel(R) Core(TM) i5-6300U CPU @ 2.40GHz

```mermaid
gantt
    title Sorting 10 million items
    dateFormat x
    axisFormat %S.%L
    ./zig-out/bin/run_bench std_block_merge : 0,2017
    ./zig-out/bin/run_bench quick : 0,1312
    ./zig-out/bin/run_bench tim : 0,208
    ./zig-out/bin/run_bench comb : 0,2031
    ./zig-out/bin/run_bench shell : 0,3011
    ./zig-out/bin/run_bench heap : 0,4394
    ./zig-out/bin/run_bench radix : 0,1347
    ./zig-out/bin/run_bench twin : 0,1371
```
