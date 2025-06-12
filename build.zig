const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const zort_module = b.addModule("zort", .{
        .root_source_file = b.path("src/main.zig"),
    });
    const bench = b.addExecutable(.{
        .name = "bench",
        .root_source_file = b.path("bench/bench.zig"),
        .optimize = optimize,
        .target = target,
    });
    bench.root_module.addImport("zort", zort_module);

    const bench_cmd = b.addRunArtifact(bench);
    if (b.args) |args| {
        bench_cmd.addArgs(args);
    }
    const bench_step = b.step("bench", "Run benchmarks");
    bench_step.dependOn(&bench_cmd.step);

    const tests = b.addTest(.{
        .root_source_file = b.path("src/test.zig"),
        .optimize = optimize,
        .target = target,
    });
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
