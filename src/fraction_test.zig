const std = @import("std");
const math = std.math;
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

test "fromFloat" {
    const f1 = try Fraction.fromFloat(@as(f64, 2.5));
    try expectEqual(5, f1.num);
    try expectEqual(2, f1.denom);
    try expectEqual(false, f1.sign);

    const f2 = try Fraction.fromFloat(@as(f64, -0.0));
    try expectEqual(0, f2.num);
    try expectEqual(1, f2.denom);
    try expectEqual(false, f2.sign);

    const f3 = try Fraction.fromFloat(@as(f64, -123));
    try expectEqual(123, f3.num);
    try expectEqual(1, f3.denom);
    try expectEqual(true, f3.sign);

    const err1 = Fraction.fromFloat(math.inf(f64));
    try expectError(FractionError.CannotConvertFloat, err1);

    const err2 = Fraction.fromFloat(math.nan(f64));
    try expectError(FractionError.CannotConvertFloat, err2);
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

test "toNegation" {
    const f1 = try Fraction.init(3, 6, false);
    const r1 = f1.toNegation();
    try expectEqual(3, r1.num);
    try expectEqual(6, r1.denom);
    try expectEqual(true, r1.sign);

    const f2 = try Fraction.init(3, 6, true);
    const r2 = f2.toNegation();
    try expectEqual(3, r2.num);
    try expectEqual(6, r2.denom);
    try expectEqual(false, r2.sign);
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

test "eqlZero" {
    const f1 = try Fraction.init(0, 1, false);
    try expect(f1.eqlZero());

    const f2 = try Fraction.init(1, 2, false);
    try expect(!f2.eqlZero());
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

test "toSimplified" {
    const f1 = try Fraction.init(4, 6, false);
    const r1 = f1.toSimplified();
    try expectEqual(2, r1.num);
    try expectEqual(3, r1.denom);
    try expectEqual(false, r1.sign);

    const f2 = try Fraction.init(4, 6, true);
    const r2 = f2.toSimplified();
    try expectEqual(2, r2.num);
    try expectEqual(3, r2.denom);
    try expectEqual(true, r2.sign);
}

test "order" {
    const f1 = try Fraction.init(1, 2, false);
    const f2 = try Fraction.init(1, 3, false);
    try expect(try f1.order(&f2) == std.math.Order.gt);
    try expect(try f2.order(&f1) == std.math.Order.lt);
    try expect(try f1.order(&f1) == std.math.Order.eq);

    const f3 = try Fraction.init(1, 2, true);
    try expect(try f1.order(&f3) == std.math.Order.gt);
    try expect(try f3.order(&f1) == std.math.Order.lt);
    try expect(try f3.order(&f3) == std.math.Order.eq);

    const f4 = try Fraction.init(0, 1, false);
    const f5 = try Fraction.init(0, 2, true);
    try expect(try f4.order(&f5) == std.math.Order.eq);
    try expect(try f5.order(&f4) == std.math.Order.eq);
    try expect(try f4.order(&f4) == std.math.Order.eq);
    try expect(try f5.order(&f5) == std.math.Order.eq);
}

test "add" {
    // 1/2 + 1/3 = 5/6
    var f1 = try Fraction.init(1, 2, false);
    const f2 = try Fraction.init(1, 3, false);
    try f1.add(&f2);
    try expectEqual(5, f1.num);
    try expectEqual(6, f1.denom);
    try expectEqual(false, f1.sign);

    // 1/2 + -1/3 = 1/6
    var f3 = try Fraction.init(1, 2, false);
    const f4 = try Fraction.init(1, 3, true);
    try f3.add(&f4);
    try expectEqual(1, f3.num);
    try expectEqual(6, f3.denom);
    try expectEqual(false, f3.sign);

    // -1/2 + 1/3 = -1/6
    var f5 = try Fraction.init(1, 2, true);
    const f6 = try Fraction.init(1, 3, false);
    try f5.add(&f6);
    try expectEqual(1, f5.num);
    try expectEqual(6, f5.denom);
    try expectEqual(true, f5.sign);

    // -1/2 + -1/3 = -5/6
    var f7 = try Fraction.init(1, 2, true);
    const f8 = try Fraction.init(1, 3, true);
    try f7.add(&f8);
    try expectEqual(5, f7.num);
    try expectEqual(6, f7.denom);
    try expectEqual(true, f7.sign);

    // 1/3 + 1/2 = 5/6
    var f9 = try Fraction.init(1, 3, false);
    const f10 = try Fraction.init(1, 2, false);
    try f9.add(&f10);
    try expectEqual(5, f9.num);
    try expectEqual(6, f9.denom);
    try expectEqual(false, f9.sign);

    // 1/3 + -1/2 = -1/6
    var f11 = try Fraction.init(1, 3, false);
    const f12 = try Fraction.init(1, 2, true);
    try f11.add(&f12);
    try expectEqual(1, f11.num);
    try expectEqual(6, f11.denom);
    try expectEqual(true, f11.sign);

    // -1/3 + 1/2 = 1/6
    var f13 = try Fraction.init(1, 3, true);
    const f14 = try Fraction.init(1, 2, false);
    try f13.add(&f14);
    try expectEqual(1, f13.num);
    try expectEqual(6, f13.denom);
    try expectEqual(false, f13.sign);

    // -1/3 + -1/2 = -5/6
    var f15 = try Fraction.init(1, 3, true);
    const f17 = try Fraction.init(1, 2, true);
    try f15.add(&f17);
    try expectEqual(5, f15.num);
    try expectEqual(6, f15.denom);
    try expectEqual(true, f15.sign);

    var f18 = try Fraction.init(1, 2, false);
    try f18.add(&f18);
    try expectEqual(1, f18.num);
    try expectEqual(1, f18.denom);
    try expectEqual(false, f18.sign);
}

test "sub" {
    // 1/2 - 1/3 = 1/6
    var f1 = try Fraction.init(1, 2, false);
    const f2 = try Fraction.init(1, 3, false);
    try f1.sub(&f2);
    try expectEqual(1, f1.num);
    try expectEqual(6, f1.denom);
    try expectEqual(false, f1.sign);

    // 1/2 - -1/3 = 5/6
    var f3 = try Fraction.init(1, 2, false);
    const f4 = try Fraction.init(1, 3, true);
    try f3.sub(&f4);
    try expectEqual(5, f3.num);
    try expectEqual(6, f3.denom);
    try expectEqual(false, f3.sign);

    // -1/2 - 1/3 = -5/6
    var f5 = try Fraction.init(1, 2, true);
    const f6 = try Fraction.init(1, 3, false);
    try f5.sub(&f6);
    try expectEqual(5, f5.num);
    try expectEqual(6, f5.denom);
    try expectEqual(true, f5.sign);

    // -1/2 - -1/3 = -1/6
    var f7 = try Fraction.init(1, 2, true);
    const f8 = try Fraction.init(1, 3, true);
    try f7.sub(&f8);
    try expectEqual(1, f7.num);
    try expectEqual(6, f7.denom);
    try expectEqual(true, f7.sign);

    // 1/3 - 1/2 = -1/6
    var f9 = try Fraction.init(1, 3, false);
    const f10 = try Fraction.init(1, 2, false);
    try f9.sub(&f10);
    try expectEqual(1, f9.num);
    try expectEqual(6, f9.denom);
    try expectEqual(true, f9.sign);

    // 1/3 - -1/2 = 5/6
    var f11 = try Fraction.init(1, 3, false);
    const f12 = try Fraction.init(1, 2, true);
    try f11.sub(&f12);
    try expectEqual(5, f11.num);
    try expectEqual(6, f11.denom);
    try expectEqual(false, f11.sign);

    // -1/3 - 1/2 = -5/6
    var f13 = try Fraction.init(1, 3, true);
    const f14 = try Fraction.init(1, 2, false);
    try f13.sub(&f14);
    try expectEqual(5, f13.num);
    try expectEqual(6, f13.denom);
    try expectEqual(true, f13.sign);

    // -1/3 - -1/2 = 1/6
    var f15 = try Fraction.init(1, 3, true);
    const f17 = try Fraction.init(1, 2, true);
    try f15.sub(&f17);
    try expectEqual(1, f15.num);
    try expectEqual(6, f15.denom);
    try expectEqual(false, f15.sign);

    var f18 = try Fraction.init(1, 2, true);
    try f18.sub(&f18);
    try expectEqual(0, f18.num);
    try expectEqual(1, f18.denom);
    try expectEqual(false, f18.sign);
}

test "mul" {
    var f1 = try Fraction.init(1, 2, false);
    const f2 = try Fraction.init(3, 5, false);
    try f1.mul(&f2);
    try expectEqual(3, f1.num);
    try expectEqual(10, f1.denom);

    var f3 = try Fraction.init(1, 2, true);
    try f3.mul(&f3);
    try expectEqual(1, f3.num);
    try expectEqual(4, f3.denom);
    try expectEqual(false, f3.sign);
}

test "div" {
    var f1 = try Fraction.init(1, 2, false);
    const f2 = try Fraction.init(3, 5, false);
    try f1.div(&f2);
    try expectEqual(5, f1.num);
    try expectEqual(6, f1.denom);

    var f3 = try Fraction.init(1, 2, true);
    try f3.div(&f3);
    try expectEqual(1, f3.num);
    try expectEqual(1, f3.denom);
    try expectEqual(false, f3.sign);

    var f4 = try Fraction.init(1, 2, false);
    const f5 = try Fraction.init(0, 1, false);
    const err = f4.div(&f5);
    try expectError(FractionError.DivisionByZero, err);
}
