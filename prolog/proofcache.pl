% proofcache: a shared cache of proven rewrites, so a rewrite proven once is reused everywhere.
% A rewrite is Lhs = Rhs over arithmetic in variables; it is checked on every assignment of
% its variables to -6..6 (a bounded proof), and the result is stored under the rewrite's
% canonical form, so x*2 = x+x and y*2 = y+y share one entry. The cache is a value, passed
% in and out, so it can be saved as a file and shared between repos.
%?- prove(X * 2 = X + X, R).                                   % R = holds
%?- prove(X * X = X + X, R).                                   % R = fails_at([X = 3]) style counterexample
%?- empty(C0), cached(C0, A * 2 = A + A, R1, C1, H1), cached(C1, B * 2 = B + B, R2, _, H2).  % H1 = miss, H2 = hit
:- module(proofcache, [key/2, prove/2, empty/1, cached/5, size/2, cached_all/4]).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(assoc)).

key(R, K) :- copy_term(R, K0), numbervars(K0, 0, _), format(string(S), "~q", [K0]), K = S.

% prove(+Rewrite, -Result): holds, or fails_at(Bindings) for the first assignment that breaks it.
prove(R, Res) :- copy_term(R, Lhs = Rhs), term_variables(Lhs = Rhs, Vs),
    (   assign(Vs), catch(\+ (Lhs =:= Rhs), _, true) -> pairs_of(Vs, Bs), Res = fails_at(Bs)
    ;   Res = holds ).
assign(Vs) :- maplist([V]>>between(-6, 6, V), Vs).
pairs_of(Vs, Bs) :- length(Vs, N), numlist(1, N, Is), maplist([I, V, x(I) = V]>>true, Is, Vs, Bs).

empty(C) :- empty_assoc(C).
size(C, N) :- assoc_to_keys(C, Ks), length(Ks, N).

% cached(+Cache0, +Rewrite, -Result, -Cache, -HitOrMiss)
cached(C0, R, Res, C, H) :- key(R, K), ( get_assoc(K, C0, Res0) -> Res = Res0, C = C0, H = hit ; prove(R, Res0), Res = Res0, put_assoc(K, C0, Res0, C), H = miss ).

% cached_all(+Rewrites, -Results, -Hits, -Misses): prove a batch through one cache.
cached_all(Rs, Res, Hits, Misses) :- empty(C0), foldl([R, X, C-H0-M0, C1-H1-M1]>>( cached(C, R, X, C1, HM), ( HM == hit -> H1 is H0 + 1, M1 = M0 ; M1 is M0 + 1, H1 = H0 ) ), Rs, Res, C0-0-0, _-Hits-Misses).
