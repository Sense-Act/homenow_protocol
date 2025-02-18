const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.addModule("homenow_protocol", .{ .root_source_file = b.path("src/homenow_protocol.zig"), .optimize = optimize, .target = target });
    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });
    lib_unit_tests.linkLibC();

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
