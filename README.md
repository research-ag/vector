# A vector data structure for Motoko

## Overview

### Characteristics

The package provides a resizable vector data structure `Vector` with the following characteristics:

* implemented as a 2-dimensional array
* performance-optimized
* persistent memory overhead: O(sqrt(n))
* worst-case instruction overhead: O(sqrt(n))
* no re-allocation of data blocks and no copying

### Motivation

When developing smart contract canisters, to be sure that the canister does not ever run into cycle limits,
one has to reason about the code's worst-case complexity. 
This is even more important as publicly accessible smart contract canisters operate in an adversarial environment in which they don't control their input.
Understanding worst-case behavior is often critical.

The go-to data structure for a resizable array is `Buffer` from motoko-base.
`Buffer` is a fixed-size array with some reserve capacity that is "grown" when the fill level reaches the capacity.
Growing means that the old array is copied into a newly allocated larger array and the old array becomes garbage.
The growing factor is 1.5x.
Therefore, `Buffer` has linear persistent memory overhead (1.5x) and
linear worst-case behavior (copying the entire array in the growth event).

The present data structure improves both metrics from linear to O(sqrt(n)) in exchange for less performant random access.
Since the underlying data structure is a 2-dimensional array, put and get operation become approximately twice as expensive.
However, the implementation is highly optimized so that in practice it is less than 2x in practice.
Several convenience functions operate even faster for `Vector` than they do for `Buffer`.
For details see the Benchmarking section below.

### Interface

`Vector` is a static type and can therefore be declared `stable`.
This is unlike `Buffer` which is a class and can not be directly declared `stable`.

`Vector` provides 40+ convenience functions that are modeled and named after the convenience functions of `Buffer`.
This is done to make it as easy as possible to replace Buffer with Vector.

If a `stable` declaration is not required then the package also provides a class version of Vector. 
This can be used as a drop-in replacement for Buffer as it provides exactly the same interface.
As with Buffer, the user can benefit from the convenient dot-notation for the class methods.



## Usage

### With mops

Add this line to your project's `mops.toml`:
```
[dependencies]
vector = "0.1.0"
```

In your Motoko files import the package as follows:
```
import Vec "mo:vector";
```

to use the static version or

```
import Vec "mo:vector/Class";
```

to use the class version.

## Benchmarks

We extensively benchmarked `Vector` against `Buffer` and the Motoko-native `Array`, where applicable.
Each line in the follwing tables below is one benchmark and corresponds to the given function name.

### Time

This table shows the number of wasm instruction for the given function execution.

For some functions the number of instructions is expected to be independent of the size of the vector,
e.g. init, get, getOpt, put, size, clear, isEmpty.
However, even in those case we run the function N times and take the average because there may be marginal differences in cost based on the conrete value of the index being used.

For some functions the function is run only once for a vector of size N
because a single call iterates through the whole vector,
e.g. addMany, clone, indexOf, firstIndexWith, lastIndexOf, lastIndexWith, forAll, forSome, forNone, iterate, iterateRev, vals, valsRev, items, itemsRev, keys, iterateItems, iterateItemsRev, addFromIter, toArray, fromArray, toVarArray, fromVarArray, contains, max, min, equal, compare, toText, foldLeft, foldRight, reverse, reversed.

The functions add and removeLast have sporadic worst-case behavior when the data structure has to grow.
They are therefore run N times and the result is averaged to obtain an amortized cost per call.

N = 100,000

|method|vector|vector class|buffer|array|
|---|---|---|---|---|
|init|13|13|12|12|
|addMany|14|14|-|-|
|clone|176|0|253|-|
|add|291|321|490|-|
|get|195|225|118|71|
|getOpt|230|260|120|-|
|put|236|267|126|72|
|size|153|182|74|49|
|removeLast|294|323|326|-|
|indexOf|148|148|137|34|
|firstIndexWith|136|136|-|-|
|lastIndexOf|176|176|144|-|
|lastIndexWith|164|164|-|-|
|forAll|140|140|132|-|
|forSome|136|136|137|-|
|forNone|136|136|137|-|
|iterate|93|93|123|-|
|iterateRev|114|114|-|-|
|vals|147|147|117|14|
|valsRev|140|140|-|-|
|items|247|247|-|-|
|itemsRev|267|267|-|-|
|keys|92|92|-|-|
|iterateItems|123|123|-|-|
|iterateItemsRev|151|151|-|-|
|addFromIter|368|368|311|-|
|toArray|138|138|102|-|
|fromArray|148|148|152|-|
|toVarArray|199|199|156|110|
|fromVarArray|148|148|152|56|
|clear|161|189|266|-|
|contains|148|148|138|34|
|max|147|147|163|37|
|min|147|147|168|37|
|equal|291|291|204|112|
|compare|331|331|244|112|
|toText|409|409|366|0|
|foldLeft|137|137|153|50|
|foldRight|158|158|159|113|
|reverse|396|396|209|128|
|reversed|365|365|209|128|
|isEmpty|89|120|89|61|

Note:

* add is the function that can grow the data structure. It performs better for Vector than for Buffer because the growth events are cheaper. `Buffer` only allocates new data blocks, it does not re-allocate and copy old data blocks. 
* get, put and getOpt are the random access functions. `Vector` is a 2-dimensional array where (only) the second dimension has option-values, `Buffer` is a 1-dimensional array with option-values and `Array` is a 1-dimensional array with non-option-values. Hence, the expected access time for `Vector` is expected to be roughly the sum of access times for `Buffer` and `Array`. This is correctly reflected in the numbers.
* All functions that iterate through the data structure are optimized in a way that they don't use random access. This is the reason that they are generally only slighly (0-35%) more costly than `Buffer`. In some case the function can be cheaper than for `Buffer` (iterate, max, min).

### Memory

This table shows the heap allocation (persistent and garbage) for the given function execution.
The results are for a data structure of size N.

The memory size is generally shown in bytes for a single function execution.

In some cases, the value depends on the size N of the Vector,
e.g. init, addMany, clone, etc.

In cases when there is an amortized cost such as add, removeLast then the function is executed N times
so that one can get an idea of the average. 

N = 100,000

|method|vector|vector class|buffer|array|
|---|---|---|---|---|
|init|408688|409076|400504|400008|
|addMany|408640|408640|-|-|
|clone|425060|520|553568|-|
|add|416060|416060|1659216|-|
|get|0|0|0|0|
|getOpt|0|0|0|-|
|put|0|0|0|0|
|size|0|0|0|0|
|removeLast|7404|7404|553112|-|
|indexOf|28|28|0|0|
|firstIndexWith|8|8|-|-|
|lastIndexOf|20|20|0|-|
|lastIndexWith|0|0|-|-|
|forAll|24|24|48|-|
|forSome|8|8|48|-|
|forNone|8|8|48|-|
|iterate|8|8|48|-|
|iterateRev|0|0|-|-|
|vals|172|172|48|0|
|valsRev|68|68|-|-|
|items|1600104|1600104|-|-|
|itemsRev|1600080|1600080|-|-|
|keys|44|44|-|-|
|iterateItems|8|8|-|-|
|iterateItemsRev|0|0|-|-|
|addFromIter|416060|416060|1200008|-|
|toArray|400180|400180|400024|-|
|fromArray|408716|409104|600504|-|
|toVarArray|400180|400180|400008|400008|
|fromVarArray|408716|409104|600504|400024|
|clear|20|20|40|-|
|contains|28|28|48|0|
|max|36|36|48|0|
|min|36|36|48|0|
|equal|344|344|0|0|
|compare|344|344|0|0|
|toText|3200164|3200164|3199992|296|
|foldLeft|36|36|48|0|
|foldRight|28|28|0|0|
|reverse|0|0|0|400028|
|reversed|416144|416532|0|400028|
|isEmpty|0|0|0|0|

Note:

* init and addMany create a data structure of size N. Here we see the sqrt(N) overhead for Vector over Array.
* add shows the garbage creation of Buffer due to copying of the entire data block during growth events. Buffer copies only its index block which is in the order of sqrt(N). The same effect is seen for shrink events in removeLast.
* items produces a large amount of garbage because the iterator produces tupels (unlike vals which produces single Nat values in this example). If that is a problem than the iterateItems functions may provide a better alternative for the use case.

## Authors

MR Research AG by Andrii Stepanov with contributions from 
Timo Hanke, Andy Gura and react0r-com.

## License 

Apache-2.0