const std = @import("std");
const math = std.math;

pub const FractionError = error{
    DenominatorCannotBeZero,
};

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
    num: usize,

    /// The denominator of the fraction.
    denom: usize,

    /// The sign bit of the fraction. True if the fraction is negative.
    sign: bool,

    /// Initialize the fraction. The sign bit is true if the fraction is negative.
    /// The denominator must not be zero.
    pub fn init(num: usize, denom: usize, sign: bool) !Fraction {
        if (denom == 0) {
            return FractionError.DenominatorCannotBeZero;
        }
        return Fraction{ .num = num, .denom = denom, .sign = sign };
    }

    /// Modify to become the absolute value.
    pub fn abs(self: *Fraction) void {
        if (self.sign == true) {
            self.sign = false;
        }
    }

    /// Return a new fraction that is the absolute value.
    pub fn toAbs(self: Fraction) Fraction {
        return Fraction{ .num = self.num, .denom = self.denom, .sign = false };
    }

    /// Modify to become the negative.
    pub fn negate(self: *Fraction) void {
        self.sign = !self.sign;
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
        const result = Fraction{ .num = self.denom, .denom = self.num, .sign = self.sign };
        if (result.denom == 0) {
            return FractionError.DenominatorCannotBeZero;
        }
        return result;
    }

    /// Returns true if the two fractions are equal.
    pub fn eql(a: *const Fraction, b: *const Fraction) !bool {
        const r1 = try math.mul(usize, a.num, b.denom);
        const r2 = try math.mul(usize, b.num, a.denom);
        return a.sign == b.sign and r1 == r2;
    }

    /// Returns true if the two fractions are equal in absolute value.
    pub fn eqlAbs(a: *const Fraction, b: *const Fraction) !bool {
        const r1 = try math.mul(usize, a.num, b.denom);
        const r2 = try math.mul(usize, b.num, a.denom);
        return r1 == r2;
    }

    /// Simplify the fraction.
    pub fn simplify(self: *Fraction) void {
        const gcd = std.math.gcd(self.num, self.denom);
        self.num = @divExact(self.num, gcd);
        self.denom = @divExact(self.denom, gcd);
    }
};

test {
    _ = @import("fraction_test.zig");
}
