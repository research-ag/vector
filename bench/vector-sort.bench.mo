import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Prim "mo:prim";
import Text "mo:base/Text";

import Vector "../src";

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

  public func init() : BenchV1 {
    let ns = [10, 100, 1_000, 10_000];

    let schema : Schema = {
      name = "Sorting Vector vs Buffer vs Array Benchmark";
      description = "In-place sorting of vector containing N Nat-s vs Array.sort vs Buffer.sort";
      rows = [
        "Sorted vector",
        "Sorted buffer",
        "Sorted array",
        "Sorted vector (reversed)",
        "Sorted buffer (reversed)",
        "Sorted array (reversed)",
        "Shuffled vector",
        "Shuffled buffer",
        "Shuffled array",
      ];
      cols = Array.map(ns, func(x) = Nat.toText(x));
    };

    let nCols = ns.size();

    let shuffledChunk = [8, 6, 9, 0, 4, 2, 3, 7, 1, 5];

    let arrayInput : [[[Nat]]] = Array.tabulate<[[Nat]]>(
      3,
      func(r : Nat) = Array.tabulate<[Nat]>(
        nCols,
        func(ci) {
          let n = ns[ci];
          let generator : (Nat) -> Nat = switch (r) {
            case (0) func i = i; // ordered
            case (1) func i = n - i - 1; // reversed
            case (2) func i = shuffledChunk[i % 10] + 10 ** shuffledChunk[(i / 10) % 10]; // shuffled
            case (_) Prim.trap("Row not implemented");
          };
          Array.tabulate<Nat>(n, generator);
        },
      ),
    );

    let bufferInput = Array.map(arrayInput, func x = Array.map(x, func y = Buffer.fromArray<Nat>(y))); 
    let vectorInput = Array.map(arrayInput, func x = Array.map(x, func y = Vector.fromArray<Nat>(y))); 

    func run(ri : Nat, ci : Nat) {
      switch (ri % 3) {
        case (0) {
          let vec = vectorInput[ri / 3][ci];
          Vector.sort(vec, Nat.compare);
        };
        case (1) {
          let buf = bufferInput[ri / 3][ci];
          buf.sort(Nat.compare);
        };
        case (2) {
          let arr = arrayInput[ri / 3][ci];
          ignore Array.sort<Nat>(arr, Nat.compare);
        };
        case (_) Prim.trap("Can never happen");
      };
    };

    BenchV1(schema, run);
  };
};
