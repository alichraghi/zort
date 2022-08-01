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
    tim 0.179: 0,179
    pdq 0.450: 0,450
    quick 1.243: 0,1243
    radix 0.945: 0,945
    twin 1.412: 0,1412
    std_block_merge 1.784: 0,1784
    comb 1.797: 0,1797
    shell 2.357: 0,2358
    section sorted
    tim 0.193: 0,193
    pdq 0.007: 0,7
    quick 0.294: 0,294
    radix 0.956: 0,956
    twin 0.043: 0,43
    std_block_merge 0.059: 0,59
    comb 0.471: 0,471
    shell 0.253: 0,253
    section reverse
    tim 0.179: 0,179
    pdq 0.097: 0,97
    quick 0.542: 0,542
    radix 1.097: 0,1097
    twin 0.422: 0,422
    std_block_merge 0.474: 0,474
    comb 0.583: 0,583
    shell 0.324: 0,324
    section ascending saw
    tim 0.180: 0,180
    pdq 0.441: 0,441
    quick 0.801: 0,801
    radix 1.098: 0,1098
    twin 0.272: 0,272
    std_block_merge 0.469: 0,469
    comb 0.897: 0,897
    shell 0.576: 0,576
    section descending saw
    tim 0.180: 0,180
    pdq 0.441: 0,441
    quick SKIPPED: 0
    radix 0.947: 0,947
    twin 0.517: 0,517
    std_block_merge 0.654: 0,654
    comb 0.915: 0,915
    shell 0.567: 0,567
```

```mermaid
gantt
    title Sorting (ascending) 10000000 isize
    dateFormat x
    axisFormat %S s
    section random
    tim 0.181: 0,181
    pdq 0.470: 0,470
    quick 1.201: 0,1201
    radix 0.004: 0,4
    twin 1.402: 0,1402
    std_block_merge 1.775: 0,1775
    comb 1.727: 0,1727
    shell 2.469: 0,2467
    section sorted
    tim 0.179: 0,179
    pdq 0.008: 0,8
    quick 0.205: 0,205
    radix 0.004: 0,4
    twin 0.029: 0,29
    std_block_merge 0.059: 0,59
    comb 0.499: 0,499
    shell 0.252: 0,252
    section reverse
    tim 0.177: 0,177
    pdq 0.039: 0,39
    quick 0.441: 0,441
    radix 0.004: 0,4
    twin 0.014: 0,14
    std_block_merge 0.313: 0,313
    comb 0.596: 0,596
    shell 0.318: 0,318
    section ascending saw
    tim 0.180: 0,180
    pdq 0.461: 0,461
    quick 2.180: 0,2181
    radix 0.004: 0,4
    twin 0.271: 0,271
    std_block_merge 0.467: 0,467
    comb 0.946: 0,946
    shell 0.628: 0,628
    section descending saw
    tim 0.180: 0,180
    pdq 0.475: 0,475
    quick SKIPPED: 0
    radix 0.004: 0,4
    twin 0.278: 0,278
    std_block_merge 0.637: 0,637
    comb 0.968: 0,968
    shell 0.648: 0,648
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
