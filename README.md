# zig-fractions

A Zig library for performing math with fractions, where each fraction is represented by a pair of integers.

Compatible with Zig 0.13 stable.

## Installation

First, run the following:

```
zig fetch --save git+https://github.com/Chriscbr/zig-fractions
```

Then add the following to build.zig:

```zig
const zig_fractions = b.dependency("zig-fractions", .{});
exe.root_module.addImport("zig-fractions", zig_fractions.module("zig-fractions"));
```

Then you can use the library in your Zig project:

```zig
const Fraction = @import("zig-fractions").Fraction;

var f1 = try Fraction.fromFloat(@as(f32, 2.5));
const f2 = try Fraction.init(1, 5, false);
try f1.mul(&f2); // 2.5 * 1/5 = 1/2
std.debug.print("{}\n", .{f1}); // "1/2"
```

## Contributing

Pull requests are welcome.
