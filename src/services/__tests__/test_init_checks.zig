const std = @import("std");
const testing = std.testing;
const fs = std.fs;
const services = @import("services");
const utils = @import("utils");
const Config = @import("config");

test "init_checks creates database file if it doesn't exist" {
    // Setup
    const config = Config.Config.init();
    const test_db_path = config.db_path;

    // Ensure the test database doesn't exist
    fs.cwd().deleteFile(test_db_path) catch |err| switch (err) {
        error.FileNotFound => {},
        else => return err,
    };

    // Run the function
    try services.init_checks.init_checks();

    // Check if the file was created
    const file_exists = fs.cwd().access(test_db_path, .{}) catch |err| switch (err) {
        error.FileNotFound => false,
        else => return err,
    };
    try testing.expect(file_exists);

    // Cleanup
    try fs.cwd().deleteFile(test_db_path);
}

test "init_checks doesn't throw error if database already exists" {
    utils.logger(.tests, "init_checks doesn't throw error if database already exists", .{});

    // Setup
    const config = Config.Config.init();
    const test_db_path = config.db_path;

    // Create a dummy database file
    {
        const file = try fs.cwd().createFile(test_db_path, .{});
        file.close();
    }

    // Run the function
    try services.init_checks.init_checks();

    // Cleanup
    try fs.cwd().deleteFile(test_db_path);
}

// Note: Testing SQLite operations might require more setup and teardown.
// You may want to add more specific tests for SQLite operations if needed.
