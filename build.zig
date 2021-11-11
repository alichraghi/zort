const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const lib = b.addStaticLibrary("zort", "zort.zig");
    lib.setBuildMode(mode);
    lib.install();

    var benchmark = b.addExecutable("benchmark", "benchmark.zig");
    const benchmarks_step = b.step("bench", "Build Benchmarks");
    benchmarks_step.dependOn(&benchmark.step);
    benchmark.addPackagePath("zort", "zort.zig");
    benchmark.setTarget(target);
    benchmark.setBuildMode(mode);
    benchmark.install();

    var main_tests = b.addTest("zort.zig");
    main_tests.setBuildMode(mode);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
