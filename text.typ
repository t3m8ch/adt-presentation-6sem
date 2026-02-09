#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
#codly(languages: codly-languages)

= Algebraic data types

== What is this?

In every programming language, any type can be thought of as a set of values
that a variable of this type can take. For instance, the `i32` from Rust is
the set of integers in the range between $-2^31$ and $2^31 - 1$, inclusive:

$
  #[`i32`] in {a | a in ZZ #[and] -2^31 <= a <= 2^31 - 1}
$

`i32` is a primitive data type. But how can we build a composite data type?
For this, we can use *the Cartesian product*. It works something like this:

$
  A = {1, 2, 3} quad B = {x, y} \
  A times B = {(1, x), (1, y), (2, x), (2, y), (3, x), (3, y)}
$

Let's build the tuple of three `i32` values, that is, `(i32, i32, i32)`. It's
simply the Cartesian product of three sets of `i32`:
$#[`i32`] times #[`i32`] times #[`i32`]$.

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
In set theory there is a union operation. It works something like this:

$
  A = {1, 2, 3} quad B = {x, y} \
  A union B = {1, 2, 3, x, y}
$

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

#pagebreak()

In traditional programming languages enumerations can't often contain any values.
For instance, in C++ they are simply named numbers:

```cpp
enum class TrafficLight {
  Red,
  Yellow,
  Green
}
```

*Algebraic data type* is the composite data type built of other
types using the Cartesian product and union operation. Enumerations from Rust
are algebraic data types, enumerations from C++ aren't.

== Why is this necessary?

Let's write a library for TypeScript to make HTTP requests to the server.
Request has three states: `loading`, `success` and `error`. For each state
our library will store different data. For `loading` the library doesn't store
any data. For `success` the library will store the response from the server.
And for `error` it stores the error from the server.

What it look like in a traditional programming language:

```typescript
// like C++ enumerations
type RequestState = 'loading' | 'success' | 'error';

type Request<T, E> = {
  state: RequestState,
  data?: T,
  error?: E,
};
```

We know that `data` contains value only when state is equal to `'success'`.
Also `error` contains value only when state is equal to `'error'`. We can
check this conditions at runtime, but they aren't verified at compile-time
using types. This makes bugs harder to catch because runtime error can occur
at any time.

Fortunately, TypeScript allows us to implement algebraic data types using
*union operator* (we already use it in `RequestState` to implement C++
enumerations). We can take composite types for union operands to impelement
Sum Types from Rust:

```typescript
type Request<T, E> =
  | { state: 'loading'; }
  | { state: 'success'; data: T; }
  | { state: 'error'; error: E; };
```

#pagebreak()

Now, TypeScript at compile-time will verify that `data` is of type `T` if and
only if `state` is `'success'`. Let's try make incorrect object with this type:

```typescript
// Good!
const req1: Request<{ status: 'OK'; }, { error: string; }> = {
  state: 'success',
  data: {
    status: 'OK'
  },
};

// Won't compile
const req2: Request<{ status: 'OK'; }, { error: string; }> = {
  state: 'success'
};

// Won't compile
const req3: Request<{ status: 'OK'; }, { error: string; }> = {
  state: 'loading',
  data: {
    status: 'OK'
  }
};

// Won't compile
const req4: Request<{ status: 'OK'; }, { error: string; }> = {
  state: 'success',
  data: {
    status: 'Спасайся, кто может!'
  }
};
```

