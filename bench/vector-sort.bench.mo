import Array "mo:core/Array";
import Buffer "mo:base/Buffer";
import Nat "mo:core/Nat";
import Bench "mo:bench-helper";

import Vector "../src";

module {
  public func init() : Bench.V1 {
    let ns = [10, 100, 1_000, 10_000];

    let schema : Bench.Schema = {
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
      cols = Array.map(ns, func(x) = x.toText());
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
            case (_) func i = shuffledChunk[i % 10] + 10 ** shuffledChunk[(i / 10) % 10]; // shuffled
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
        case (_) {
          let arr = arrayInput[ri / 3][ci];
          ignore Array.sort<Nat>(arr, Nat.compare);
        };
      };
    };

    Bench.V1(schema, run);
  };
};
