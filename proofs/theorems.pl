% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/proofcache').

% Domain: every rewrite Lhs = Rhs where each side is one of a pool of expressions in X and Y.
side(E, X, Y) :- member(E, [X, Y, X + X, X * 2, 2 * X, X * X, X + Y, Y + X, X - X, 0, X * Y, Y * X, (X + 1) * 2, 2 * X + 2]).
rewrite(L = R) :- side(L, X, Y), side(R, X, Y).

% 1. The cache never changes an answer: cached and fresh proofs agree.
theorem(cache_agrees_with_proof) :- forall(rewrite(R), ( empty(C), cached(C, R, A, _, miss), prove(R, B), A == B )).

% 2. Asking again is a hit with the same answer, and the cache doesn't grow.
theorem(second_ask_is_a_hit) :- forall(rewrite(R), ( empty(C0), cached(C0, R, A, C1, _), cached(C1, R, B, C2, hit), A == B, size(C1, N), size(C2, N) )).

% 3. Renaming variables gives the same entry (a hit).
theorem(renamed_is_a_hit) :- forall(rewrite(R), ( empty(C0), cached(C0, R, _, C1, _), copy_term(R, R2), cached(C1, R2, _, _, hit) )).

% 4. A counterexample really breaks the rewrite.
theorem(counterexamples_are_real) :-
    forall(( rewrite(R), prove(R, fails_at(Bs)) ), ( copy_term(R, L = Rhs), term_variables(L = Rhs, Vs), maplist([V, _ = V]>>true, Vs, Bs), L =\= Rhs )).

% 5. holds means it holds on the whole checked range.
theorem(holds_means_holds) :- forall(( rewrite(R), prove(R, holds) ), ( copy_term(R, L = Rhs), term_variables(L = Rhs, Vs), forall(maplist([V]>>between(-6, 6, V), Vs), L =:= Rhs) )).
