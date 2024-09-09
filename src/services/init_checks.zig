const Config = @import("config");
const std = @import("std");
const sqlite = @import("sqlite3");
const c = @cImport({
    @cDefine("SQLITE_THREADSAFE", "0");
    @cInclude("sqlite3.h");
});
const utils = @import("utils");

/// check_init checks if database exits and is ready to be used
pub fn init_checks() !void {
    const config = Config.Config.init();

    const fs = std.fs;
    const db_path = config.db_path;

    var file = fs.cwd().openFile(db_path, .{}) catch |err| {
        if (err == error.FileNotFound) {
            _ = try fs.cwd().createFile(db_path, .{});
            return;
        }
        return err;
    };

    defer file.close();

    // Open a connection to SQLite database
    var db: ?*c.sqlite3 = null;
    if (c.sqlite3_open(db_path.ptr, &db) != c.SQLITE_OK) {
        utils.logger(.err, "Can't open database: {s}", .{c.sqlite3_errmsg(db)});
        return error.DatabaseOpenError;
    } else {
        utils.logger(.info, "Database opened successfully\n", .{});
    }
    defer _ = c.sqlite3_close(db);

    // Example: Create a table
    const err = c.sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT);", null, null, null);
    if (err != c.SQLITE_OK) {
        utils.logger(.err, "SQL error: {s}", .{c.sqlite3_errmsg(db)});
        return error.SQLExecutionError;
    } else {
        utils.logger(.info, "Tables created successfully\n", .{});
    }

    utils.logger(.info, "Checks passed\n", .{});
}
