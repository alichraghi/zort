# Zort

![logo](/media/logo.png)

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

### Intel(R) Core(TM) i7-4600U CPU @ 2.10GHz

```mermaid
gantt
    title Sorting (ascending) 10000000 usize
    dateFormat x
    axisFormat %S s
    section random
    tim 1.932: 0,1932
    pdq 0.400: 0,400
    quick 0.882: 0,882
    radix 0.311: 0,311
    twin 1.126: 0,1126
    std_block_merge 1.402: 0,1402
    comb 1.631: 0,1631
    shell 2.943: 0,2944
    section sorted
    tim 0.010: 0,10
    pdq 0.011: 0,11
    quick 0.281: 0,281
    radix 0.303: 0,303
    twin 0.085: 0,85
    std_block_merge 0.063: 0,63
    comb 0.500: 0,500
    shell 0.332: 0,332
    section reverse
    tim 0.603: 0,603
    pdq 0.108: 0,108
    quick 0.474: 0,474
    radix 0.251: 0,251
    twin 0.431: 0,431
    std_block_merge 0.477: 0,477
    comb 0.559: 0,559
    shell 0.357: 0,357
    section ascending saw
    tim 0.325: 0,325
    pdq 0.408: 0,408
    quick 1.454: 0,1454
    radix 0.318: 0,318
    twin 0.285: 0,285
    std_block_merge 0.518: 0,518
    comb 0.836: 0,836
    shell 0.590: 0,590
    section descending saw
    tim 0.482: 0,482
    pdq 0.404: 0,404
    quick 49.500: 0,49519
    radix 0.375: 0,375
    twin 0.674: 0,674
    std_block_merge 0.746: 0,746
    comb 1.082: 0,1082
    shell 0.834: 0,834
```

```mermaid
gantt
    title Sorting (ascending) 10000000 isize
    dateFormat x
    axisFormat %S s
    section random
    tim 2.160: 0,2160
    pdq 0.515: 0,515
    quick 0.987: 0,987
    radix 0.407: 0,407
    twin 1.281: 0,1281
    std_block_merge 1.588: 0,1588
    comb 1.753: 0,1753
    shell 2.480: 0,2481
    section sorted
    tim 0.013: 0,13
    pdq 0.013: 0,13
    quick 0.207: 0,207
    radix 0.212: 0,212
    twin 0.086: 0,86
    std_block_merge 0.090: 0,90
    comb 0.681: 0,681
    shell 0.442: 0,442
    section reverse
    tim 0.029: 0,29
    pdq 0.053: 0,53
    quick 0.424: 0,424
    radix 0.188: 0,188
    twin 0.020: 0,20
    std_block_merge 0.393: 0,393
    comb 0.544: 0,544
    shell 0.355: 0,355
    section ascending saw
    tim 0.417: 0,417
    pdq 0.522: 0,522
    quick 0.668: 0,668
    radix 0.234: 0,234
    twin 0.312: 0,312
    std_block_merge 0.452: 0,452
    comb 0.899: 0,899
    shell 0.688: 0,688
    section descending saw
    tim 0.339: 0,339
    pdq 0.422: 0,422
    quick 33.281: 0,33269
    radix 0.250: 0,250
    twin 0.373: 0,373
    std_block_merge 0.797: 0,797
    comb 1.001: 0,1001
    shell 0.699: 0,699
```

### Big Thank to

[voroskoi](https://github.com/voroskoi) and other contributors
