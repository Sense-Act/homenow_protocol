const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_protocol_path = b.path("src/protocol/homenow_protocol.zig");
    const root_api_path = b.path("src/api/homenow.zig");
    const name = "homenow_protocol";

    const home_now_lib_unexported = b.createModule(.{
        .root_source_file = root_protocol_path,
        .target = target,
        .optimize = optimize,
    });

    { // Creating module for external usage
        const home_now_lib = b.createModule(.{
            .root_source_file = root_protocol_path,
        });

        _ = b.addModule(name, .{
            .root_source_file = root_api_path,
            .imports = &.{
                .{ .name = "homenow_protocol", .module = home_now_lib },
            },
        });
    }

    { // Library
        const lib = b.addLibrary(.{
            .name = name,
            .root_module = home_now_lib_unexported,
            .linkage = .dynamic,
        });
        b.installArtifact(lib);
        // const installed_lib = b.addInstallArtifact(lib, .{});
        // installed_lib.emitted_h = lib.getEmittedH();
        // b.getInstallStep().dependOn(&installed_lib.step);
    }

    { // Tests
        const lib_unit_tests = b.addTest(.{
            .root_module = home_now_lib_unexported,
        });
        lib_unit_tests.linkLibC();
        const lldb = b.addSystemCommand(&.{ "lldb", "--" });
        lldb.addArtifactArg(lib_unit_tests);

        const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_lib_unit_tests.step);

        const lldb_step = b.step("debug", "run tests in debug mode");
        lldb_step.dependOn(&lldb.step);
    }
}
