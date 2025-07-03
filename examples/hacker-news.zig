const std = @import("std");
const capy = @import("capy");
pub usingnamespace capy.cross_platform;

const ListModel = struct {
    /// size is a data wrapper so that we can change it (e.g. implement infinite scrolling)
    size: capy.Atom(usize) = capy.Atom(usize).of(10),
    arena: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(capy.internal.allocator),

    pub fn getComponent(self: *ListModel, index: usize) *capy.Label {
        return capy.label(.{
            .text = std.fmt.allocPrintZ(self.arena.allocator(), "Label #{d}", .{index + 1}) catch unreachable,
        });
    }
};

pub fn main() !void {
    try capy.init();
    defer capy.deinit();

    var hn_list_model = ListModel{};

    var window = try capy.Window.init();
    try window.set(
        capy.stack(.{
            capy.rect(.{ .color = capy.Color.comptimeFromString("#f6f6ef") }),
            capy.column(.{}, .{
                capy.stack(.{
                    capy.rect(.{
                        .color = capy.Color.comptimeFromString("#ff6600"),
                        .cornerRadius = .{ 0.0, 0.0, 5.0, 5.0 },
                    }),
                    capy.label(.{ .text = "Hacker News", .layout = .{ .alignment = .Center } }),
                }),
                capy.columnList(.{}, &hn_list_model),
            }),
        }),
    );
    window.setTitle("Hacker News");
    window.show();

    // The last time a new entry was added to the list
    var last_add = std.time.milliTimestamp();
    while (capy.stepEventLoop(.Blocking)) {
        while (std.time.milliTimestamp() >= last_add + 1000) : (last_add += 1000) {
            hn_list_model.size.set(hn_list_model.size.get() + 1);
            std.log.info("There are now {} items.", .{hn_list_model.size.get()});
        }
    }
}
