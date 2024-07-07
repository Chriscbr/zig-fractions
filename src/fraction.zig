const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub const FractionError = error{
    DenominatorCannotBeZero,
};

// TODO: to(comptime type T) T
// TODO: mutating floor(), ceil(), round()
// TODO: toFloor(), toCeil(), toRound()
// TODO: mutating add(), sub(), mul(), div(), pow()

// TODO: fromFloat()
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

    /// Returns the length of the string representation of the fraction.
    pub fn toStringBufferLen(self: *const Fraction) usize {
        var len: usize = 0;
        if (self.sign) {
            len += 1;
        }
        var num = self.num;
        if (num == 0) {
            len += 1;
        } else {
            while (num != 0) {
                len += 1;
                num /= 10;
            }
        }
        len += 1; // '/'
        var denom = self.denom;
        while (denom != 0) {
            len += 1;
            denom /= 10;
        }
        return len;
    }

    /// Converts the fraction to a string.
    /// Caller owns returned memory.
    /// See also `toString`, a lower level function than this.
    pub fn toStringAlloc(self: *const Fraction, allocator: Allocator, case: std.fmt.Case) Allocator.Error![]u8 {
        const string = try allocator.alloc(u8, self.toStringBufferLen());
        errdefer allocator.free(string);
        return allocator.realloc(string, self.toString(string, case));
    }

    /// Return the string representation of the fraction.
    /// `buf` is caller-provided memory for toString to use as a working area.
    /// It must have length at least `toStringBufferLen`.
    /// Returns the length of the string.
    pub fn toString(self: *const Fraction, buf: []u8, case: std.fmt.Case) usize {
        assert(self.denom != 0);
        var digits_len: usize = 0;

        if (self.sign) {
            buf[digits_len] = '-';
            digits_len += 1;
        }

        var num = self.num;
        if (num == 0) {
            buf[digits_len] = '0';
            digits_len += 1;
        } else {
            while (num != 0) {
                const digit: u8 = @intCast(num % 10);
                const ch = std.fmt.digitToChar(digit, case);
                buf[digits_len] = ch;
                digits_len += 1;
                num /= 10;
            }
            std.mem.reverse(u8, buf[@intFromBool(self.sign)..digits_len]);
        }

        buf[digits_len] = '/';
        digits_len += 1;

        var denom = self.denom;
        const denom_start = digits_len;
        while (denom != 0) {
            const digit: u8 = @intCast(denom % 10);
            const ch = std.fmt.digitToChar(digit, case);
            buf[digits_len] = ch;
            digits_len += 1;
            denom /= 10;
        }
        std.mem.reverse(u8, buf[denom_start..digits_len]);

        return digits_len;
    }

    /// To allow `std.fmt.format` to work with this type.
    pub fn format(
        self: *const Fraction,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        out_stream: anytype,
    ) !void {
        _ = options;
        const case = std.fmt.Case.lower;

        if (fmt.len == 0 or comptime std.mem.eql(u8, fmt, "d")) {
            // format as decimal
        } else {
            std.fmt.invalidFmtError(fmt, self);
        }

        // A usize can be at most max(u64) = 18446744073709551615 = 20 digits
        // So the maximum length of the string representation of a fraction is
        // 1 (sign) + 20 + 1 (slash) + 20 = 42
        var buf: [42]u8 = undefined;
        const len = self.toString(&buf, case);
        return out_stream.writeAll(buf[0..len]);
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

    /// Return a new fraction that is the negative.
    pub fn toNegation(self: *const Fraction) Fraction {
        return Fraction{ .num = self.num, .denom = self.denom, .sign = !self.sign };
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

    /// Returns true if the fraction is zero.
    pub fn eqlZero(self: *const Fraction) bool {
        return self.num == 0;
    }

    /// Simplify the fraction.
    pub fn simplify(self: *Fraction) void {
        const gcd = math.gcd(self.num, self.denom);
        self.num = @divExact(self.num, gcd);
        self.denom = @divExact(self.denom, gcd);
    }

    /// Return a new fraction that is the simplified version.
    pub fn toSimplified(self: *const Fraction) Fraction {
        const gcd = math.gcd(self.num, self.denom);
        return Fraction{ .num = @divExact(self.num, gcd), .denom = @divExact(self.denom, gcd), .sign = self.sign };
    }

    /// Returns `math.Order.lt`, `math.Order.eq`, `math.Order.gt` if `a < b`, `a == b` or `a > b` respectively.
    pub fn order(self: *const Fraction, other: *const Fraction) !math.Order {
        if (self.sign != other.sign) {
            if (eqlZero(self) and eqlZero(other)) {
                return .eq;
            } else {
                return if (self.sign) .lt else .gt;
            }
        } else {
            const r = try orderAbs(self, other);
            return if (!self.sign) r else switch (r) {
                .lt => math.Order.gt,
                .eq => math.Order.eq,
                .gt => math.Order.lt,
            };
        }
    }

    /// Returns `math.Order.lt`, `math.Order.eq`, `math.Order.gt` if
    /// `|a| < |b|`, `|a| == |b|`, or `|a| > |b|` respectively.
    pub fn orderAbs(self: *const Fraction, other: *const Fraction) !math.Order {
        // a/b < c/d <=> a*d < b*c
        const ad = try math.mul(usize, self.num, other.denom);
        const bc = try math.mul(usize, other.num, self.denom);
        return math.order(ad, bc);
    }

    /// Multiply another fraction to this fraction.
    /// The result is stored in this fraction.
    /// Returns an error if the result is not representable.
    pub fn mul(self: *Fraction, other: *const Fraction) !void {
        // a/b * c/d = a*c / b*d
        const num = try math.mul(usize, self.num, other.num);
        const denom = try math.mul(usize, self.denom, other.denom);
        self.num = num;
        self.denom = denom;
        self.sign = self.sign != other.sign;
        self.simplify();
    }
};

test {
    _ = @import("fraction_test.zig");
}
