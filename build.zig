const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    {
        const lib = b.addStaticLibrary("embedding", "src/main.zig");
        lib.setBuildMode(mode);
        lib.linkLibC();
        lib.linkSystemLibrary("luajit");
        lib.install();
    }

    {
        const lib = b.addSharedLibrary("moon", "src/moon.zig", .unversioned);
        lib.setBuildMode(mode);
        lib.linkLibC();
        lib.linkSystemLibrary("luajit");
        lib.install();
    }

    const test_step = b.step("test", "Run library tests");
    {
        const main_tests = b.addTest("src/main.zig");
        main_tests.setBuildMode(mode);
        test_step.dependOn(&main_tests.step);
    }

    const run_step = b.step("run", "Run main");
    {
        const exe = b.addExecutable("main", "src/main.zig");
        exe.setBuildMode(mode);
        exe.linkLibC();
        exe.linkSystemLibrary("luajit");
        exe.install();
        run_step.dependOn(&exe.run().step);
    }
}
