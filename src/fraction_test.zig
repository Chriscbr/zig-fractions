const std = @import("std");
const testing = std.testing;

const expect = testing.expect;
const expectEqual = testing.expectEqual;
const expectError = testing.expectError;

const Fraction = @import("Fraction.zig").Fraction;
const FractionError = @import("Fraction.zig").FractionError;

test "init" {
    const f = try Fraction.init(1, 2);
    try expectEqual(1, f.num);
    try expectEqual(2, f.denom);

    const err = Fraction.init(1, 0);
    try expectError(FractionError.DenominatorCannotBeZero, err);
}

test "abs" {
    var f1 = try Fraction.init(-1, 2);
    try f1.abs();
    try expectEqual(1, f1.num);
    try expectEqual(2, f1.denom);

    var f2 = try Fraction.init(1, -2);
    try f2.abs();
    try expectEqual(1, f2.num);
    try expectEqual(2, f2.denom);

    var f3 = try Fraction.init(-1, -2);
    try f3.abs();
    try expectEqual(1, f3.num);
    try expectEqual(2, f3.denom);

    var f4 = try Fraction.init(std.math.minInt(i32), 1);
    const err = f4.abs();
    try expectError(error.Overflow, err);
}

test "toAbs" {
    const f1 = try Fraction.init(-1, 2);
    const r1 = f1.toAbs();
    try expectEqual(1, r1.num);
    try expectEqual(2, r1.denom);

    const f2 = try Fraction.init(1, -2);
    const r2 = f2.toAbs();
    try expectEqual(1, r2.num);
    try expectEqual(2, r2.denom);

    const f3 = try Fraction.init(-1, -2);
    const r3 = f3.toAbs();
    try expectEqual(1, r3.num);
    try expectEqual(2, r3.denom);
}

test "negate" {
    var f1 = try Fraction.init(1, 2);
    try f1.negate();
    try expectEqual(-1, f1.num);
    try expectEqual(2, f1.denom);

    var f2 = try Fraction.init(-1, 2);
    try f2.negate();
    try expectEqual(1, f2.num);
    try expectEqual(2, f2.denom);

    var f3 = try Fraction.init(std.math.minInt(i32), 1);
    const err = f3.negate();
    try expectError(error.Overflow, err);
}

test "reciprocal" {
    var f1 = try Fraction.init(1, 2);
    try f1.reciprocal();
    try expectEqual(2, f1.num);
    try expectEqual(1, f1.denom);

    var f2 = try Fraction.init(0, 1);
    const err = f2.reciprocal();
    try expectError(FractionError.DenominatorCannotBeZero, err);
}

test "toReciprocal" {
    const f1 = try Fraction.init(1, 2);
    const r = try f1.toReciprocal();
    try expectEqual(2, r.num);
    try expectEqual(1, r.denom);

    const f2 = try Fraction.init(0, 1);
    const err = f2.toReciprocal();
    try expectError(FractionError.DenominatorCannotBeZero, err);
}

test "eql" {
    const f1 = try Fraction.init(1, 2);
    const f2 = try Fraction.init(-2, -4);
    try expect(Fraction.eql(&f1, &f2));
}

test "eqlAbs" {
    const f1 = try Fraction.init(1, 2);
    const f2 = try Fraction.init(-2, 4);
    try expect(try Fraction.eqlAbs(&f1, &f2));

    const f3 = try Fraction.init(std.math.maxInt(i32), std.math.minInt(i32));
    const f4 = try Fraction.init(std.math.minInt(i32), std.math.maxInt(i32));
    try expect(!try Fraction.eqlAbs(&f3, &f4));
}

test "simplify" {
    var f1 = try Fraction.init(-4, -6);
    f1.simplify();
    try expectEqual(2, f1.num);
    try expectEqual(3, f1.denom);

    var f2 = try Fraction.init(4, -6);
    f2.simplify();
    try expectEqual(-2, f2.num);
    try expectEqual(3, f2.denom);
}
