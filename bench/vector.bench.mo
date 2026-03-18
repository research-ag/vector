import Array "mo:core/Array";
import Buffer "mo:base/Buffer";
import _Nat32 "mo:core/Nat32";
import Vector "../src";
import Bench "mo:bench-helper";

module {
  public func init() : Bench.V1 {
    let schema : Bench.Schema = {
      name = "Vector vs Buffer vs Array Benchmark";
      description = "Vector/Buffer add items one-by-one. Array uses tabulate.";
      rows = ["Vector", "Buffer", "Array"];
      cols = ["10", "10000", "1000000"];
    };

    let vec = Vector.new<Nat>();
    let buf = Buffer.Buffer<Nat>(0);
    var arr = [] : [Nat];
    let ns : [Nat32] = [10, 10000, 1000000];

    func run(ri : Nat, ci : Nat) {
      let n = ns[ci];

      // Vector
      if (ri == 0) {
        var i : Nat32 = 0; 
        while (i < n) {
          Vector.add(vec, i.toNat());
          i +%= 1;
        };
      };

      // Buffer
      if (ri == 1) {
        var i : Nat32 = 0; 
        while (i < n) {
          buf.add(i.toNat());
          i +%= 1;
        };
      };

      // Array
      if (ri == 2) {
        arr := Array.tabulate<Nat>(n.toNat(), func(i) = i);
      };
    };

    Bench.V1(schema, run);
  };
};
