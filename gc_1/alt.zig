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
            first: ?*Object,

            second: ?*Object,
        },
    },

    pub fn mark(obj: *Object) !void {
        if (obj.marked == 1) return;

        obj.marked = 1;

        mark(obj.next);
    }
};

const STACK_MAX = 256;

pub fn newObject(allocator: std.mem.Allocator, vm: *VM, Otype: ObjTyp) !*Object {
    var object: *Object = try allocator.create(Object);

    switch (Otype) {
        .integer => {
            object = {
                .data.integer = 0;
            };
        },
        .pair => {
            object.data = {
                .pair.first = null;
                .pair.second = null;
            };
        },
    }
    object.next = vm.firstObject;
    vm.firstObject = object;
    return object;
}

const VM = struct {
    firstObject: ?*Object = null,
    stack: [STACK_MAX]*Object,

    stackSize: i32 = 0,

    pub fn init(allocator: std.mem.Allocator) !*VM {
        //var buffer: [1000]u8 = undefined;
        //var fba: std.heap.FixedBufferAllocator = .init(&buffer);
        //const allocator = fba.allocator();
        const vm: *VM = try allocator.create(VM);
        std.debug.print("{}", vm);
        return vm;
    }

    pub fn push(vm: *VM, obj: *Object) !void {
        assert(vm.stackSize < STACK_MAX);
        vm.stack[vm.stackSize] = obj;
        vm.stackSize += 1;
    }

    pub fn pop(vm: *VM) !*Object {
        assert(vm.stackSize > 0);
        const tempObj: **Object = &vm.stack[vm.stackSize];
        vm.stackSize -= 1;
        return *tempObj;
    }

    pub fn markAll() !void {}
};

pub fn main() !void {}
