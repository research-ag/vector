import Array "mo:base/Array";
import Bench "mo:bench";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Prim "mo:prim";
import Text "mo:base/Text";

import Vector "../src";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Sorting Vector vs Buffer vs Array");
    bench.description("In-place sorting of vector containing N Nat-s vs Array.sort vs Buffer.sort");

    let rows = [
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

    let cols = ["10", "100", "1000" /*, "1000000" */ ];

    bench.rows(rows);
    bench.cols(cols);

    let routines : [() -> ()] = Array.tabulate<() -> ()>(
      rows.size() * cols.size(),
      func(i) {
        let row : Nat = i % rows.size();
        let ?n = Nat.fromText(cols[i / rows.size()]) else Prim.trap("Cannot parse N");

        let shuffledChunk = [8, 6, 9, 0, 4, 2, 3, 7, 1, 5];
        let generator : (Nat) -> Nat = switch (row / 3) {
          case (0) func(i : Nat) = i;
          case (1) func(i : Nat) = n - i - 1;
          case (2) func(i : Nat) = shuffledChunk[i % 10] + 10**shuffledChunk[(i / 10) % 10];
          case (_) Prim.trap("Row not implemented");
        };

        switch (row % 3) {
          case (0) {
            Array.tabulate<Nat>(n, generator)
            |> Vector.fromArray<Nat>(_)
            |> (func() = Vector.sort(_, Nat.compare));
          };
          case (1) {
            let b = Buffer.Buffer<Nat>(n);
            for (i in Iter.range(0, n - 1)) {
              b.add(generator(i));
            };
            func() = b.sort(Nat.compare);
          };
          case (2) {
            Array.tabulate<Nat>(n, generator)
            |> (func() = ignore Array.sort<Nat>(_, Nat.compare));
          };
          case (_) Prim.trap("Can never happen");
        };
      },
    );

    bench.runner(
      func(row, col) {
        let ?ci = Array.indexOf<Text>(col, cols, Text.equal) else Prim.trap("Cannot determine column: " # col);
        let ?ri = Array.indexOf<Text>(row, rows, Text.equal) else Prim.trap("Cannot determine row: " # row);

        routines[ci * rows.size() + ri]();
      }
    );

    bench;
  };
};
