const std = @import("std");
const testing = std.testing;
const print = std.debug.print;
const assert = std.debug.assert;

const h = @cImport({
    @cInclude("lua.h");
    @cInclude("lualib.h");
    @cInclude("lauxlib.h");
});

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

fn ok(val: c_int) void {
    assert(val == h.LUA_OK);
}
fn fine(val: bool) void {
    // !(lua*() != LUA_OK)
    assert(!val);
}

fn mul(L: ?*h.lua_State) callconv(.C) c_int {
    const a = h.luaL_checkinteger(L, 1);
    const b = h.luaL_checkinteger(L, 2);
    const c = a * b;
    // print("mul a={any}, b={any}, c={any}\n", .{a, b, c});
    h.lua_pushinteger(L, c);

    // why 1 not LUA_OK? the number of returned values
    return 1;
}

pub fn main() void {
    var L = h.luaL_newstate();
    defer h.lua_close(L);

    print("ok={any}\n", .{h.LUA_OK});

    h.luaL_openlibs(L);

    // hello world!
    if (true) {
        const code = "print('hello from lua!')";
        if (true) {
            fine(h.luaL_dostring(L, code));
        } else {
            ok(h.luaL_loadstring(L, code));
            ok(h.lua_pcall(L, 0, 0, 0));
        }
        h.lua_pop(L, h.lua_gettop(L));
    }

    // register global variable
    {
        h.lua_pushinteger(L, 42);
        h.lua_setglobal(L, "answer");
        fine(h.luaL_dostring(L, "print('What is the meaning of life, the universe and everything?', answer)"));
        h.lua_pop(L, h.lua_gettop(L));
    }

    // register global function
    {
        if (true) {
            h.lua_register(L, "mul", mul);
        } else {
            h.lua_pushcfunction(L, mul);
            h.lua_setglobal(L, "mul");
        }
        fine(h.luaL_dostring(L, "print(1, mul(7, 8))"));
        h.lua_pop(L, h.lua_gettop(L));
    }

    // register scoped functions
    if (true) {
        const mymod = [_]h.luaL_Reg{
            .{ .name = "mul", .func = mul },
            .{ .name = 0, .func = null },
        };
        print("mymode={any}, ptr={any}\n", .{ mymod, &mymod });
        h.luaL_register(L, "my", &mymod);

        fine(h.luaL_dostring(L, "print(2, my.mul(7, 8))"));
        h.lua_pop(L, h.lua_gettop(L));
    }

    // todo: register module
}
