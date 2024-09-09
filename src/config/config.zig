pub const Config = struct {
    db_host: []const u8,
    db_port: u16,
    db_user: []const u8,
    db_password: []const u8,
    db_name: []const u8,
    db_path: []const u8,
    is_dev: bool,

    pub fn init() Config {
        return Config{
            .db_host = "localhost",
            .db_port = 5432,
            .db_user = "zigolo",
            .db_password = "postgres",
            .db_name = "postgres",
            .db_path = "zigolo.db",
            .is_dev = true,
        };
    }
};
