# Zort

Implementation of 13 sorting algorithms in Zig

| Algorithm               | Custom Comparison | Zero Allocation |
| ----------------------- | ----------------- | --------------- |
| Bubble                  | ✅                | ✅              |
| Comb                    | ✅                | ✅              |
| Heap                    | ✅                | ✅              |
| Insertion               | ✅                | ✅              |
| Merge                   | ✅                | ❌              |
| PDQ                     | ✅                | ✅              |
| Quick                   | ✅                | ✅              |
| Radix (no negative yet) | ❌                | ❌              |
| Selection               | ✅                | ✅              |
| Shell                   | ✅                | ✅              |
| Tail                    | ✅                | ❌              |
| Tim                     | ✅                | ❌              |
| Twin                    | ✅                | ❌              |

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

### Raspberry Pi 4 with 8GB RAM (old)

```mermaid
gantt
    title Sorting 10 million items
    dateFormat x
    axisFormat %S s
    tim 0.617: 0,617
    pdq 1.306: 0,1306
    quick 2.553: 0,2552
    radix 2.439: 0,2441
    tail 3.232: 0,3232
    twin 3.248: 0,3248
    std_block_merge 4.285: 0,4283
    comb 4.746: 0,4747
    shell 7.645: 0,7643
```

### Intel(R) Core(TM) i5-6300U CPU @ 2.40GHz (old)

```mermaid
gantt
    title Sorting 10 million items
    dateFormat x
    axisFormat %S s
    tim 0.215: 0,215
    pdq 0.503: 0,503
    quick 1.152: 0,1152
    radix 1.101: 0,1101
    tail 1.396: 0,1396
    twin 1.401: 0,1401
    std_block_merge 1.594: 0,1594
    comb 1.741: 0,1741
    shell 2.500: 0,2501
```

### Intel(R) Core(TM) i7-4600U CPU @ 2.10GHz

```mermaid
gantt
    title Sorting 10 million items
    dateFormat x
    axisFormat %S s
    tim 0.170: 0,170
    pdq 0.402: 0,402
    quick 0.958: 0,958
    radix 1.095: 0,1095
    tail 1.198: 0,1198
    twin 1.193: 0,1193
    std_block_merge 1.420: 0,1420
    comb 1.684: 0,1684
    shell 2.359: 0,2359
```


### Thanks

[Voroskoi](https://github.com/voroskio) and other contributors
