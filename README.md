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

run this to see resulst on your machine:
```
zig build bench -Doptimize=ReleaseFast -- tim pdq quick radix twin std_block_merge comb shell
```

### 12th Gen Intel(R) Core(TM) i5-12400F

```mermaid
gantt
    title Sorting (ascending) 10000000 usize
    dateFormat x
    axisFormat %S s
    section random
    quick 1.670: 0,1670
    comb 3.156: 0,3155
    shell 5.469: 0,5467
    radix 0.304: 0,304
    tim 2.893: 0,2893
    tail 2.400: 0,2399
    twin 2.377: 0,2377
    std_block 3.371: 0,3372
    std_pdq 2.250: 0,2250
    std_heap 5.512: 0,5514
    section sorted
    quick 0.829: 0,829
    comb 1.179: 0,1179
    shell 0.740: 0,740
    radix 0.301: 0,301
    tim 0.025: 0,25
    tail 0.058: 0,58
    twin 0.071: 0,71
    std_block 0.266: 0,266
    std_pdq 0.041: 0,41
    std_heap 3.912: 0,3913
    section reverse
    quick 1.544: 0,1544
    comb 1.375: 0,1375
    shell 1.378: 0,1378
    radix 0.303: 0,303
    tim 0.822: 0,822
    tail 1.364: 0,1364
    twin 1.280: 0,1280
    std_block 1.304: 0,1304
    std_pdq 0.199: 0,199
    std_heap 3.844: 0,3845
    section ascending saw
    quick 2.979: 0,2978
    comb 2.088: 0,2089
    shell 1.807: 0,1807
    radix 0.322: 0,322
    tim 0.473: 0,473
    tail 0.486: 0,486
    twin 0.465: 0,465
    std_block 1.129: 0,1129
    std_pdq 1.604: 0,1604
    std_heap 4.246: 0,4249
    section descending saw
    comb 1.949: 0,1949
    shell 1.694: 0,1694
    radix 0.299: 0,299
    tim 1.339: 0,1339
    tail 1.478: 0,1478
    twin 1.288: 0,1288
    std_block 1.618: 0,1618
    std_pdq 1.613: 0,1613
    std_heap 4.262: 0,4261
```

```mermaid
gantt
    title Sorting (ascending) 10000000 isize
    dateFormat x
    axisFormat %S s
    section random
    quick 1.691: 0,1691
    comb 3.084: 0,3084
    shell 5.410: 0,5413
    radix 0.332: 0,332
    tim 2.951: 0,2953
    tail 2.414: 0,2414
    twin 2.414: 0,2414
    std_block 3.346: 0,3346
    std_pdq 2.309: 0,2309
    std_heap 5.449: 0,5447
    section sorted
    quick 0.798: 0,798
    comb 1.166: 0,1166
    shell 0.739: 0,739
    radix 0.247: 0,247
    tim 0.025: 0,25
    tail 0.059: 0,59
    twin 0.048: 0,48
    std_block 0.270: 0,270
    std_pdq 0.039: 0,39
    std_heap 3.816: 0,3815
    section reverse
    quick 1.581: 0,1581
    comb 1.347: 0,1347
    shell 1.234: 0,1234
    radix 0.262: 0,262
    tim 0.044: 0,44
    tail 1.396: 0,1396
    twin 0.041: 0,41
    std_block 0.953: 0,953
    std_pdq 0.204: 0,204
    std_heap 3.713: 0,3713
    section ascending saw
    quick 5.516: 0,5516
    comb 2.064: 0,2064
    shell 1.632: 0,1632
    radix 0.280: 0,280
    tim 0.449: 0,449
    tail 0.466: 0,466
    twin 0.478: 0,478
    std_block 1.157: 0,1157
    std_pdq 1.618: 0,1618
    std_heap 4.281: 0,4279
    section descending saw
    comb 2.039: 0,2040
    shell 1.644: 0,1644
    radix 0.279: 0,279
    tim 0.465: 0,465
    tail 1.492: 0,1492
    twin 0.481: 0,481
    std_block 1.596: 0,1596
    std_pdq 1.576: 0,1576
    std_heap 4.199: 0,4199
```

### Big Thank to

[voroskoi](https://github.com/voroskoi) and other contributors
