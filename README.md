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

### Raspberry Pi 4 with 8GB RAM

```mermaid
gantt
    title Sorting (ascending) 10000000 usize
    dateFormat x
    axisFormat %S s
    section random
    tim 3.646: 0,3646
    pdq 1.323: 0,1323
    quick 2.264: 0,2263
    radix 2.590: 0,2590
    msb_radix 1.271: 0,1271
    twin 2.928: 0,2929
    std_block_merge 3.982: 0,3982
    comb 4.680: 0,4679
    shell 7.617: 0,7616
    section sorted
    tim 0.021: 0,21
    pdq 0.021: 0,21
    quick 0.818: 0,818
    radix 3.184: 0,3184
    msb_radix 0.867: 0,867
    twin 0.235: 0,235
    std_block_merge 0.151: 0,151
    comb 1.428: 0,1428
    shell 1.562: 0,1562
    section reverse
    tim 1.461: 0,1461
    pdq 0.353: 0,353
    quick 1.623: 0,1623
    radix 3.123: 0,3125
    msb_radix 0.871: 0,871
    twin 1.848: 0,1848
    std_block_merge 2.365: 0,2366
    comb 1.946: 0,1946
    shell 1.766: 0,1766
    section ascending saw
    tim 0.645: 0,645
    pdq 1.197: 0,1197
    quick 4.809: 0,4809
    radix 2.629: 0,2629
    msb_radix 0.960: 0,960
    twin 0.712: 0,712
    std_block_merge 1.325: 0,1325
    comb 2.896: 0,2895
    shell 2.039: 0,2039
    section descending saw
    tim 1.580: 0,1580
    pdq 1.182: 0,1182
    quick SKIPPED: 0
    radix 2.943: 0,2944
    msb_radix 0.955: 0,955
    twin 1.868: 0,1868
    std_block_merge 2.396: 0,2395
    comb 3.064: 0,3064
    shell 2.090: 0,2090
```

```mermaid
gantt
    title Sorting (ascending) 10000000 isize
    dateFormat x
    axisFormat %S s
    section random
    tim 3.695: 0,3697
    pdq 1.314: 0,1314
    quick 2.262: 0,2262
    radix 0.019: 0,19
    msb_radix 1.176: 0,1176
    twin 2.936: 0,2936
    std_block_merge 3.973: 0,3973
    comb 4.879: 0,4880
    shell 7.574: 0,7576
    section sorted
    tim 0.021: 0,21
    pdq 0.021: 0,21
    quick 0.707: 0,707
    radix 0.019: 0,19
    msb_radix 0.584: 0,584
    twin 0.174: 0,174
    std_block_merge 0.151: 0,151
    comb 1.415: 0,1415
    shell 1.439: 0,1439
    section reverse
    tim 0.097: 0,97
    pdq 0.183: 0,183
    quick 1.610: 0,1610
    radix 0.019: 0,19
    msb_radix 0.606: 0,606
    twin 0.082: 0,82
    std_block_merge 1.952: 0,1952
    comb 1.955: 0,1955
    shell 2.217: 0,2216
    section ascending saw
    tim 0.652: 0,652
    pdq 1.204: 0,1204
    quick 5.137: 0,5135
    radix 0.019: 0,19
    msb_radix 0.688: 0,688
    twin 0.697: 0,697
    std_block_merge 1.327: 0,1327
    comb 3.039: 0,3039
    shell 2.258: 0,2258
    section descending saw
    tim 0.708: 0,708
    pdq 1.207: 0,1207
    quick SKIPPED: 0
    radix 0.019: 0,19
    msb_radix 0.700: 0,700
    twin 0.755: 0,755
    std_block_merge 2.363: 0,2363
    comb 3.014: 0,3014
    shell 2.297: 0,2297
```

### Intel(R) Core(TM) i5-6300U CPU @ 2.40GHz

```mermaid
gantt
    title Sorting (ascending) 10000000 usize
    dateFormat x
    axisFormat %S s
    section random
    tim 2.072: 0,2073
    pdq 0.447: 0,447
    quick 1.114: 0,1114
    radix 1.251: 0,1251
    msb_radix 0.355: 0,355
    twin 1.187: 0,1187
    std_block_merge 1.556: 0,1556
    comb 1.592: 0,1592
    shell 2.240: 0,2240
    section sorted
    tim 0.008: 0,8
    pdq 0.006: 0,6
    quick 0.261: 0,261
    radix 1.249: 0,1249
    msb_radix 0.375: 0,375
    twin 0.073: 0,73
    std_block_merge 0.058: 0,58
    comb 0.397: 0,397
    shell 0.250: 0,250
    section reverse
    tim 0.396: 0,396
    pdq 0.091: 0,91
    quick 0.476: 0,476
    radix 1.086: 0,1086
    msb_radix 0.377: 0,377
    twin 0.414: 0,414
    std_block_merge 0.484: 0,484
    comb 0.488: 0,488
    shell 0.308: 0,308
    section ascending saw
    tim 0.349: 0,349
    pdq 0.443: 0,443
    quick 0.910: 0,910
    radix 1.256: 0,1256
    msb_radix 0.376: 0,376
    twin 0.246: 0,246
    std_block_merge 0.369: 0,369
    comb 0.754: 0,754
    shell 0.553: 0,553
    section descending saw
    tim 0.543: 0,543
    pdq 0.441: 0,441
    quick SKIPPED: 0
    radix 1.247: 0,1247
    msb_radix 0.376: 0,376
    twin 0.478: 0,478
    std_block_merge 0.573: 0,573
    comb 0.788: 0,788
    shell 0.551: 0,551
```

```mermaid
gantt
    title Sorting (ascending) 10000000 isize
    dateFormat x
    axisFormat %S s
    section random
    tim 2.145: 0,2145
    pdq 0.475: 0,475
    quick 1.116: 0,1116
    radix 0.004: 0,4
    msb_radix 0.384: 0,384
    twin 1.216: 0,1216
    std_block_merge 1.572: 0,1572
    comb 1.753: 0,1753
    shell 2.443: 0,2444
    section sorted
    tim 0.008: 0,8
    pdq 0.008: 0,8
    quick 0.186: 0,186
    radix 0.004: 0,4
    msb_radix 0.252: 0,252
    twin 0.059: 0,59
    std_block_merge 0.056: 0,56
    comb 0.398: 0,398
    shell 0.274: 0,274
    section reverse
    tim 0.013: 0,13
    pdq 0.039: 0,39
    quick 0.399: 0,399
    radix 0.004: 0,4
    msb_radix 0.255: 0,255
    twin 0.015: 0,15
    std_block_merge 0.329: 0,329
    comb 0.476: 0,476
    shell 0.343: 0,343
    section ascending saw
    tim 0.362: 0,362
    pdq 0.470: 0,470
    quick 1.206: 0,1206
    radix 0.004: 0,4
    msb_radix 0.260: 0,260
    twin 0.248: 0,248
    std_block_merge 0.371: 0,371
    comb 0.792: 0,792
    shell 0.629: 0,629
    section descending saw
    tim 0.364: 0,364
    pdq 0.468: 0,468
    quick SKIPPED: 0
    radix 0.004: 0,4
    msb_radix 0.272: 0,272
    twin 0.270: 0,270
    std_block_merge 0.566: 0,566
    comb 0.830: 0,830
    shell 0.643: 0,643
```

### Thanks to

[voroskoi](https://github.com/voroskoi) and other contributors
