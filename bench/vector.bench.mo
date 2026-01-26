import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Vector "../src";
import Prim "mo:prim";

module {
  type Schema = {
    name : Text;
    description : Text;
    rows : [Text];
    cols : [Text];
  };

  class BenchV1(schema : Schema, run : (Nat, Nat) -> ()) {
    public func getVersion() : Nat = 1;
    public func getSchema() : Schema = schema;
    public let runCell = run;

    // unused stuff just to satisfy types
    public func name(_ : Text) {};
    public func description(_ : Text) {};
    public func rows(_ : [Text]) {};
    public func cols(_ : [Text]) {};
    public func runner(_ : (Text, Text) -> ()) {};
    // end unused stuff
  };

  let nat = Prim.nat32ToNat;

  public func init() : BenchV1 {
    let schema : Schema = {
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
          Vector.add(vec, nat(i));
          i +%= 1;
        };
      };

      // Buffer
      if (ri == 1) {
        var i : Nat32 = 0; 
        while (i < n) {
          buf.add(nat(i));
          i +%= 1;
        };
      };

      // Array
      if (ri == 2) {
        arr := Array.tabulate<Nat>(nat(n), func(i) = i);
      };
    };

    BenchV1(schema, run);
  };
};
