const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const lib = b.addStaticLibrary("zort", "zort.zig");
    const install_lib = b.addInstallArtifact(lib);
    const lib_step = b.step("lib", "Build Static Library");
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib_step.dependOn(&install_lib.step);

    const benchmark = b.addExecutable("run_bench", "benchmark/run_bench.zig");
    const benchmarks_step = b.step("bench", "Build Benchmarks");
    const install_benchmark = b.addInstallArtifact(benchmark);
    benchmark.setTarget(target);
    benchmark.addPackagePath("zort", "zort.zig");
    benchmarks_step.dependOn(&install_benchmark.step);

    var tests = b.addTest("zort.zig");
    const test_step = b.step("test", "Run library tests");
    tests.setBuildMode(mode);
    test_step.dependOn(&tests.step);
}
