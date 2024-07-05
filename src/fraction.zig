const std = @import("std");
const math = std.math;

pub const FractionError = error{
    DenominatorCannotBeZero,
};

// TODO: refactor implementation to store the numerator and
// denominator as unsigned values, and add a sign field.
// TODO: or better, allow numerator and denominator to be
// stored as any unsigned integer type

// TODO: toString()
// TODO: format()
// TODO: to(comptime type T) T
// TODO: mutating floor(), ceil(), round()
// TODO: toFloor(), toCeil(), toRound()
// TODO: eqlZero()
// TODO: order(), orderAbs()
// TODO: mutating add(), sub(), mul(), div(), pow()

// TODO: a way to create a Fraction from a float
// see: https://github.com/python/cpython/blob/6239d41527d5977aa5d44e4b894d719bc045860e/Objects/floatobject.c#L1556

pub const Fraction = struct {
    /// The numerator of the fraction.
    num: i32,

    /// The denominator of the fraction. Must not be zero.
    denom: i32,

    /// Initialize the fraction with the given numerator and denominator.
    /// The denominator must not be zero.
    pub fn init(num: i32, denom: i32) !Fraction {
        if (denom == 0) {
            return FractionError.DenominatorCannotBeZero;
        }
        return Fraction{ .num = num, .denom = denom };
    }

    /// Modify to become the absolute value.
    pub fn abs(self: *Fraction) !void {
        if (self.num < 0) {
            self.num = try math.sub(i32, 0, self.num);
        }
        if (self.denom < 0) {
            self.denom = try math.sub(i32, 0, self.denom);
        }
    }

    /// Return a new fraction that is the absolute value.
    pub fn toAbs(self: Fraction) Fraction {
        const num = if (self.num < 0) -self.num else self.num;
        const denom = if (self.denom < 0) -self.denom else self.denom;
        return Fraction{ .num = num, .denom = denom };
    }

    /// Modify to become the negative.
    pub fn negate(self: *Fraction) !void {
        if (self.denom > 0) {
            self.num = try math.sub(i32, 0, self.num);
        } else {
            self.denom = try math.sub(i32, 0, self.denom);
        }
    }

    /// Modify to become the reciprocal.
    pub fn reciprocal(self: *Fraction) !void {
        const tmp = self.num;
        self.num = self.denom;
        self.denom = tmp;
        if (self.denom == 0) {
            return FractionError.DenominatorCannotBeZero;
        }
    }

    /// Return a new fraction that is the reciprocal.
    pub fn toReciprocal(self: Fraction) !Fraction {
        const result = Fraction{ .num = self.denom, .denom = self.num };
        if (result.denom == 0) {
            return FractionError.DenominatorCannotBeZero;
        }
        return result;
    }

    /// Returns true if the two fractions are equal.
    pub fn eql(a: *const Fraction, b: *const Fraction) bool {
        return a.num * b.denom == b.num * a.denom;
    }

    /// Returns true if the two fractions are equal in absolute value.
    pub fn eqlAbs(a: *const Fraction, b: *const Fraction) !bool {
        const r1 = try math.mul(usize, @abs(a.num), @abs(b.denom));
        const r2 = try math.mul(usize, @abs(b.num), @abs(a.denom));
        return r1 == r2;
    }

    /// Simplify the fraction.
    pub fn simplify(self: *Fraction) void {
        const gcd_result: usize = std.math.gcd(@abs(self.num), @abs(self.denom));
        // Safe cast because GCD of two i32s is always <= 2147483647
        const gcd: i32 = @intCast(gcd_result);
        self.num = @divExact(self.num, gcd);
        self.denom = @divExact(self.denom, gcd);
        if (self.denom < 0) {
            self.num = -self.num;
            self.denom = -self.denom;
        }
    }
};

test {
    _ = @import("fraction_test.zig");
}
