[![mops](https://oknww-riaaa-aaaam-qaf6a-cai.raw.ic0.app/badge/mops/vector)](https://mops.one/vector)
[![documentation](https://oknww-riaaa-aaaam-qaf6a-cai.raw.ic0.app/badge/documentation/vector)](https://mops.one/vector/docs)

# Vector data structure for Motoko

## Overview

The `Vector` data structure is meant to be a replacement for `Array` when a growable and/or shrinkable data structure is needed.
It provides random access like `Array` and `Buffer` and can grow and shrink at the end like `Buffer` can.
Unlike `Buffer`, the memory overhead for allocated but no yet used space is $O(\sqrt{n})$ instead of $O(n)$.

### Links

The package is published on [MOPS](https://mops.one/vector) and [GitHub](https://github.com/research-ag/vector).
Please refer to the README on GitHub where it renders properly with formulas and tables.

The API documentation can be found [here](https://mops.one/vector/docs/lib) on Mops.

For updates, help, questions, feedback and other requests related to this package join us on:

* [OpenChat group](https://oc.app/2zyqk-iqaaa-aaaar-anmra-cai)
* [Twitter](https://twitter.com/mr_research_ag)
* [Dfinity forum](https://forum.dfinity.org/)

### Characteristics

The data structure is based on the paper [Resizable Arrays in Optimal Time and Space](https://sedgewick.io/wp-content/themes/sedgewick/papers/1999Optimal.pdf) by Brodnik, Carlsson, Demaine, Munro and Sedgewick (1999)
which has the following characteristics:

* based on a 2-dimensional array
* persistent memory overhead: $O(\sqrt{n})$
* worst-case instruction overhead: $O(\sqrt{n})$
* no re-allocation or copying of data blocks

The implementation is furthermore cycle optimized.

### Motivation

When developing smart contract canisters, to be sure that the canister does not ever run into cycle limits,
one has to reason about the code's worst-case complexity. 
This is even more important as publicly accessible smart contract canisters don't control their input
and operate in a potentially adversarial environment.
Understanding worst-case behavior is often critical.

The go-to data structure for a resizable array is `Buffer` from motoko-base.
`Buffer` is a fixed-size array with some reserve capacity that is "grown" when it fills up.
Growing means that the old array is copied into a newly allocated larger array and the old array becomes garbage.
The growing factor is 1.5x.
Therefore, `Buffer` has linear persistent memory overhead (1.5x) and
linear worst-case behavior (copying the entire array in the growth event).

The present data structure improves both metrics from linear to $O(\sqrt{n})$ in exchange for less performant random access.
Since the underlying data structure is a 2-dimensional array, put and get operation become approximately twice as expensive.
However, the implementation is highly optimized so that in practice it is less than 2x in practice.
Several convenience functions operate even faster for `Vector` than they do for `Buffer`.
For details see the Benchmarking section below.

### Interface

`Vector` is a static type and can therefore be declared `stable`.
This is unlike `Buffer` which is a class and can not be directly declared `stable`.

`Vector` provides 40+ convenience functions that are modeled and named after the convenience functions of `Buffer`.
This is done to make it as easy as possible to replace `Buffer` with Vector.

If a `stable` declaration is not required then the package also provides a class version of `Vector`. 
This can be used as a drop-in replacement for `Buffer` as it provides exactly the same interface.
As with `Buffer`, the user can benefit from the convenient dot-notation for the class methods.

## Usage

### Install with mops

You need `mops` installed. In your project directory run:
```
mops add vector
```

In the Motoko source file import the package as one of:
```
import Vec "mo:vector";
import Vec "mo:vector/Class";
```

for the static version or the class version, respectively.

### Example

```
import Vector "mo:vector";

let v = Vector.new<Nat>();
Vector.add(v, 1);
Vector.add(v, 2);
Vector.add(v, 3);
assert(Vector.get(v, 0) == 1);
assert(Vector.get(v, 1) == 2);
assert(Vector.get(v, 2) == 3);
Vector.size(v);
```

[Executable version of above example](https://embed.smartcontracts.org/motoko/g/AyS1mBK7bmZuQpfetD8HgwnKmVHgBhKWoFLaKskE3RZcmDbLiwSJNqkdGCRytymssQft3fdPSWAQ8opcmqDXTREhCwWGFs1tnAYDbJxraMbSrUKcDSEE2NcZeRZMTsShY3oGpnTjf9iUV2K6iYzdc7hCq2TjZC5gG8dzJN3duuBjPCaKJnyA7aJ642Ps2YWXXUt6NAbpZ?lines=12)

```
import Vector "mo:vector/Class";

let v = Vector.Vector<Nat>();
v.add(1);
v.add(2);
v.add(3);
assert(v.get(0) == 1);
assert(v.get(1) == 2);
assert(v.get(2) == 3);
v.size();
```

[Executable version of above example](https://embed.smartcontracts.org/motoko/g/7jAGWj9539qPauP9xFW79q2x9Xdeki6FHJWjByGftGsSFTJDKYk6b2oeTZpJZT6RtCWrwSAEpbdmgZ7FiGRoDLQi7149XNunNr8iDS1rk5ix81qC4BqNfjLGBrTnwRRtAQbBmRnZSFzjfuF1hHntQm2js1QAk5ffimyfHBywwtajcmGZyeSKPQzM5WT9n7gwVSfRQ?lines=12)

### Build & test

You need `moc` and `wasmtime` installed.
Then run:
```
git clone git@github.com:research-ag/vector.git
make -C test
```

## Benchmarks

We extensively benchmarked `Vector` against `Buffer` and the Motoko-native `Array`, where applicable.
Each line in the follwing tables below is one benchmark and corresponds to the given function name.

The benchmarking code can be found here: [canister-profiling](https://github.com/research-ag/canister-profiling)

### Time

This table shows the number of wasm instruction for the given function execution.

For some functions the number of instructions is expected to be independent of the size of the vector,
e.g. `init`, `get`, `getOpt`, `put`, `size`, `clear`, `isEmpty`.
However, even in those case we run the function N times and take the average because there may be marginal differences in cost based on the concrete integer value of the index being used.

For some functions the function is run only once for a vector of size N
because a single call iterates through the whole vector,
e.g. `addMany`, `clone`, `indexOf`, `firstIndexWith`, `lastIndexOf`, `lastIndexWith`, `forAll`, `forSome`, `forNone`, `iterate`, `iterateRev`, `vals`, `valsRev`, `items`, `itemsRev`, `keys`, `iterateItems`, `iterateItemsRev`, `addFromIter`, `toArray`, `fromArray`, `toVarArray`, `fromVarArray`, `contains`, `max`, `min`, `equal`, `compare`, `toText`, `foldLeft`, `foldRight`, `reverse`, `reversed`.

The functions `add` and `removeLast` have sporadic worst-case behavior when the data structure has to grow.
They are therefore run N times and the result is averaged to obtain an amortized cost per call.

```
N = 100,000
Compiler: moc-0.11.4
value data type: Nat
```
|method|vector|vector class|buffer|array|
|---|---|---|---|---|
|init|15|15|14|14|
|addMany|17|17|-|-|
|clone|188|188|298|-|
|add|336|378|552|-|
|get|205|247|136|72|
|getOpt|261|303|149|-|
|put|266|309|152|82|
|size|183|216|101|69|
|removeLast|315|356|395|-|
|indexOf|182|182|172|56|
|firstIndexWith|163|163|-|-|
|lastIndexOf|222|222|179|-|
|lastIndexWith|203|203|-|-|
|forAll|175|175|157|-|
|forSome|163|163|162|-|
|forNone|163|163|162|-|
|iterate|106|106|140|-|
|iterateRev|133|133|-|-|
|vals|156|156|127|20|
|valsRev|163|163|-|-|
|items|266|266|-|-|
|itemsRev|293|293|-|-|
|keys|105|105|-|-|
|iterateItems|142|142|-|-|
|iterateItemsRev|177|177|-|-|
|addFromIter|406|406|354|-|
|toArray|158|158|117|-|
|fromArray|163|163|190|-|
|toVarArray|226|226|170|114|
|fromVarArray|163|163|190|64|
|clear|139|180|329|-|
|contains|182|182|163|56|
|max|174|174|191|57|
|min|174|174|197|57|
|equal|356|356|243|133|
|compare|397|397|284|133|
|toText|455|455|398|0|
|foldLeft|163|163|176|69|
|foldRight|190|190|192|135|
|reverse|426|426|243|145|
|reversed|412|412|243|145|
|isEmpty|116|156|120|88|

Note:

* `add` is the function that can grow the data structure. It performs better in amortized terms than for `Buffer` because the growth events are cheaper. `Vector` only allocates new data blocks, it does not re-allocate and copy old data blocks. 
* `get`, `put` and `getOpt` are the random access functions. `Vector` is a 2-dimensional array where (only) the second dimension has option-values, `Buffer` is a 1-dimensional array with option-values and `Array` is a 1-dimensional array with non-option-values. Hence, the expected access time for `Vector` is expected to be roughly the sum of access times for `Buffer` and `Array`. This is correctly reflected in the numbers.
* All functions that iterate through the data structure are optimized in a way that they don't use random access. This is the reason that they are generally only slighly (0-35%) more costly than `Buffer`. In some case the function can be cheaper than for `Buffer` (`iterate`, `max`, `min`).

### Memory

This table shows the heap allocation (persistent and garbage) for the given function execution.
The results are for a data structure of size N.

The memory size is generally shown in bytes for a single function execution.

In some cases, the value depends on the size N of the `Vector`,
e.g. `init`, `addMany`, `clone`, etc.

In cases when there is an amortized cost such as `add`, `removeLast` then the function is executed N times
so that one can get an idea of the average. 

```
N = 100,000
Compiler: moc-0.11.1
value data type: Nat
```

|method|vector|vector class|buffer|array|
|---|---|---|---|---|
|init|408688|409076|400504|400008|
|addMany|408640|408640|-|-|
|clone|425032|425420|553568|-|
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

* `init` and `addMany` create a data structure of size N. Here we see the persisten $\sqrt{N}$ memory overhead for `Vector` relative to `Array`.
* `add` shows the garbage creation of `Buffer` due to copying of the entire data block during growth events. `Vector` copies only its index block which is in the order of $\sqrt{N}$. 
* `removeLast` shows the same effects as `add` but for shrink events.
* `items` produces a large amount of garbage because the iterator produces tupels (unlike vals which produces single Nat values in this example). If that is a problem than the `iterateItems` function may provide a better alternative for the use case.

## Design

The data structure is based on the paper [Resizable Arrays in Optimal Time and Space](https://sedgewick.io/wp-content/themes/sedgewick/papers/1999Optimal.pdf) by Brodnik, Carlsson, Demaine, Munro and Sedgewick (1999).

The vector elements are stored in so-called data blocks and
the whole data structure consists of a sequence of data blocks of increasing size.
Hence it is in fact a two-dimensional array (but not a "square" one).

The trick lies in the selection of the sizes of the data blocks. 
They are chosen such that the conversion of the externally used single index 
to the internally used index pair can be cheaply done by bit shifts.

The data block sizes can be better understood when thinking of the data blocks being arranged in "super blocks".
Super blocks are merely a virtual concept and have no manifestation in the implementation.
The capacity of a super block is always a $2$-power.
The $i$-th super block has capacity $2^i$ and consists of $2^{\lfloor i / 2\rfloor}$ data blocks of size $2^{\lceil i / 2 \rceil}$.
This is followed by the next super block of capacity $2^{i+1}$ and so on.

Hence, the sequence of data block sizes look like this:

$$1,\ \ 2,\ \ 2,2,\ \ 4,4,\ \ 4,4,4,4,\ \ 8,8,8,8,\ \ ...$$

where the additional white space indicates super block boundaries. 

## Implementation notes

Each data block is a mutable array of type `[var ?X]` where `X` is the element type.
The data blocks themselves are stored in the mutable array called `data_blocks`.
Hence `data_blocks` has type `[var [var ?X]]`.

The present implementation differs from the article in that the data block indices are shifted by $2$ and we introduce two data blocks of size $0$ and $1$ at the beginning of the sequence.
This makes the access faster because it eliminates the frequent computation of $i+2$ in the internal formulas needed for index conversion.

Besides the `data_blocks` array, the `Vector` type constains the index pair `i_block`, `i_element` which means the next position that should be written by an `add` operation:
`data_blocks[i_block][i_element]`.
We do not store any more information to reduce memory.
But we also do not store less any information (such as only the total size in a single variable)
as to not slow down access.

When growing we resize `data_blocks` (the outer array) so that it can store exactly one next super block. But unused data blocks in the last super block are not allocated, i.e. set to the empty array. 

When shrinking we keep space in `data_blocks` for two additional super blocks. But unused data blocks in the last two super blocks are deallocated, i.e. set to the empty array.

## Copyright

MR Research AG, 2023
## Authors

Andrii Stepanov with contributions from Timo Hanke, Andy Gura and react0r-com.

## License 

Apache-2.0