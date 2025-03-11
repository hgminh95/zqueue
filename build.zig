const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const optimize = b.standardOptimizeOption(.{});

    const zqueue_module = b.addModule("zqueue", .{
        .root_source_file = b.path("src/zqueue.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Benchmark
    const zbench_module = b.dependency("zbench", .{
        .target = target,
        .optimize = optimize,
    }).module("zbench");

    const bench = b.addExecutable(.{
        .name = "bench",
        .root_source_file = b.path("bench/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    bench.root_module.addImport("zbench", zbench_module);
    bench.root_module.addImport("zqueue", zqueue_module);

    const run_exe = b.addRunArtifact(bench);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
