# proofcache

a shared cache of proven rewrites, so a rewrite proven once is reused everywhere. A rewrite is Lhs = Rhs over arithmetic in variables; it is checked on every assignment of its variables to -6..6, and the result is stored under the rewrite's canonical form, so x*2 = x+x and y*2 = y+y share one entry. For polynomials of total degree at most 12, agreeing on all 13 values of each variable is a proof (a nonzero polynomial of degree at most 12 in each variable cannot vanish on them all), so the result is holds; for anything else it is holds_on(-6, 6), so a shared entry never claims more than was checked. The cache is a value, passed in and out, so it can be saved as a file and shared between repos.

## Use

```prolog
?- use_module(prolog/proofcache).
?- prove(X * 2 = X + X, R).                                   % R = holds
?- prove(X * X = X + X, R).                                   % R = fails_at([x(1) = -6]): the first value tried
?- empty(C0), cached(C0, A * 2 = A + A, R1, C1, H1), cached(C1, B * 2 = B + B, R2, _, H2).  % H1 = miss, H2 = hit
```

## Proofs

`proofs/theorems.pl` proves 6 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every rewrite Lhs = Rhs where each side is one of a pool of expressions in X and Y.

1. The cache never changes an answer: cached and fresh proofs agree.
2. Asking again is a hit with the same answer, and the cache doesn't grow.
3. Renaming variables gives the same entry (a hit).
4. A counterexample really breaks the rewrite.
5. holds means it holds on the whole checked range, and is given only for polynomials of degree up to 12, where agreement on -6..6 is a proof.
6. Agreement on the range alone is not called a proof: otherwise the result is holds_on(-6, 6) (the product of X - K for K in -6..6 is zero on the whole range and nowhere else).

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
