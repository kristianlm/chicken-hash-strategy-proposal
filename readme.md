# Suggested Hash Algorithm Conventions for CHICKEN 5

THe CHICKEN 5 ecosystem needs a hashing strategy. It should:

- be consistent and easy to use
- be possible to write an hashing algorithm egg with no dependencies
- be possible to use multiple hashing algorithms without changing
  application code

What if each algorithm egg provides three functions, would that be
enough?

- _alg_-init
- _alg_-update!
- _alg_-final!

## Hash Algorithms

We could name them like this for example:

- `(import (hash crc))`
- `(import (hash md5))`
- `(import (hash sha1))`
- `(import (hash sha2))`
- `(import (hash blake2))`
- `(import (hash hmac))` <-- would this be hard?

All of these could be separate eggs that _only_ provide the basic
`init`, `update!` and `final!` functions. These should have none or
few dependencies.

## Hash util egg

A separate `(import (hash))` could provide some utils that utilize the
algorithms. It could provide:

- blob->hex for easy printing
- algorithm -> port hasher
- algorithm -> file hasher

## API by convention

It would be nice to have a set of `hash-*` eggs that follow this eggs
API convention that would allow dependency-free hash eggs for CHICKEN.

The hashing alrogithms for CHICKEN themselves typically just embed a C
implementation and don't require any other eggs. However, CHICKEN 4
hash eggs typically depend on the `message-digest` egg which again has
a large number of dependencies. If all you need is `string->sha256`,
for example, this may be overkill and this approach may be better.

If you want to be hash-algorithm agnostic, this should still be
possible provided that all `hash-*` eggs follow a certain
standard. This standard is currently not written yet, but this egg is
an attempt.
