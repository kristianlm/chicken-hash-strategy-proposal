# Suggested Hash Algorithm Conventions for CHICKEN 5

This is CHICKEN 5 hashing strategy proposal. The CHICKEN 5 ecosystem
needs a hashing strategy. It should:

- be consistent and easy to use
- be possible to write an hashing algorithm egg with no dependencies
- be possible to use multiple hashing algorithms without changing
  application code

The hashing alrogithms for CHICKEN themselves typically just embed a C
implementation and don't require any other eggs. However, CHICKEN 4
hash eggs typically depend on the `message-digest` egg which again has
a large number of dependencies. If all you need is `string->sha256`,
for example, this may be overkill and the approach documented here may
be more suitable.

If you want to be hash-algorithm agnostic, this should still be
possible provided that all `hash-*` eggs follow a certain
standard.

## 3-function interface

It's possible to offer fast hash algorithms for many (all?) hashing
alrorithm given a three functions: `init`, `update!` and `final!`.

Let's say each CHICKEN 5 hash algorithm exported these 4 identifiers:

    [constant] digest-length

Number of bytes returned as blob/string in `final!`. eg.

    [pocedure] (init [ args ... ] )

Returns a fresh context that can be passed to `update!` and `final!`,
and only to those two procedures. It can be any scheme object, but it
is generally a good idea to use something that checks for the right
type as this will produce errors (instead of segfaults) when `update!`
and `final!` are given wrong contexts. Contexts are therefore
typically wrapped in their own record types.

`context` cannot (usually) be inspected directly.

`init` may contain any number of arguments, depending on the hashing
algorithm.

> hmac's `init` will probably need some data to initialize itself.

    [procedure] (update! context data #!optional len offset)

Mutates context by input `data`, which may be of different types. The
type of `data` may be:

- a string
- a blob
- a u8vector
- a c-pointer

`len` specifies the number of bytes to read from `data`, starting from
`offset`. it defaults to `#f`, indicating to read all bytes in `data`.

It is an error if `len` is not given or `#f` if the type of data is
c-pointer.

`offset` is always optional and specifies the number of bytes to skip
and defaults to `0`. it is an error if `(> (+ len offset)
(number-of-bytes data))`.

`update!` returns `context` for convenience.

    [procedure] (final! context #!optional destination)

Fills `destination` with the hashing algorithms result reflected in
`context`. `destination` defaults to a blob of length `digest-length`,
but may also be given as a string of the same length (that will be
overwritten).

`final!` returns `destination`.

`final!` may modify `context` and should only be called once for each
context.

# Simple example

A `sha256sum` application could look like this:

```
(import (chicken port) (chicken io)
        (hash sha256))

(define c (init))
(port-for-each (lambda (s) (update! c s))
               (lambda () (read-string 1024)))
(print (final! c))
```

If another hashing algorithm is desired, only the import needs to be
changed. If multiple hashing alrorithms are used, the imports will
need to be prefixed or lexically scoped:

```
(import (chicken io) (chicken process-context))

(define sha256
  (lambda ()
    (import (hash sha256))
    (values (init) update! final!)))

(define sha512
  (lambda ()
    (import (hash sha512))
    (values (init) update! final!)))

(define alg* (car (command-line-arguments)))
(define alg
  (cond ((equal? "sha256" alg*) sha256)
        ((equal? "sha512" alg*) sha512)
        (else (error "unknown algorithm" alg*))))

(receive (ctx update! final!) (alg)
  (print (final! (update! ctx (read-string)))))
```

## The return value of `update!`

If we say `update!` must always return the given context, we can make
this shortcut:

```
(import (hash sha256) (chicken io))
(print (final! (update! (init) (read-string))))
```

This is nice because, as this is a common use-case, this is concise
enough to (hopefully) avoid the need for util functions.

## Imports

We could name them like this for example:

- `(import (hash blake2))`
- `(import (hash crc32))`
- `(import (hash hmac))` <-- would this be hard?
- `(import (hash md5))`
- `(import (hash sha1))`
- `(import (hash sha256))`
- `(import (hash sha512))`

All of these could be in separate eggs that _only_ provide the
`digest-length`, `init`, `update!` and `final!` functions. These eggs
chould have none or few dependencies, and export one or more modules
under `(hash <algorithm-name>)`.

## Hash util egg

A separate `(import (hash))` egg could provide some utils that utilize
the algorithms. It could provide:

- blob->hex for easy printing
- algorithm -> fast port hasher
- algorithm -> fast file hasher

Plus various other things that `message-digest` is good at.

## Sample code

This repository implements prototypes of this API conventions in
sub-folders. Run `chicken-install` in each sub-directory to give these
examples a spin.
