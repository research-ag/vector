import Vector "../src/lib";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

import Prim "mo:⛔";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Order "mo:base/Order";

let { run; test; suite } = Suite;

func unwrap<T>(x : ?T) : T = switch (x) {
  case (?v) v;
  case (_) Prim.trap "internal error in unwrap()";
};

let n = 100;
var vector = Vector.new<Nat>();

let sizes = Buffer.Buffer<Nat>(0);
for (i in Iter.range(0, n)) {
  sizes.add(Vector.size(vector));
  Vector.add(vector, i);
};
sizes.add(Vector.size(vector));

class OrderTestable(initItem : Order.Order) : T.TestableItem<Order.Order> {
  public let item = initItem;
  public func display(order : Order.Order) : Text {
    switch (order) {
      case (#less) {
        "#less";
      };
      case (#greater) {
        "#greater";
      };
      case (#equal) {
        "#equal";
      };
    };
  };
  public let equals = Order.equal;
};

run(
  suite(
    "clone",
    [
      test(
        "clone",
        Vector.toArray(Vector.clone(vector)),
        M.equals(T.array(T.natTestable, Vector.toArray(vector))),
      ),
    ],
  )
);

run(
  suite(
    "add",
    [
      test(
        "sizes",
        Buffer.toArray(sizes),
        M.equals(T.array(T.natTestable, Iter.toArray(Iter.range(0, n + 1)))),
      ),
      test(
        "elements",
        Vector.toArray(vector),
        M.equals(T.array(T.natTestable, Iter.toArray(Iter.range(0, n)))),
      ),
    ],
  )
);

assert Vector.indexOf(n + 1, vector, Nat.equal) == null;
assert Vector.firstIndexWith(vector, func(a : Nat) : Bool = a == n + 1) == null;
assert Vector.indexOf(n, vector, Nat.equal) == ?n;
assert Vector.firstIndexWith(vector, func(a : Nat) : Bool = a == n) == ?n;

assert Vector.lastIndexOf(n + 1, vector, Nat.equal) == null;
assert Vector.lastIndexWith(vector, func(a : Nat) : Bool = a == n + 1) == null;

assert Vector.lastIndexOf(0, vector, Nat.equal) == ?0;
assert Vector.lastIndexWith(vector, func(a : Nat) : Bool = a == 0) == ?0;

assert Vector.forAll(vector, func(x : Nat) : Bool = 0 <= x and x <= n);
assert Vector.forNone(vector, func(x : Nat) : Bool = x == n + 1);
assert Vector.forSome(vector, func(x : Nat) : Bool = x == n / 2);

run(
  suite(
    "iterator",
    [
      test(
        "elements",
        Iter.toArray(Vector.vals(vector)),
        M.equals(T.array(T.natTestable, Iter.toArray(Iter.range(0, n)))),
      ),
      test(
        "revElements",
        Iter.toArray(Vector.valsRev(vector)),
        M.equals(T.array(T.intTestable, Iter.toArray(Iter.revRange(n, 0)))),
      ),
      test(
        "keys",
        Iter.toArray(Vector.keys(vector)),
        M.equals(T.array(T.natTestable, Iter.toArray(Iter.range(0, n)))),
      ),
      test(
        "items1",
        Iter.toArray(Iter.map<(Nat, Nat), Nat>(Vector.items(vector), func((a, b)) { a })),
        M.equals(T.array(T.natTestable, Iter.toArray(Iter.range(0, n)))),
      ),
      test(
        "items2",
        Iter.toArray(Iter.map<(Nat, Nat), Nat>(Vector.items(vector), func((a, b)) { b })),
        M.equals(T.array(T.natTestable, Iter.toArray(Iter.range(0, n)))),
      ),
      test(
        "itemsRev1",
        Iter.toArray(Iter.map<(Nat, Nat), Nat>(Vector.itemsRev(vector), func((a, b)) { a })),
        M.equals(T.array(T.intTestable, Iter.toArray(Iter.revRange(n, 0)))),
      ),
      test(
        "itemsRev2",
        Iter.toArray(Iter.map<(Nat, Nat), Nat>(Vector.itemsRev(vector), func((a, b)) { b })),
        M.equals(T.array(T.intTestable, Iter.toArray(Iter.revRange(n, 0)))),
      ),
    ],
  )
);

let for_add_many = Vector.init<Nat>(n, 0);
Vector.addMany(for_add_many, n, 0);

let for_add_iter = Vector.init<Nat>(n, 0);
Vector.addFromIter(for_add_iter, Array.init<Nat>(n, 0).vals());

run(
  suite(
    "init",
    [
      test(
        "init with toArray",
        Vector.toArray(Vector.init<Nat>(n, 0)),
        M.equals(T.array(T.natTestable, Array.tabulate<Nat>(n, func(_) = 0))),
      ),
      test(
        "init with vals",
        Iter.toArray(Vector.vals(Vector.init<Nat>(n, 0))),
        M.equals(T.array(T.natTestable, Array.tabulate<Nat>(n, func(_) = 0))),
      ),
      test(
        "add many with toArray",
        Vector.toArray(for_add_many),
        M.equals(T.array(T.natTestable, Array.tabulate<Nat>(2 * n, func(_) = 0))),
      ),
      test(
        "add many with vals",
        Iter.toArray(Vector.vals(for_add_many)),
        M.equals(T.array(T.natTestable, Array.tabulate<Nat>(2 * n, func(_) = 0))),
      ),
      test(
        "addFromIter",
        Vector.toArray(for_add_iter),
        M.equals(T.array(T.natTestable, Array.tabulate<Nat>(2 * n, func(_) = 0))),
      ),
    ],
  )
);

for (i in Iter.range(0, n)) {
  Vector.put(vector, i, n - i : Nat);
};

run(
  suite(
    "put",
    [
      test(
        "size",
        Vector.size(vector),
        M.equals(T.nat(n + 1)),
      ),
      test(
        "elements",
        Vector.toArray(vector),
        M.equals(T.array(T.intTestable, Iter.toArray(Iter.revRange(n, 0)))),
      ),
    ],
  )
);

let removed = Buffer.Buffer<Nat>(0);
for (i in Iter.range(0, n)) {
  removed.add(unwrap(Vector.removeLast(vector)));
};

run(
  suite(
    "removeLast",
    [
      test(
        "size",
        Vector.size(vector),
        M.equals(T.nat(0)),
      ),
      test(
        "elements",
        Buffer.toArray(removed),
        M.equals(T.array(T.natTestable, Iter.toArray(Iter.range(0, n)))),
      ),
    ],
  )
);

for (i in Iter.range(0, n)) {
  Vector.add(vector, i);
};

run(
  suite(
    "addAfterRemove",
    [
      test(
        "elements",
        Vector.toArray(vector),
        M.equals(T.array(T.natTestable, Iter.toArray(Iter.range(0, n)))),
      ),
    ],
  )
);

run(
  suite(
    "firstAndLast",
    [
      test(
        "first",
        [Vector.first(vector)],
        M.equals(T.array(T.natTestable, [0])),
      ),
      test(
        "last of len N",
        [Vector.last(vector)],
        M.equals(T.array(T.natTestable, [n])),
      ),
      test(
        "last of len 1",
        [Vector.last(Vector.init<Nat>(1, 1))],
        M.equals(T.array(T.natTestable, [1])),
      ),
    ],
  )
);

var sumN = 0;
Vector.iterate<Nat>(vector, func(i) { sumN += i });
var sumRev = 0;
Vector.iterateRev<Nat>(vector, func(i) { sumRev += i });
var sum1 = 0;
Vector.iterate<Nat>(Vector.init<Nat>(1, 1), func(i) { sum1 += i });
var sum0 = 0;
Vector.iterate<Nat>(Vector.new<Nat>(), func(i) { sum0 += i });

run(
  suite(
    "iterate",
    [
      test(
        "sumN",
        [sumN],
        M.equals(T.array(T.natTestable, [n * (n + 1) / 2])),
      ),
      test(
        "sumRev",
        [sumRev],
        M.equals(T.array(T.natTestable, [n * (n + 1) / 2])),
      ),
      test(
        "sum1",
        [sum1],
        M.equals(T.array(T.natTestable, [1])),
      ),
      test(
        "sum0",
        [sum0],
        M.equals(T.array(T.natTestable, [0])),
      ),
    ],
  )
);

/* --------------------------------------- */

var sumItems = 0;
Vector.iterateItems<Nat>(vector, func(i, x) { sumItems += i + x });
var sumItemsRev = 0;
Vector.iterateItems<Nat>(vector, func(i, x) { sumItemsRev += i + x });

run(
  suite(
    "iterateItems",
    [
      test(
        "sumItems",
        [sumItems],
        M.equals(T.array(T.natTestable, [n * (n + 1)])),
      ),
      test(
        "sumItemsRev",
        [sumItemsRev],
        M.equals(T.array(T.natTestable, [n * (n + 1)])),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.fromArray<Nat>([0, 1, 2, 3, 4, 5]);

run(
  suite(
    "contains",
    [
      test(
        "true",
        Vector.contains<Nat>(vector, 2, Nat.equal),
        M.equals(T.bool(true)),
      ),
      test(
        "true",
        Vector.contains<Nat>(vector, 9, Nat.equal),
        M.equals(T.bool(false)),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.new<Nat>();

run(
  suite(
    "contains empty",
    [
      test(
        "true",
        Vector.contains<Nat>(vector, 2, Nat.equal),
        M.equals(T.bool(false)),
      ),
      test(
        "true",
        Vector.contains<Nat>(vector, 9, Nat.equal),
        M.equals(T.bool(false)),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.fromArray<Nat>([2, 1, 10, 1, 0, 3]);

run(
  suite(
    "max",
    [
      test(
        "return value",
        Vector.max<Nat>(vector, Nat.compare),
        M.equals(T.optional(T.natTestable, ?10)),
      )
    ],
  )
);

/* --------------------------------------- */

vector := Vector.fromArray<Nat>([2, 1, 10, 1, 0, 3, 0]);

run(
  suite(
    "min",
    [
      test(
        "return value",
        Vector.min<Nat>(vector, Nat.compare),
        M.equals(T.optional(T.natTestable, ?0)),
      )
    ],
  )
);

/* --------------------------------------- */

vector := Vector.fromArray<Nat>([0, 1, 2, 3, 4, 5]);

var vector2 = Vector.fromArray<Nat>([0, 1, 2]);

run(
  suite(
    "equal",
    [
      test(
        "empty vectors",
        Vector.equal<Nat>(Vector.new<Nat>(), Vector.new<Nat>(), Nat.equal),
        M.equals(T.bool(true)),
      ),
      test(
        "non-empty vectors",
        Vector.equal<Nat>(vector, Vector.clone(vector), Nat.equal),
        M.equals(T.bool(true)),
      ),
      test(
        "non-empty and empty vectors",
        Vector.equal<Nat>(vector, Vector.new<Nat>(), Nat.equal),
        M.equals(T.bool(false)),
      ),
      test(
        "non-empty vectors mismatching lengths",
        Vector.equal<Nat>(vector, vector2, Nat.equal),
        M.equals(T.bool(false)),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.fromArray<Nat>([0, 1, 2, 3, 4, 5]);
vector2 := Vector.fromArray<Nat>([0, 1, 2]);

var vector3 = Vector.fromArray<Nat>([2, 3, 4, 5]);

run(
  suite(
    "compare",
    [
      test(
        "empty vectors",
        Vector.compare<Nat>(Vector.new<Nat>(), Vector.new<Nat>(), Nat.compare),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "non-empty vectors equal",
        Vector.compare<Nat>(vector, Vector.clone(vector), Nat.compare),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "non-empty and empty vectors",
        Vector.compare<Nat>(vector, Vector.new<Nat>(), Nat.compare),
        M.equals(OrderTestable(#greater)),
      ),
      test(
        "non-empty vectors mismatching lengths",
        Vector.compare<Nat>(vector, vector2, Nat.compare),
        M.equals(OrderTestable(#greater)),
      ),
      test(
        "non-empty vectors lexicographic difference",
        Vector.compare<Nat>(vector, vector3, Nat.compare),
        M.equals(OrderTestable(#less)),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.fromArray<Nat>([0, 1, 2, 3, 4, 5]);

run(
  suite(
    "toText",
    [
      test(
        "empty vector",
        Vector.toText<Nat>(Vector.new<Nat>(), Nat.toText),
        M.equals(T.text("[]")),
      ),
      test(
        "singleton vector",
        Vector.toText<Nat>(Vector.make<Nat>(3), Nat.toText),
        M.equals(T.text("[3]")),
      ),
      test(
        "non-empty vector",
        Vector.toText<Nat>(vector, Nat.toText),
        M.equals(T.text("[0, 1, 2, 3, 4, 5]")),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6, 7]);
vector2 := Vector.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]);
vector3 := Vector.new<Nat>();

var vector4 = Vector.make<Nat>(3);

Vector.reverse<Nat>(vector);
Vector.reverse<Nat>(vector2);
Vector.reverse<Nat>(vector3);
Vector.reverse<Nat>(vector4);

run(
  suite(
    "reverse",
    [
      test(
        "even elements",
        Vector.toArray(vector),
        M.equals(T.array(T.natTestable, [7, 6, 5, 4, 3, 2, 1, 0])),
      ),
      test(
        "odd elements",
        Vector.toArray(vector2),
        M.equals(T.array(T.natTestable, [6, 5, 4, 3, 2, 1, 0])),
      ),
      test(
        "empty",
        Vector.toArray(vector3),
        M.equals(T.array(T.natTestable, [] : [Nat])),
      ),
      test(
        "singleton",
        Vector.toArray(vector4),
        M.equals(T.array(T.natTestable, [3])),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.reversed<Nat>(Vector.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6, 7]));
vector2 := Vector.reversed<Nat>(Vector.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]));
vector3 := Vector.reversed<Nat>(Vector.new<Nat>());
vector4 := Vector.reversed<Nat>(Vector.make<Nat>(3));

run(
  suite(
    "reversed",
    [
      test(
        "even elements",
        Vector.toArray(vector),
        M.equals(T.array(T.natTestable, [7, 6, 5, 4, 3, 2, 1, 0])),
      ),
      test(
        "odd elements",
        Vector.toArray(vector2),
        M.equals(T.array(T.natTestable, [6, 5, 4, 3, 2, 1, 0])),
      ),
      test(
        "empty",
        Vector.toArray(vector3),
        M.equals(T.array(T.natTestable, [] : [Nat])),
      ),
      test(
        "singleton",
        Vector.toArray(vector4),
        M.equals(T.array(T.natTestable, [3])),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]);

run(
  suite(
    "foldLeft",
    [
      test(
        "return value",
        Vector.foldLeft<Text, Nat>(vector, "", func(acc, x) = acc # Nat.toText(x)),
        M.equals(T.text("0123456")),
      ),
      test(
        "return value empty",
        Vector.foldLeft<Text, Nat>(Vector.new<Nat>(), "", func(acc, x) = acc # Nat.toText(x)),
        M.equals(T.text("")),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]);

run(
  suite(
    "foldRight",
    [
      test(
        "return value",
        Vector.foldRight<Nat, Text>(vector, "", func(x, acc) = acc # Nat.toText(x)),
        M.equals(T.text("6543210")),
      ),
      test(
        "return value empty",
        Vector.foldRight<Nat, Text>(Vector.new<Nat>(), "", func(x, acc) = acc # Nat.toText(x)),
        M.equals(T.text("")),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.make<Nat>(2);

run(
  suite(
    "isEmpty",
    [
      test(
        "true",
        Vector.isEmpty(Vector.new<Nat>()),
        M.equals(T.bool(true)),
      ),
      test(
        "false",
        Vector.isEmpty(vector),
        M.equals(T.bool(false)),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.fromArray<Nat>([0, 1, 2, 3, 4, 5, 6]);

run(
  suite(
    "map",
    [
      test(
        "map",
        Vector.toArray(Vector.map<Nat, Text>(vector, Nat.toText)),
        M.equals(T.array(T.textTestable, ["0", "1", "2", "3", "4", "5", "6"])),
      ),
      test(
        "empty",
        Vector.isEmpty(Vector.map<Nat, Text>(Vector.new<Nat>(), Nat.toText)),
        M.equals(T.bool(true)),
      ),
    ],
  )
);

/* --------------------------------------- */

vector := Vector.fromArray<Nat>([8, 6, 9, 10, 0, 4, 2, 3, 7, 1, 5]);

run(
  suite(
    "sort",
    [
      test(
        "sort",
        Vector.sort<Nat>(vector, Nat.compare) |> Vector.toArray(vector),
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10] |> M.equals(T.array(T.natTestable, _)),
      ),
    ],
  )
);

/* --------------------------------------- */

func locate_readable<X>(index : Nat) : (Nat, Nat) {
  // index is any Nat32 except for
  // blocks before super block s == 2 ** s
  let i = Nat32.fromNat(index);
  // element with index 0 located in data block with index 1
  if (i == 0) {
    return (1, 0);
  };
  let lz = Nat32.bitcountLeadingZero(i);
  // super block s = bit length - 1 = (32 - leading zeros) - 1
  // i in binary = zeroes; 1; bits blocks mask; bits element mask
  // bit lengths =     lz; 1;     floor(s / 2);       ceil(s / 2)
  let s = 31 - lz;
  // floor(s / 2)
  let down = s >> 1;
  // ceil(s / 2) = floor((s + 1) / 2)
  let up = (s + 1) >> 1;
  // element mask = ceil(s / 2) ones in binary
  let e_mask = 1 << up - 1;
  //block mask = floor(s / 2) ones in binary
  let b_mask = 1 << down - 1;
  // data blocks in even super blocks before current = 2 ** ceil(s / 2)
  // data blocks in odd super blocks before current = 2 ** floor(s / 2)
  // data blocks before the super block = element mask + block mask
  // elements before the super block = 2 ** s
  // first floor(s / 2) bits in index after the highest bit = index of data block in super block
  // the next ceil(s / 2) to the end of binary representation of index + 1 = index of element in data block
  (Nat32.toNat(e_mask + b_mask + 2 + (i >> up) & b_mask), Nat32.toNat(i & e_mask));
};

// this was optimized in terms of instructions
func locate_optimal<X>(index : Nat) : (Nat, Nat) {
  // super block s = bit length - 1 = (32 - leading zeros) - 1
  // blocks before super block s == 2 ** s
  let i = Nat32.fromNat(index);
  let lz = Nat32.bitcountLeadingZero(i);
  let lz2 = lz >> 1;
  // we split into cases to apply different optimizations in each one
  if (lz & 1 == 0) {
    // ceil(s / 2)  = 16 - lz2
    // floor(s / 2) = 15 - lz2
    // i in binary = zeroes; 1; bits blocks mask; bits element mask
    // bit lengths =     lz; 1;         15 - lz2;          16 - lz2
    // blocks before = 2 ** ceil(s / 2) + 2 ** floor(s / 2)

    // so in order to calculate index of the data block
    // we need to shift i by 16 - lz2 and set bit with number 16 - lz2, bit 15 - lz2 is already set

    // element mask = 2 ** (16 - lz2) = (1 << 16) >> lz2 = 0xFFFF >> lz2
    let mask = 0xFFFF >> lz2;
    (Nat32.toNat(((i << lz2) >> 16) ^ (0x10000 >> lz2)), Nat32.toNat(i & (0xFFFF >> lz2)));
  } else {
    // s / 2 = ceil(s / 2) = floor(s / 2) = 15 - lz2
    // i in binary = zeroes; 1; bits blocks mask; bits element mask
    // bit lengths =     lz; 1;         15 - lz2;          15 - lz2
    // block mask = element mask = mask = 2 ** (s / 2) - 1 = 2 ** (15 - lz2) - 1 = (1 << 15) >> lz2 = 0x7FFF >> lz2
    // blocks before = 2 * 2 ** (s / 2)

    // so in order to calculate index of the data block
    // we need to shift i by 15 - lz2, set bit with number 16 - lz2 and unset bit 15 - lz2

    let mask = 0x7FFF >> lz2;
    (Nat32.toNat(((i << lz2) >> 15) ^ (0x18000 >> lz2)), Nat32.toNat(i & (0x7FFF >> lz2)));
  };
};

let locate_n = 1_000;
var i = 0;
while (i < locate_n) {
  assert (locate_readable(i) == locate_optimal(i));
  assert (locate_readable(1_000_000 + i) == locate_optimal(1_000_000 + i));
  assert (locate_readable(1_000_000_000 + i) == locate_optimal(1_000_000_000 + i));
  assert (locate_readable(2_000_000_000 + i) == locate_optimal(2_000_000_000 + i));
  assert (locate_readable(2 ** 32 - 1 - i : Nat) == locate_optimal(2 ** 32 - 1 - i : Nat));
  i += 1;
};
