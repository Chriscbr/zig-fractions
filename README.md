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

## Contributing

Pull requests are welcome.
