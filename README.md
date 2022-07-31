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

### Intel(R) Core(TM) i5-6300U CPU @ 2.40GHz

```mermaid
gantt
    title Sorting (ascending) 10000000 usize
    dateFormat x
    axisFormat %S s
    section random
    tim 0.224: 0,224
    pdq 0.536: 0,536
    twin 1.640: 0,1640
    std_block_merge 2.053: 0,2051
    comb 2.145: 0,2144
    shell 2.758: 0,2758
    section sorted
    tim 0.210: 0,210
    pdq 0.009: 0,9
    twin 0.040: 0,40
    std_block_merge 0.089: 0,89
    comb 0.693: 0,693
    shell 0.332: 0,332
    section reverse
    tim 0.211: 0,211
    pdq 0.055: 0,55
    twin 0.021: 0,21
    std_block_merge 0.419: 0,419
    comb 0.750: 0,750
    shell 0.405: 0,405
    section ascending saw
    tim 0.212: 0,212
    pdq 0.677: 0,677
    twin 0.230: 0,230
    std_block_merge 0.338: 0,338
    comb 0.960: 0,960
    shell 0.623: 0,623
    section descending saw
    tim 0.212: 0,212
    pdq 0.663: 0,663
    twin 0.239: 0,239
    std_block_merge 0.607: 0,607
    comb 0.995: 0,995
    shell 0.692: 0,692
```

```mermaid
gantt
    title Sorting (ascending) 10000000 isize
    dateFormat x
    axisFormat %S s
    section random
    tim 0.216: 0,216
    pdq 0.564: 0,564
    twin 1.642: 0,1642
    std_block_merge 2.070: 0,2070
    comb 2.260: 0,2260
    shell 2.729: 0,2727
    section sorted
    tim 0.219: 0,219
    pdq 0.011: 0,11
    twin 0.039: 0,39
    std_block_merge 0.087: 0,87
    comb 0.661: 0,661
    shell 0.325: 0,325
    section reverse
    tim 0.205: 0,205
    pdq 0.053: 0,53
    twin 0.020: 0,20
    std_block_merge 0.416: 0,416
    comb 0.756: 0,756
    shell 0.408: 0,408
    section ascending saw
    tim 0.214: 0,214
    pdq 0.729: 0,729
    twin 0.227: 0,227
    std_block_merge 0.333: 0,333
    comb 0.979: 0,979
    shell 0.601: 0,601
    section descending saw
    tim 0.205: 0,205
    pdq 0.662: 0,662
    twin 0.246: 0,246
    std_block_merge 0.608: 0,608
    comb 1.021: 0,1021
    shell 0.673: 0,673
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

[voroskoi](https://github.com/voroskoi) and other contributors
