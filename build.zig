const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_path = b.path("src/homenow_protocol.zig");
    const name = "homenow_protocol";

    _ = b.addModule(name, .{
        .root_source_file = root_path,
    });

    const lib_mod = b.createModule(.{
        .root_source_file = root_path,
        .target = target,
        .optimize = optimize,
    });

    { // Library
        const lib = b.addLibrary(.{
            .name = name,
            .root_module = lib_mod,
            .linkage = .dynamic,
        });
        b.installArtifact(lib);
        // const installed_lib = b.addInstallArtifact(lib, .{});
        // installed_lib.emitted_h = lib.getEmittedH();
        // b.getInstallStep().dependOn(&installed_lib.step);
    }

    { // Tests
        const lib_unit_tests = b.addTest(.{
            .root_module = lib_mod,
        });
        lib_unit_tests.linkLibC();

        const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_lib_unit_tests.step);
    }
}
