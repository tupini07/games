const std = @import("std");

const tic = @import("tic80.zig");
const map_utils = @import("./utils//map.zig");
const random = @import("./utils/random.zig");
const log = @import("./utils/logger.zig");

const constants = @import("./constants.zig");
const controller = @import("./utils/controller.zig");

const Shape = @import("./entities/shape.zig").Shape;

const MAX_SHAPES = 20;
var shapes: [MAX_SHAPES]Shape = undefined;

var shappes_mem: [40 * @sizeOf(Shape)]u8 = undefined;
var buffered_allocator = std.heap.FixedBufferAllocator.init(&shappes_mem);
var alloc = buffered_allocator.allocator();

var shapes_list: std.ArrayList(Shape) = undefined;

export fn BOOT() void {
    shapes_list = std.ArrayList(Shape).init(alloc);

    random.initRandom();

    for (0..MAX_SHAPES) |i| {
        shapes[i].brand_new();
    }
}

export fn TIC() void {
    if (constants.DEBUG) {
        @setRuntimeSafety(true);
    }

    tic.cls(0);

    for (0..shapes.len) |i| {
        if (!shapes[i].is_dead) {
            shapes[i].doUpdate();
            shapes[i].doDraw();
        }
    }

    if (tic.pressed(controller.UP)) {
        spawnShape();
    }
}

fn spawnShape() void {
    // adding to buffered allocator
    shapes_list.append(Shape{}) catch |err| {
        log.err("Error appending to shapes list: {}", .{err});
    };
    tic.tracef("Shapes list: {any}", .{shapes_list.items.len});

    for (0..shapes.len) |i| {
        if (shapes[i].is_dead) {
            tic.sfx(0, .{ .duration = 20, .speed = 5 });
            shapes[i].init();
            return;
        }
    }
}

export fn BDR() void {}

export fn OVR() void {}
