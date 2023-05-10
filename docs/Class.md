# Class
Class wrapper around the static Vector type

This allows to use VectorClass as a drop-in replacement of Buffer

We provide all the functions of Buffer except for:
- sort
- insertBuffer
- insert
- append
- reserve
- capacity
- filterEntries
- remove

## Class `Vector<X>`

``` motoko no-repl
class Vector<X>()
```

Constructs an empty `Vector<X>`.

Example:
```motoko

let vec = Vector.Vector<Nat>();
```
Runtime: `O(1)`

Space: `O(1)`

### Function `size`
``` motoko no-repl
func size() : Nat
```

Returns the current number of elements in the vec.

Example:
```motoko

let vec = Vector.Vector<Nat>();
vec.size() // => 0
```

Runtime: `O(1)`

Space: `O(1)`


### Function `add`
``` motoko no-repl
func add(x : X)
```

Adds a single element to the end of the vector, adding datablocks if capacity is exceeded.

Example:
```motoko

let vec = Vector.Vector<Nat>();

vec.add(0); // add 0 to vector
vec.add(1);
vec.add(2);
vec.add(3);
Vector.toArray(vec) // => [0, 1, 2, 3]
```

Amortized Runtime: `O(1)`, Worst Case Runtime: `O(sqrt(n))`

Amortized Space: `O(1)`, Worst Case Space: `O(sqrt(n))`


### Function `addMany`
``` motoko no-repl
func addMany(count : Nat, x : X)
```

Adds a single element to the end of the vector multiple number of times.

Example:
```motoko

let vec = Vector.Vector<Nat>();

vec.add(0); // add 0 to vector
vec.add(1);
vec.add(2);
vec.addMany(2, 3);
Vector.toArray(vec) // => [0, 1, 2, 3, 3]
```

Amortized Runtime: `O(count)`, Worst Case Runtime: `O(max(sqrt(n), count))`

Amortized Space: `O(count)`, Worst Case Space: `O(max(sqrt(n), count))`


### Function `get`
``` motoko no-repl
func get(i : Nat) : X
```

Returns the element at index `index`. Indexing is zero-based.
Traps if `index >= size`, error message may not be descriptive.

Example:
```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.add(11);
vec.get(0); // => 10
```

Runtime: `O(1)`

Space: `O(1)`


### Function `getOpt`
``` motoko no-repl
func getOpt(i : Nat) : ?X
```

Returns the element at index `index` as an option.
Returns `null` when `index >= size`. Indexing is zero-based.

Example:
```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.add(11);
let x = vec.getOpt(0); // => ?10
let y = vec.getOpt(2); // => null
```

Runtime: `O(1)`

Space: `O(1)`


### Function `put`
``` motoko no-repl
func put(i : Nat, x : X)
```

Overwrites the current element at `index` with `element`. Traps if
`index` >= size. Indexing is zero-based.

Example:
```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.put(0, 20); // overwrites 10 at index 0 with 20
Vector.toArray(buffer) // => [20]
```

Runtime: `O(1)`

Space: `O(1)`


### Function `removeLast`
``` motoko no-repl
func removeLast() : ?X
```

Removes and returns the last item in the buffer or `null` if
the buffer is empty.

Example:
```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.add(11);
vec.removeLast(); // => ?11
```

Amortized Runtime: `O(1)`, Worst Case Runtime: `O(n)`

Amortized Space: `O(1)`, Worst Case Space: `O(n)`


### Function `clear`
``` motoko no-repl
func clear()
```

Resets the buffer. Capacity is set to 0.

Example:
```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.add(11);
vec.add(12);
vec.clear(); // vector is now empty
Vector.toArray(vec) // => []
```

Runtime: `O(1)`

Space: `O(1)`


### Function `vals`
``` motoko no-repl
func vals() : { next : () -> ?X }
```

Returns an Iterator (`Iter`) over the elements of this vec.
Iterator provides a single method `next()`, which returns
elements in order, or `null` when out of elements to iterate over.

```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.add(11);
vec.add(12);

var sum = 0;
for (element in vec.vals()) {
  sum += element;
};
sum // => 33
```

Runtime: `O(1)`

Space: `O(1)`


### Function `keys`
``` motoko no-repl
func keys() : { next : () -> ?Nat }
```

Returns an Iterator (`Iter`) over the keys (indices) of a Vector.
Iterator provides a single method `next()`, which returns
elements in order, or `null` when out of elements to iterate over.

```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.add(11);
vec.add(12);
Iter.toArray(vec.keys()); // [0, 1, 2]
```

Note: This does not create a snapshot. If the returned iterator is not consumed at once,
and instead the consumption of the iterator is interleaved with other operations on the
Vector, then this may lead to unexpected results.

Runtime: `O(1)`


### Function `items`
``` motoko no-repl
func items() : { next : () -> ?(X, Nat) }
```

Returns an Iterator (`Iter`) over the items, i.e. pairs of value and index of a Vector.
Iterator provides a single method `next()`, which returns
elements in order, or `null` when out of elements to iterate over.

```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.add(11);
vec.add(12);
Iter.toArray(vec.items()); // [(10, 0), (11, 1), (12, 2)]
```

Note: This does not create a snapshot. If the returned iterator is not consumed at once,
and instead the consumption of the iterator is interleaved with other operations on the
Vector, then this may lead to unexpected results.

Runtime: `O(1)`

Warning: Allocates memory on the heap to store ?(X, Nat).


### Function `valsRev`
``` motoko no-repl
func valsRev() : { next : () -> ?X }
```

Returns an Iterator (`Iter`) over the elements of a Vector in reverse order.
Iterator provides a single method `next()`, which returns
elements in reverse order, or `null` when out of elements to iterate over.

```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.add(11);
vec.add(12);

var sum = 0;
for (element in vec.vals()) {
  sum += element;
};
sum // => 33
```

Note: This does not create a snapshot. If the returned iterator is not consumed at once,
and instead the consumption of the iterator is interleaved with other operations on the
Vector, then this may lead to unexpected results.

Runtime: `O(1)`


### Function `itemsRev`
``` motoko no-repl
func itemsRev() : { next : () -> ?(X, Nat) }
```

Returns an Iterator (`Iter`) over the items in reverse order, i.e. pairs of value and index of a Vector.
Iterator provides a single method `next()`, which returns
elements in reverse order, or `null` when out of elements to iterate over.

```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.add(11);
vec.add(12);
Iter.toArray(vec.items()); // [(12, 0), (11, 1), (10, 2)]
```

Note: This does not create a snapshot. If the returned iterator is not consumed at once,
and instead the consumption of the iterator is interleaved with other operations on the
Vector, then this may lead to unexpected results.

Runtime: `O(1)`

Warning: Allocates memory on the heap to store ?(X, Nat).


### Function `share`
``` motoko no-repl
func share() : Static.Vector<X>
```

Returns stable version of the vector

Example:
```motoko

let vec = Vector.Vector<Nat>();
vec.unshare(vec.share()); // Unchanged
```

Runtime: `O(1)`.


### Function `unshare`
``` motoko no-repl
func unshare(v_ : Static.Vector<X>)
```

Creates vector from a stable version.

Example:
```motoko

let vec = Vector.Vector<Nat>();
vec.unshare(vec.share()); // Unchanged
```

Runtime: `O(1)`.

## Function `first`
``` motoko no-repl
func first<X>(vec : Vector<X>) : X
```

Returns the first element of `vec`. Traps if `vec` is empty.

Example:
```motoko

let vec = Vector.Vector<Nat>();
vec.add(1);

Vector.first(vec); // => 1
```

Runtime: `O(1)`

Space: `O(1)`

## Function `last`
``` motoko no-repl
func last<X>(vec : Vector<X>) : X
```

Returns the last element of `vec`. Traps if `vec` is empty.

Example:
```motoko

let vec = Vector.Vector<Nat>();
vec.add(1);

Vector.last(vec); // => 1
```

Runtime: `O(1)`

Space: `O(1)`

## Function `iterate`
``` motoko no-repl
func iterate<X>(vec : Vector<X>, f : X -> ())
```

Applies `f` to each element in `vec`.

Example:
```motoko

let vec = Vector.fromArray<Nat>([1, 2, 3]);

Vector.iterate<Nat>(vec, func (x) {
  Debug.print(Nat.toText(x)); // prints each element in vector
});
```

Runtime: `O(size)`

Space: `O(size)`

*Runtime and space assumes that `f` runs in `O(1)` time and space.

## Function `iterateItems`
``` motoko no-repl
func iterateItems<X>(vec : Vector<X>, f : (Nat, X) -> ())
```

Applies `f` to each item `(i, x)` in `vec` where `i` is the key
and `x` is the value.

Example:
```motoko

import Nat "mo:base/Nat";
import Debug "mo:base/Debug";

let vec = Vector.fromArray<Nat>([1, 2, 3]);

Vector.iterateItems<Nat>(vec, func (i,x) {
  // prints each item (i,x) in vector
  Debug.print(Nat.toText(i) # Nat.toText(x));
});
```

Runtime: `O(size)`

Space: `O(size)`

*Runtime and space assumes that `f` runs in O(1) time and space.

## Function `iterateItemsRev`
``` motoko no-repl
func iterateItemsRev<X>(vec : Vector<X>, f : (Nat, X) -> ())
```

Like `iterateItems` but iterates through the vector in reverse order,
from end to beginning.

Example:
```motoko

import Nat "mo:base/Nat";
import Debug "mo:base/Debug";

let vec = Vector.fromArray<Nat>([1, 2, 3]);

Vector.iterateItemsRev<Nat>(vec, func (i,x) {
  // prints each item (i,x) in vector
  Debug.print(Nat.toText(i) # Nat.toText(x)); 
});
```

Runtime: `O(size)`

Space: `O(size)`

*Runtime and space assumes that `f` runs in O(1) time and space.

## Function `iterateRev`
``` motoko no-repl
func iterateRev<X>(vec : Vector<X>, f : X -> ())
```

Applies `f` to each element in `vec` in reverse order.

Example:
```motoko

let vec = Vector.fromArray<Nat>([1, 2, 3]);

Vector.iterate<Nat>(vec, func (x) {
  Debug.print(Nat.toText(x)); // prints each element in vector in reverse order
});
```

Runtime: `O(size)`

Space: `O(size)`

*Runtime and space assumes that `f` runs in `O(1)` time and space.

## Function `toArray`
``` motoko no-repl
func toArray<X>(vec : Vector<X>) : [X]
```

Creates an immutable array containing elements from a Vector.

Example:
```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.add(11);
vec.add(12);

Vector.toArray<Nat>(vec); // => [1, 2, 3]
```

Runtime: `O(size)`

## Function `toVarArray`
``` motoko no-repl
func toVarArray<X>(vec : Vector<X>) : [var X]
```

Creates a mutable array containing elements from a Vector.

Example:
```motoko

let vec = Vector.Vector<Nat>();

vec.add(10);
vec.add(11);
vec.add(12);

Vector.toVarArray<Nat>(vec); // => [1, 2, 3]
```

Runtime: `O(size)`

## Function `indexOf`
``` motoko no-repl
func indexOf<X>(element : X, vec : Vector<X>, equal : (X, X) -> Bool) : ?Nat
```

Finds the first index of `element` in `vector` using equality of elements defined
by `equal`. Returns `null` if `element` is not found.

Example:
```motoko

let vec = Vector.Vector<Nat>();

vec.add(1);
vec.add(2);
vec.add(3);
vec.add(4);

Vector.indexOf<Nat>(3, vec, Nat.equal); // => ?2
```

Runtime: `O(size)`

*Runtime and space assumes that `equal` runs in `O(1)` time and space.

## Function `lastIndexOf`
``` motoko no-repl
func lastIndexOf<X>(element : X, vec : Vector<X>, equal : (X, X) -> Bool) : ?Nat
```

Finds the last index of `element` in `vec` using equality of elements defined
by `equal`. Returns `null` if `element` is not found.

Example:
```motoko

let vec = Vector.Vector<Nat>();

vec.add(1);
vec.add(2);
vec.add(3);
vec.add(4);
vec.add(2);
vec.add(2);

Vector.lastIndexOf<Nat>(2, vec, Nat.equal); // => ?5
```

Runtime: `O(size)`

*Runtime and space assumes that `equal` runs in `O(1)` time and space.

## Function `init`
``` motoko no-repl
func init<X>(size : Nat, initValue : X) : Vector<X>
```

Create a Vector with `size` copies of the initial value.

```motoko

let vec = Vector.init<Nat>(4, 2); // [2, 2, 2, 2]
```

Runtime: `O(size)`

## Function `fromArray`
``` motoko no-repl
func fromArray<X>(array : [X]) : Vector<X>
```

Creates a Vector containing elements from an Array.

Example:
```motoko

import Nat "mo:base/Nat";

let array = [2, 3];

let vec = Vector.fromArray<Nat>(array); // => [2, 3]
```

Runtime: `O(size)`

## Function `fromVarArray`
``` motoko no-repl
func fromVarArray<X>(array : [var X]) : Vector<X>
```

Creates a Vector containing elements from a mutable Array.

Example:
```motoko

import Nat "mo:base/Nat";

let array = [var 2, 3];

let vec = Vector.fromVarArray<Nat>(array); // => [2, 3]
```

Runtime: `O(size)`

## Function `clone`
``` motoko no-repl
func clone<X>(vec : Vector<X>) : Vector<X>
```

Returns a copy of a Vector, with the same size.

Example:
```motoko

let vec = Vector.Vector<Nat>();
vec.add(1);

let clone = Vector.clone(vec);
Vector.toArray(clone); // => [1]
```

Runtime: `O(size)`

## Function `fromIter`
``` motoko no-repl
func fromIter<X>(iter : Iter.Iter<X>) : Vector<X>
```

Creates a Vector containing elements from `iter`.

Example:
```motoko

import Nat "mo:base/Nat";

let array = [1, 1, 1];
let iter = array.vals();

let vec = Vector.fromIter<Nat>(iter); // => [1, 1, 1]
```

Runtime: `O(size)`

## Function `addFromIter`
``` motoko no-repl
func addFromIter<X>(vec : Vector<X>, iter : Iter.Iter<X>)
```

Adds elements to a Vector from `iter`.

Example:
```motoko

import Nat "mo:base/Nat";

let array = [1, 1, 1];
let iter = array.vals();
let vec = Vector.init<Nat>(1, 2);

let vec = Vector.addFromIter<Nat>(vec, iter); // => [2, 1, 1, 1]
```

Runtime: `O(size)`, where n is the size of iter.

## Function `make`
``` motoko no-repl
func make<X>(element : X) : Vector<X>
```

Returns a new vector with capacity and size 1, containing `element`.

Example:
```motoko

import Nat "mo:base/Nat";

let vec = Vector.make<Nat>(1);
Vector.toText<Nat>(vec, Nat.toText); // => "[1]"
```

Runtime: `O(1)`

Space: `O(1)`

## Function `toText`
``` motoko no-repl
func toText<X>(vec : Vector<X>, toText_fn : X -> Text) : Text
```

Creates a textual representation of `vector`, using `toText` to recursively
convert the elements into Text.

Example:
```motoko

import Nat "mo:base/Nat";

let vec = Vector.fromArray<Nat>([1,2,3,4]);

Vector.toText<Nat>(vec, Nat.toText); // => "[1, 2, 3, 4]"
```

Runtime: `O(size)`

Space: `O(size)`

*Runtime and space assumes that `toText` runs in O(1) time and space.

## Function `firstIndexWith`
``` motoko no-repl
func firstIndexWith<X>(vec : Vector<X>, predicate : X -> Bool) : ?Nat
```

Finds the index of the first element in `vec` for which `predicate` is true.
Returns `null` if no such element is found.

Example:
```motoko

let vec = Vector.new<Nat>();
vec.add(1);
vec.add(2);
vec.add(3);
vec.add(4);

Vector.firstIndexWith<Nat>(vec, func(i) { i % 2 == 0 }); // => ?1
```

Runtime: `O(size)`

*Runtime and space assumes that `predicate` runs in `O(1)` time and space.

## Function `lastIndexWith`
``` motoko no-repl
func lastIndexWith<X>(vec : Vector<X>, predicate : X -> Bool) : ?Nat
```

Finds the index of the last element in `vec` for which `predicate` is true.
Returns `null` if no such element is found.

Example:
```motoko

let vec = Vector.new<Nat>();
vec.add(1);
vec.add(2);
vec.add(3);
vec.add(4);

Vector.lastIndexWith<Nat>(vec, func(i) { i % 2 == 0 }); // => ?3
```

Runtime: `O(size)`

*Runtime and space assumes that `predicate` runs in `O(1)` time and space.

## Function `forAll`
``` motoko no-repl
func forAll<X>(vec : Vector<X>, predicate : X -> Bool) : Bool
```

Returns true iff every element in `vec` satisfies `predicate`.
In particular, if `vec` is empty the function returns `true`.

Example:
```motoko

Vector.add(vec, 2);
Vector.add(vec, 3);
Vector.add(vec, 4);

Vector.forAll<Nat>(vec, func x { x > 1 }); // => true
```

Runtime: `O(size)`

Space: `O(1)`

*Runtime and space assumes that `predicate` runs in O(1) time and space.

## Function `forSome`
``` motoko no-repl
func forSome<X>(vec : Vector<X>, predicate : X -> Bool) : Bool
```

Returns true iff some element in `vec` satisfies `predicate`.
In particular, if `vec` is empty the function returns `false`.

Example:
```motoko

Vector.add(vec, 2);
Vector.add(vec, 3);
Vector.add(vec, 4);

Vector.forSome<Nat>(vec, func x { x > 3 }); // => true
```

Runtime: `O(size)`

Space: `O(1)`

*Runtime and space assumes that `predicate` runs in O(1) time and space.

## Function `forNone`
``` motoko no-repl
func forNone<X>(vec : Vector<X>, predicate : X -> Bool) : Bool
```

Returns true iff no element in `vec` satisfies `predicate`.
This is logically equivalent to that all elements in `vec` satisfy `not predicate`.
In particular, if `vec` is empty the function returns `true`.

Example:
```motoko

Vector.add(vec, 2);
Vector.add(vec, 3);
Vector.add(vec, 4);

Vector.forNone<Nat>(vec, func x { x == 0 }); // => true
```

Runtime: `O(size)`

Space: `O(1)`

*Runtime and space assumes that `predicate` runs in O(1) time and space.

## Function `contains`
``` motoko no-repl
func contains<X>(vec : Vector<X>, element : X, equal : (X, X) -> Bool) : Bool
```

Returns true if Vector contains element with respect to equality
defined by `equal`.


Example:
```motoko

import Nat "mo:base/Nat";

Vector.add(vec, 2);
Vector.add(vec, 0);
Vector.add(vec, 3);

Vector.contains<Nat>(vec, 2, Nat.equal); // => true
```

Runtime: `O(size)`

Space: `O(1)`

*Runtime and space assumes that `equal` runs in O(1) time and space.

## Function `max`
``` motoko no-repl
func max<X>(vec : Vector<X>, compare : (X, X) -> Order.Order) : ?X
```

Finds the greatest element in `vec` defined by `compare`.
Returns `null` if `vec` is empty.


Example:
```motoko

import Nat "mo:base/Nat";

Vector.add(vec, 1);
Vector.add(vec, 2);

Vector.max<Nat>(vec, Nat.compare); // => ?2
```

Runtime: `O(size)`

Space: `O(1)`

*Runtime and space assumes that `compare` runs in O(1) time and space.

## Function `min`
``` motoko no-repl
func min<X>(vec : Vector<X>, compare : (X, X) -> Order.Order) : ?X
```

Finds the least element in `vec` defined by `compare`.
Returns `null` if `vec` is empty.

Example:
```motoko

import Nat "mo:base/Nat";

Vector.add(vec, 1);
Vector.add(vec, 2);

Vector.min<Nat>(vec, Nat.compare); // => ?1
```

Runtime: `O(size)`

Space: `O(1)`

*Runtime and space assumes that `compare` runs in O(1) time and space.

## Function `equal`
``` motoko no-repl
func equal<X>(vec1 : Vector<X>, vec2 : Vector<X>, equal : (X, X) -> Bool) : Bool
```

Defines equality for two vectors, using `equal` to recursively compare elements in the
vectors. Returns true iff the two vectors are of the same size, and `equal`
evaluates to true for every pair of elements in the two vectors of the same
index.


Example:
```motoko

import Nat "mo:base/Nat";

let vec1 = Vector.fromArray<Nat>([1,2]);
let vec2 = Vector.new<Nat>();
vec2.add(1);
vec2.add(2);

Vector.equal<Nat>(vec1, vec2, Nat.equal); // => true
```

Runtime: `O(size)`

Space: `O(1)`

*Runtime and space assumes that `equal` runs in O(1) time and space.

## Function `compare`
``` motoko no-repl
func compare<X>(vec1 : Vector<X>, vec2 : Vector<X>, compare_fn : (X, X) -> Order.Order) : Order.Order
```

Defines comparison for two vectors, using `compare` to recursively compare elements in the
vectors. Comparison is defined lexicographically.


Example:
```motoko

import Nat "mo:base/Nat";

let vec1 = Vector.fromArray<Nat>([1,2]);
let vec2 = Vector.new<Nat>();
vec2.add(1);
vec2.add(2);

Vector.compare<Nat>(vec1, vec2, Nat.compare); // => #less
```

Runtime: `O(size)`

Space: `O(1)`

*Runtime and space assumes that `compare` runs in O(1) time and space.

## Function `reverse`
``` motoko no-repl
func reverse<X>(vec : Vector<X>)
```

Reverses the order of elements in `vec` by overwriting in place.

Example:
```motoko

import Nat "mo:base/Nat";

let vec = Vector.fromArray<Nat>([1,2,3]);

Vector.reverse<Nat>(vec);
Vector.toText<Nat>(vec, Nat.toText); // => "[3, 2, 1]"
```

Runtime: `O(size)`

Space: `O(1)`

## Function `reversed`
``` motoko no-repl
func reversed<X>(vec : Vector<X>) : Vector<X>
```

Reverses the order of elements in `vec` and returns a new
Vector.

Example:
```motoko

import Nat "mo:base/Nat";

let vec = Vector.fromArray<Nat>([1,2,3]);

let rvec = Vector.reversed<Nat>(vec);
Vector.toText<Nat>(rvec, Nat.toText); // => "[3, 2, 1]"
```

Runtime: `O(size)`

Space: `O(1)`

## Function `isEmpty`
``` motoko no-repl
func isEmpty<X>(vec : Vector<X>) : Bool
```

Returns true if and only if the vector is empty.

Example:
```motoko

let vec = Vector.fromArray<Nat>([2,0,3]);
Vector.isEmpty<Nat>(vec); // => false
```

Runtime: `O(1)`

Space: `O(1)`

## Function `foldLeft`
``` motoko no-repl
func foldLeft<A, X>(vec : Vector<X>, base : A, combine : (A, X) -> A) : A
```

Collapses the elements in `vec` into a single value by starting with `base`
and progessively combining elements into `base` with `combine`. Iteration runs
left to right.

Example:
```motoko

import Nat "mo:base/Nat";

let vec = Vector.fromArray<Nat>([1,2,3]);

Vector.foldLeft<Text, Nat>(vec, "", func (acc, x) { acc # Nat.toText(x)}); // => "123"
```

Runtime: `O(size)`

Space: `O(1)`

*Runtime and space assumes that `combine` runs in O(1)` time and space.

## Function `foldRight`
``` motoko no-repl
func foldRight<X, A>(vec : Vector<X>, base : A, combine : (X, A) -> A) : A
```

Collapses the elements in `vec` into a single value by starting with `base`
and progessively combining elements into `base` with `combine`. Iteration runs
right to left.

Example:
```motoko

import Nat "mo:base/Nat";

let vec = Vector.fromArray<Nat>([1,2,3]);

Vector.foldRight<Nat, Text>(vec, "", func (x, acc) { Nat.toText(x) # acc }); // => "123"
```

Runtime: `O(size)`

Space: `O(1)`

*Runtime and space assumes that `combine` runs in O(1)` time and space.
