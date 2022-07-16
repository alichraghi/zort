# Zort

Implementation of 13 sorting algorithms in Zig

| Algorithm               | Custom Comparison | Zero Allocation |
| ----------------------- | ----------------- | --------------- |
| Quick                   | ✅                | ✅              |
| Insertion               | ✅                | ✅              |
| Selection               | ✅                | ✅              |
| Bubble                  | ✅                | ✅              |
| Shell                   | ✅                | ✅              |
| Comb                    | ✅                | ✅              |
| Heap                    | ✅                | ✅              |
| Merge                   | ✅                | ❌              |
| Tail                    | ✅                | ❌              |
| Tim                     | ✅                | ❌              |
| Twin                    | ✅                | ❌              |
| Radix (no negative yet) | ❌                | ❌              |

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
    axisFormat %S s
    tim 0.617: 0,617
    quick 2.596: 0,2595
    radix 2.297: 0,2297
    tail 3.199: 0,3199
    twin 3.148: 0,3149
    std_block_merge 4.281: 0,4281
    comb 4.730: 0,4731
    shell 7.633: 0,7634
```

### Intel(R) Core(TM) i5-6300U CPU @ 2.40GHz

```mermaid
gantt
    title Sorting 10 million items
    dateFormat x
    axisFormat %S.%L
    std_block_merge : 0,2017
    quick : 0,1312
    tim : 0,208
    comb : 0,2031
    shell : 0,3011
    heap : 0,4394
    radix : 0,1347
    twin : 0,1371
```

### Intel(R) Core(TM) i7-4600U CPU @ 2.10GHz

```mermaid
gantt
    title Sorting 10 million items
    dateFormat x
    axisFormat %S.%L
    std_block_merge : 0,1699
    quick : 0,994
    tim : 0,159
    comb : 0,1827
    shell : 0,2368
    heap : 0,3733
    radix : 0,1468
    twin : 0,1273
```
