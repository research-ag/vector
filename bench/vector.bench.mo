import Bench "mo:bench";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Vector "../src";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Vector vs Buffer vs Array");
    bench.description("Vector/Buffer add items one-by-one. Array uses tabulate.");

    bench.rows(["Vector", "Buffer", "Array"]);
    bench.cols(["10", "10000", "1000000"]);

    let vec = Vector.new<Nat>();
    let buf = Buffer.Buffer<Nat>(0);
    var arr = [] : [Nat];

    bench.runner(func(row, col) {
      let ?n = Nat.fromText(col);

      // Vector
      if (row == "Vector") {
        for (i in Iter.range(1, n)) {
          Vector.add(vec, i);
        };
      };

      // Buffer
      if (row == "Buffer") {
        for (i in Iter.range(1, n)) {
          buf.add(i);
        };
      };

      // Array
      if (row == "Array") {
        arr := Array.tabulate<Nat>(n, func(i) = i);
      };
    });

    bench;
  };
};
