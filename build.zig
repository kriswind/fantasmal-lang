const std = @import("std");

// Main build function
pub fn build(b: *std.Build) void {
    // Standard target options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create executable
    const exe = b.addExecutable(.{
        .name = "fantasmal",
        .target = target,
        .optimize = optimize,
    });

    // Add all C source files from src directory
    const src_dir = "src";
    var dir = std.fs.cwd().openDir(src_dir, .{ .iterate = true }) catch @panic("Failed to open src directory");
    defer dir.close();

    var walker = dir.iterate();
    while (walker.next() catch @panic("Error walking directory")) |entry| {
        if (std.mem.endsWith(u8, entry.name, ".c")) {
            exe.addCSourceFile(.{
                .file = b.path(b.fmt("{s}/{s}", .{ src_dir, entry.name })),
                .flags = &[_][]const u8{},
            });
        }
    }

    // Configure the C toolchain
    exe.linkLibC();

    // Install the executable
    b.installArtifact(exe);

    // Create a run step
    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Create specific steps
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    const build_step = b.step("build", "Build the application");
    build_step.dependOn(&exe.step);
}
