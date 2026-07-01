const std = @import("std");
const assert = std.debug.assert;

const ObjectType = enum {
    OBJ_INT,
    OBJ_PAIR,
};

const ObjTyp = enum {
    integer,
    pair,
};

const Object = struct {
    //f_type: ObjectType,
    marked: u8 = 0,
    next: ?*Object = null,
    data: union(ObjTyp) {
        integer: i32,
        pair: struct {
            first: *Object,

            second: *Object,
        },
    },

    pub fn mark(obj: *Object) !void {
        if (obj.marked == 1) return;

        switch (obj.data) {
            .integer => {
                obj.marked = 1;
            },

            .pair => {
                try mark(obj.data.pair.first);
                try mark(obj.data.pair.second);
            },
        }
    }
};

const STACK_MAX = 256;
const maxObjs = 20;

pub fn newObject(allocator: std.mem.Allocator, vm: *VM, Otype: ObjTyp) !*Object {
    if (vm.numObjects == vm.maxObjects) try vm.gc(allocator);
    var object: *Object = try allocator.create(Object);
    switch (Otype) {
        .integer => {
            object.* = .{
                .data = .{ .integer = 0 },
            };
        },
        .pair => {
            object.* = .{
                .data = .{
                    .pair = .{ .first = undefined, .second = undefined },
                },
            };
        },
    }
    //std.debug.print("{any}", .{Otype});
    object.next = vm.firstObject;
    vm.firstObject = object;
    return object;
}

const VM = struct {
    firstObject: ?*Object = null,
    stack: [STACK_MAX]*Object = undefined,
    numObjects: i32 = 0,
    maxObjects: i32 = maxObjs,
    stackSize: usize = 0,

    pub fn init(allocator: std.mem.Allocator) !*VM {
        //var buffer: [1000]u8 = undefined;
        //var fba: std.heap.FixedBufferAllocator = .init(&buffer);
        //const allocator = fba.allocator();
        const vm: *VM = try allocator.create(VM);
        vm.* = VM{};
        // std.debug.print("{d}\n", .{vm.stackSize});
        return vm;
    }

    fn push(vm: *VM, obj: *Object) !void {
        assert(vm.stackSize < STACK_MAX);
        vm.stack[vm.stackSize] = obj;
        vm.stackSize += 1;
    }

    fn pop(vm: *VM) !*Object {
        assert(vm.stackSize > 0);
        const tempObj: **Object = &vm.stack[vm.stackSize];
        vm.stackSize -= 1;
        return tempObj.*;
    }

    pub fn pushInt(vm: *VM, allocator: std.mem.Allocator, val: i32) !void {
        var obj: *Object = try newObject(allocator, vm, ObjTyp.integer);
        obj.data = .{
            .integer = val,
        };
        try vm.push(obj);
    }

    pub fn pushPair(vm: *VM, allocator: std.mem.Allocator) !void {
        var obj: *Object = newObject(allocator, vm, ObjTyp.pair);
        obj.data.pair.first = vm.pop();
        obj.data.pair.second = vm.pop();
        try vm.push(obj);
    }

    fn markAll(vm: *VM) !void {
        var i: usize = 0;
        while (i < vm.stackSize) : (i += 1) {
            try vm.stack[i].mark();
        }
    }

    fn sweep(vm: *VM, allocator: std.mem.Allocator) !void {
        var obj: *?*Object = &vm.firstObject;
        while (obj.*) |o| {
            if (o.marked == 0) {
                const tempobj: *Object = o;
                obj.* = tempobj.next;
                allocator.destroy(tempobj);
                vm.numObjects -= 1;
                continue;
            }
            o.marked = 0;
            obj = &o.next;
        }
    }

    pub fn gc(vm: *VM, allocator: std.mem.Allocator) !void {
        const prevNumObj: i32 = vm.numObjects;
        try markAll(vm);
        try sweep(vm, allocator);

        vm.maxObjects = vm.numObjects * 2;
        std.debug.print("Before gc: {d}\n after gc: {d}\n\n", .{ prevNumObj, vm.numObjects });
    }
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const myvm: *VM = try .init(allocator);
    defer allocator.destroy(myvm);
    std.debug.print("size:{d}", .{myvm.stackSize});

    try myvm.pushInt(allocator, 4);
    _ = try myvm.pop();
    try myvm.gc(allocator);
    std.debug.print("size:{d}", .{myvm.stackSize});
}
