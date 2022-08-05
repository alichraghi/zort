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
    title Sorting (ascending) 10000000 usize
    dateFormat x
    axisFormat %S s
    section random
    tim 0.622: 0,622
    pdq 1.280: 0,1280
    quick 2.557: 0,2555
    radix 2.645: 0,2643
    twin 3.156: 0,3156
    std_block_merge 4.340: 0,4339
    comb 5.004: 0,5004
    shell 8.000: 0,8001
    section sorted
    tim 0.623: 0,623
    pdq 0.021: 0,21
    quick 0.928: 0,928
    radix 2.680: 0,2681
    twin 0.139: 0,139
    std_block_merge 0.167: 0,167
    comb 1.498: 0,1498
    shell 1.607: 0,1607
    section reverse
    tim 0.611: 0,611
    pdq 0.367: 0,367
    quick 1.787: 0,1787
    radix 2.313: 0,2311
    twin 1.639: 0,1639
    std_block_merge 2.428: 0,2429
    comb 1.934: 0,1934
    shell 1.834: 0,1834
    section ascending saw
    tim 0.617: 0,617
    pdq 1.147: 0,1147
    quick 16.875: 0,16887
    radix 2.684: 0,2684
    twin 0.672: 0,672
    std_block_merge 1.472: 0,1472
    comb 3.018: 0,3018
    shell 2.107: 0,2107
    section descending saw
    tim 0.618: 0,618
    pdq 1.153: 0,1153
    quick SKIPPED: 0
    radix 2.658: 0,2658
    twin 1.757: 0,1757
    std_block_merge 2.545: 0,2543
    comb 3.057: 0,3056
    shell 2.139: 0,2138
```

```mermaid
gantt
    title Sorting (ascending) 10000000 isize
    dateFormat x
    axisFormat %S s
    section random
    tim 0.619: 0,619
    pdq 1.289: 0,1289
    quick 2.568: 0,2568
    radix 0.019: 0,19
    twin 3.215: 0,3214
    std_block_merge 4.336: 0,4335
    comb 4.926: 0,4924
    shell 7.957: 0,7956
    section sorted
    tim 0.624: 0,624
    pdq 0.021: 0,21
    quick 0.814: 0,814
    radix 0.019: 0,19
    twin 0.100: 0,100
    std_block_merge 0.167: 0,167
    comb 1.498: 0,1498
    shell 1.600: 0,1600
    section reverse
    tim 0.622: 0,622
    pdq 0.184: 0,184
    quick 1.831: 0,1831
    radix 0.019: 0,19
    twin 0.082: 0,82
    std_block_merge 1.979: 0,1979
    comb 1.950: 0,1950
    shell 1.840: 0,1840
    section ascending saw
    tim 0.622: 0,622
    pdq 1.147: 0,1147
    quick 11.813: 0,11813
    radix 0.019: 0,19
    twin 0.654: 0,654
    std_block_merge 1.471: 0,1471
    comb 3.020: 0,3019
    shell 2.111: 0,2113
    section descending saw
    tim 0.620: 0,620
    pdq 1.145: 0,1145
    quick SKIPPED: 0
    radix 0.019: 0,19
    twin 0.714: 0,714
    std_block_merge 2.496: 0,2496
    comb 3.072: 0,3072
    shell 2.145: 0,2143
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
