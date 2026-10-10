# Vector changelog

## 0.4.7

- Tests and benchmarks compile warning-free with moc 2.0.0
- Switch test dependency to `matchers` 2.1.0 from mops

## 0.4.6

- Use bench-helper package
- Now benchmark against `Array` from `core` (faster sort than `base`)

## 0.4.5

- Improve benchmark accuracy
- Bump bench dependency to 2.0.1

## 0.4.4

- Bump bench dependency to 2.0.0
- Remove unused test dependency

## 0.4.3

- Notice about using `List` instead
- Bump dependencies

## 0.4.2

- Bugfix: last() could sometimes return wrong element
- Memory efficiency: addMany() could sometimes allocate a data_block twice
- Bump dependencies

## 0.4.1

- Bugfix: removeLast can trap on empty vector
- Bump dependencies

## 0.4.0

- Add sort() function

## 0.3.2

- Bump dependencies to moc/base to 0.11.2, dfx 0.20.1
- Re-run benchmarks

## 0.3.1

- Add benchmark comparison of Vector/Buffer/Array
- Add `requirements` section to mops.toml

## 0.3.0

- Make all dependencies compatible with moc 0.11.0
- Switch tests to mops test

## 0.2.0

- Add the `map` function to vector
