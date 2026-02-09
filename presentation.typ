#import "@preview/slydst:0.1.5": *

#show: slides.with(
  title: "Algebraic data types",
  subtitle: "How to write clean and safety code?",
  authors: "Kudyakov Artem Alexandrovich 351",
  subslide-numbering: "(1)",
  ratio: 16 / 9,
)

#show raw: set block(fill: silver.lighten(65%), width: 100%, inset: 1em)

= What is this?

== Sets

In every programming language, any type can be thought of as a set of values
that a variable of this type can take. For instance, the `i32` from Rust is
the set of integers in the range between $-2^31$ and $2^31 - 1$, inclusive:

$
  #[`i32`] in {a | a in ZZ #[and] -2^31 <= a <= 2^31 - 1}
$

== The Cartesian product

`i32` is a primitive data type. But how can we build a composite data type?
For this, we can use *the Cartesian product*. It works something like this:

$
  A = {1, 2, 3} quad B = {x, y} \
  A times B = {(1, x), (1, y), (2, x), (2, y), (3, x), (3, y)}
$

Let's build the tuple of three `i32` values, that is, `(i32, i32, i32)`. It's
simply the Cartesian product of three sets of `i32`:
$#[`i32`] times #[`i32`] times #[`i32`]$.

== How to build structures?

Using the Cartesian product we can also build structures. For example,
the following structure:

```rust
struct Point {
  x: i32,
  y: i32,
  z: i32,
}
```

can also be represented as the Cartesian product of three `i32` values.

== Union

In set theory there is a union operation. It works something like this:

$
  A = {1, 2, 3} quad B = {x, y} \
  A union B = {1, 2, 3, x, y}
$

== Sum Types in Rust

We can use it to build the `enum` values. For instance, the following `enum`:

```rust
enum Command {
  Quit,
  Move { x: i32, y: i32 },
  Print(String)
}
```

can also be represented as the following disjoint union:

$
  Q = {#[quit]} quad
  M = {#[move]} times #[`i32`] times #[`i32`] quad
  P = {#[print]} times #[`String`] \
  C = Q union M union P
$

Values of this set look like this:

$
  C = {#[quit], (#[move], 5, 10), ..., (#[print], #[`"Hello, world!"`]), ...}
$

== Enumerations in C++ and other languages

In traditional programming languages enumerations can't often contain any values.
For instance, in C++ they are simply named numbers:

```cpp
enum class TrafficLight {
  Red,
  Yellow,
  Green
}
```

== What is ADT?

*Algebraic data type* is the composite data type built of other
types using the Cartesian product and union operation. Enumerations from Rust
are algebraic data types, enumerations from C++ aren't.

= Why is this necessary?

== Let's write some TypeScript ...

Let's write a library for TypeScript to make HTTP requests to the server.
Request has three states: `loading`, `success` and `error`. For each state
our library will store different data.
+ For `loading` the library doesn't store any data.
+ For `success` the library will store the response from the server.
+ And for `error` it stores the error from the server.

```typescript
// like C++ enumerations
type RequestState = 'loading' | 'success' | 'error';

type Request<T, E> = {
  state: RequestState,
  data?: T,
  error?: E,
};
```

== ... using ADT

```typescript
type Request<T, E> =
  | { state: 'loading'; }
  | { state: 'success'; data: T; }
  | { state: 'error'; error: E; };
```

Now, TypeScript at compile-time will verify that `data` is of type `T` if and
only if `state` is `'success'`.

== Stress-test

Let's try make incorrect object with this type:

```typescript
// Good!
const req1: Request<{ status: 'OK'; }, { error: string; }> = {
  state: 'success',
  data: {
    status: 'OK'
  },
};
```

#pagebreak()

Let's try make correct object with this type:

```typescript
// Won't compile
const req2: Request<{ status: 'OK'; }, { error: string; }> = {
  state: 'success'
};
```

#pagebreak()

Let's try make incorrect object with this type:

```typescript
// Won't compile
const req3: Request<{ status: 'OK'; }, { error: string; }> = {
  state: 'loading',
  data: {
    status: 'OK'
  }
};
```

#pagebreak()

Let's try make incorrect object with this type:

```typescript
// Won't compile
const req4: Request<{ status: 'OK'; }, { error: string; }> = {
  state: 'success',
  data: {
    status: 'Спасайся, кто может!'
  }
};
```

= Thank you for your attention!

