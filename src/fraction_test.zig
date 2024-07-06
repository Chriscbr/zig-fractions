const std = @import("std");
const testing = std.testing;

const expect = testing.expect;
const expectEqual = testing.expectEqual;
const expectError = testing.expectError;

const Fraction = @import("Fraction.zig").Fraction;
const FractionError = @import("Fraction.zig").FractionError;

test "init" {
    const f = try Fraction.init(1, 2, false);
    try expectEqual(1, f.num);
    try expectEqual(2, f.denom);
    try expectEqual(false, f.sign);

    const err = Fraction.init(1, 0, false);
    try expectError(FractionError.DenominatorCannotBeZero, err);
}

test "toString" {
    const f1 = try Fraction.init(1, 2, false);
    const f1s = try f1.toStringAlloc(testing.allocator, .lower);
    defer testing.allocator.free(f1s);
    try expect(std.mem.eql(u8, "1/2", f1s));

    const f2 = try Fraction.init(0, 10, false);
    const f2s = try f2.toStringAlloc(testing.allocator, .lower);
    defer testing.allocator.free(f2s);
    try expect(std.mem.eql(u8, "0/10", f2s));

    const f3 = try Fraction.init(123, 456, true);
    const f3s = try f3.toStringAlloc(testing.allocator, .lower);
    defer testing.allocator.free(f3s);
    try expect(std.mem.eql(u8, "-123/456", f3s));
}

test "format" {
    const f1 = try Fraction.init(123, 456, true);
    const f1_fmt = try std.fmt.allocPrintZ(testing.allocator, "{d}", .{f1});
    defer testing.allocator.free(f1_fmt);
    try expect(std.mem.eql(u8, "-123/456", f1_fmt));

    // TODO: this test might fail on 32-bit systems
    const f2 = try Fraction.init(std.math.maxInt(usize) - 1, std.math.maxInt(usize), true);
    const f2_fmt = try std.fmt.allocPrintZ(testing.allocator, "{d}", .{f2});
    defer testing.allocator.free(f2_fmt);
    try expect(std.mem.eql(u8, "-18446744073709551614/18446744073709551615", f2_fmt));
}

test "abs" {
    var f1 = try Fraction.init(1, 2, false);
    f1.abs();
    try expectEqual(1, f1.num);
    try expectEqual(2, f1.denom);
    try expectEqual(false, f1.sign);

    var f2 = try Fraction.init(1, 2, true);
    f2.abs();
    try expectEqual(1, f2.num);
    try expectEqual(2, f2.denom);
    try expectEqual(false, f2.sign);
}

test "toAbs" {
    const f1 = try Fraction.init(1, 2, false);
    const r1 = f1.toAbs();
    try expectEqual(1, r1.num);
    try expectEqual(2, r1.denom);
    try expectEqual(false, r1.sign);

    const f2 = try Fraction.init(1, 2, true);
    const r2 = f2.toAbs();
    try expectEqual(1, r2.num);
    try expectEqual(2, r2.denom);
    try expectEqual(false, r2.sign);
}

test "negate" {
    var f1 = try Fraction.init(1, 2, false);
    f1.negate();
    try expectEqual(1, f1.num);
    try expectEqual(2, f1.denom);
    try expectEqual(true, f1.sign);

    var f2 = try Fraction.init(1, 2, true);
    f2.negate();
    try expectEqual(1, f2.num);
    try expectEqual(2, f2.denom);
    try expectEqual(false, f2.sign);
}

test "reciprocal" {
    var f1 = try Fraction.init(1, 2, false);
    try f1.reciprocal();
    try expectEqual(2, f1.num);
    try expectEqual(1, f1.denom);
    try expectEqual(false, f1.sign);

    var f2 = try Fraction.init(0, 1, false);
    const err = f2.reciprocal();
    try expectError(FractionError.DenominatorCannotBeZero, err);
}

test "toReciprocal" {
    const f1 = try Fraction.init(1, 2, false);
    const r = try f1.toReciprocal();
    try expectEqual(2, r.num);
    try expectEqual(1, r.denom);
    try expectEqual(false, r.sign);

    const f2 = try Fraction.init(0, 1, false);
    const err = f2.toReciprocal();
    try expectError(FractionError.DenominatorCannotBeZero, err);
}

test "eql" {
    const f1 = try Fraction.init(1, 2, false);
    const f2 = try Fraction.init(3, 6, false);
    try expect(try Fraction.eql(&f1, &f2));

    const f3 = try Fraction.init(3, 6, true);
    try expect(!try Fraction.eql(&f1, &f3));

    const f4 = try Fraction.init(std.math.maxInt(usize), std.math.maxInt(usize), false);
    const f5 = try Fraction.init(std.math.maxInt(usize) - 1, std.math.maxInt(usize) - 1, false);
    const err = Fraction.eql(&f4, &f5);
    try expectError(error.Overflow, err);
}

test "eqlAbs" {
    const f1 = try Fraction.init(1, 2, false);
    const f2 = try Fraction.init(2, 4, false);
    try expect(try Fraction.eqlAbs(&f1, &f2));

    const f3 = try Fraction.init(4, 6, false);
    const f4 = try Fraction.init(2, 3, true);
    try expect(try Fraction.eqlAbs(&f3, &f4));
}

test "simplify" {
    var f1 = try Fraction.init(4, 6, false);
    f1.simplify();
    try expectEqual(2, f1.num);
    try expectEqual(3, f1.denom);
    try expectEqual(false, f1.sign);

    var f2 = try Fraction.init(4, 6, true);
    f2.simplify();
    try expectEqual(2, f2.num);
    try expectEqual(3, f2.denom);
    try expectEqual(true, f2.sign);
}
