const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.

    const exe = b.addExecutable(.{
        .name = "zigolo",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.version = .{ .major = 0, .minor = 0, .patch = 1 };
    exe.linkSystemLibrary("sqlite3");

    // create module for config
    const config_module = b.addModule("config", .{
        .root_source_file = b.path("src/config/config.zig"),
    });

    // create module for services
    const services_module = b.addModule("services", .{
        .root_source_file = b.path("src/services/services.zig"),
    });

    // create module for utils
    const utils_module = b.addModule("utils", .{
        .root_source_file = b.path("src/utils/utils.zig"),
    });

    exe.root_module.addImport("config", config_module);
    exe.root_module.addImport("services", services_module);
    exe.root_module.addImport("utils", utils_module);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    run_tests(b, target, optimize, config_module, services_module, utils_module);
}

fn run_tests(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, config_module: *std.Build.Module, services_module: *std.Build.Module, utils_module: *std.Build.Module) void {
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/services/__tests__/test_init_checks.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_unit_tests.root_module.addImport("config", config_module);
    exe_unit_tests.root_module.addImport("services", services_module);
    exe_unit_tests.root_module.addImport("utils", utils_module);

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
