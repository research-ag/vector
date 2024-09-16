import Vector "../src/lib";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Array "mo:base/Array";
import Iter "mo:base/Iter";

// Helper function to run tests
func runTest(name : Text, test : (Nat) -> Bool) {
  let testSizes = [0, 1, 10, 100];
  for (n in testSizes.vals()) {
    if (test(n)) {
      Debug.print("✅ " # name # " passed for n = " # Nat.toText(n));
    } else {
      Debug.trap("❌ " # name # " failed for n = " # Nat.toText(n));
    };
  };
};

// Test cases
func testNew(n : Nat) : Bool {
  let vec = Vector.new<Nat>();
  Vector.size(vec) == 0;
};

func testInit(n : Nat) : Bool {
  let vec = Vector.init<Nat>(n, 1);
  Vector.size(vec) == n and (n == 0 or (Vector.get(vec, 0) == 1 and Vector.get(vec, n - 1) == 1));
};

func testAdd(n : Nat) : Bool {
  let vec = Vector.new<Nat>();
  for (i in Iter.range(0, n - 1)) {
    Vector.add(vec, i);
  };
  Vector.size(vec) == n and (n == 0 or (Vector.get(vec, 0) == 0 and Vector.get(vec, n - 1) == n - 1));
};

func testAddMany(n : Nat) : Bool {
  let vec = Vector.new<Nat>();
  Vector.addMany(vec, n, 1);
  Vector.size(vec) == n and (n == 0 or (Vector.get(vec, 0) == 1 and Vector.get(vec, n - 1) == 1));
};

func testRemoveLast(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i));
  if (n == 0) {
    Vector.removeLast(vec) == null and Vector.size(vec) == 0;
  } else {
    let last = Vector.removeLast(vec);
    last == ?(n - 1) and Vector.size(vec) == n - 1 and (n == 1 or Vector.get(vec, n - 2) == n - 2);
  };
};

func testGet(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i));
  n == 0 or (Vector.get(vec, 0) == 0 and Vector.get(vec, n - 1) == n - 1);
};

func testGetOpt(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i));
  (n == 0 or (Vector.getOpt(vec, 0) == ?0 and Vector.getOpt(vec, n - 1) == ?(n - 1))) and
  Vector.getOpt(vec, n) == null;
};

func testPut(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i));
  if (n == 0) {
    true;
  } else {
    Vector.put(vec, n - 1, 100);
    Vector.get(vec, n - 1) == 100;
  };
};

func testClear(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i));
  Vector.clear(vec);
  Vector.size(vec) == 0;
};

func testClone(n : Nat) : Bool {
  let vec1 = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i));
  let vec2 = Vector.clone(vec1);
  Vector.equal(vec1, vec2, Nat.equal);
};

func testMap(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i));
  let mapped = Vector.map<Nat, Nat>(vec, func (x) = x * 2);
  Vector.equal(mapped, Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i * 2)), Nat.equal);
};

func testIndexOf(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(2 * n, func (i) = i % n));
  if (n == 0) {
    Vector.indexOf(0, vec, Nat.equal) == null;
  } else {
    var allCorrect = true;
    for (i in Iter.range(0, n - 1)) {
      let index = Vector.indexOf(i, vec, Nat.equal);
      if (index != ?i) {
        allCorrect := false;
        Debug.print("indexOf failed for i = " # Nat.toText(i) # ", expected ?" # Nat.toText(i) # ", got " # debug_show(index));
      };
    };
    allCorrect and Vector.indexOf(n, vec, Nat.equal) == null;
  };
};

func testLastIndexOf(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(2 * n, func (i) = i % n));
  if (n == 0) {
    Vector.lastIndexOf(0, vec, Nat.equal) == null;
  } else {
    var allCorrect = true;
    for (i in Iter.range(0, n - 1)) {
      let index = Vector.lastIndexOf(i, vec, Nat.equal);
      if (index != ?(n + i)) {
        allCorrect := false;
        Debug.print("lastIndexOf failed for i = " # Nat.toText(i) # ", expected ?" # Nat.toText(n + i) # ", got " # debug_show(index));
      };
    };
    allCorrect and Vector.lastIndexOf(n, vec, Nat.equal) == null;
  };
};

func testContains(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i));
  (n == 0 or Vector.contains(vec, n - 1, Nat.equal)) and not Vector.contains(vec, n, Nat.equal);
};

func testReverse(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i));
  Vector.reverse(vec);
  Vector.equal(vec, Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = n - 1 - i)), Nat.equal);
};

func testSort(n : Nat) : Bool {
  let vec = Vector.fromArray<Int>(Array.tabulate<Int>(n, func (i) = (i * 123) % 100 - 50));
  Vector.sort(vec, Int.compare);
  Vector.equal(vec, Vector.fromArray<Int>(Array.sort(Array.tabulate<Int>(n, func (i) = (i * 123) % 100 - 50), Int.compare)), Int.equal);
};

func testToArray(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i));
  Array.equal(Vector.toArray(vec), Array.tabulate<Nat>(n, func (i) = i), Nat.equal);
};

func testFromIter(n : Nat) : Bool {
  let iter = Iter.range(0, n - 1);
  let vec = Vector.fromIter<Nat>(iter);
  Vector.equal(vec, Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i)), Nat.equal);
};

func testFoldLeft(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i + 1));
  Vector.foldLeft<Text, Nat>(vec, "", func (acc, x) = acc # Nat.toText(x)) == Array.foldLeft<Nat, Text>(Array.tabulate<Nat>(n, func (i) = i + 1), "", func (acc, x) = acc # Nat.toText(x));
};

func testFoldRight(n : Nat) : Bool {
  let vec = Vector.fromArray<Nat>(Array.tabulate<Nat>(n, func (i) = i + 1));
  Vector.foldRight<Nat, Text>(vec, "", func (x, acc) = Nat.toText(x) # acc) == Array.foldRight<Nat, Text>(Array.tabulate<Nat>(n, func (i) = i + 1), "", func (x, acc) = Nat.toText(x) # acc);
};

// Run all tests
func runAllTests() {
  runTest("testNew", testNew);
  runTest("testInit", testInit);
  runTest("testAdd", testAdd);
  runTest("testAddMany", testAddMany);
  runTest("testRemoveLast", testRemoveLast);
  runTest("testGet", testGet);
  runTest("testGetOpt", testGetOpt);
  runTest("testPut", testPut);
  runTest("testClear", testClear);
  runTest("testClone", testClone);
  runTest("testMap", testMap);
  runTest("testIndexOf", testIndexOf);
  runTest("testLastIndexOf", testLastIndexOf);
  runTest("testContains", testContains);
  runTest("testReverse", testReverse);
  runTest("testSort", testSort);
  runTest("testToArray", testToArray);
  runTest("testFromIter", testFromIter);
  runTest("testFoldLeft", testFoldLeft);
  runTest("testFoldRight", testFoldRight);
};

// Run all tests
runAllTests();
