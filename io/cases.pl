:- module(cases, [title/1, case/3]).
:- use_module('../prolog/proofcache').
:- use_module(engine).
title('proofcache').
side_g(E, X, Y) :- rnd_pick([X, Y, X + X, X * 2, 2 * X, X * X, X + Y, Y + X, X - X, 0, X * Y, (X + 1) * 2, 2 * X + 2, X * X - Y * Y, (X + Y) * (X - Y)], E).
rw_g(L = R) :- side_g(L, X, Y), side_g(R, X, Y).
case(prove, [R], prove) :- rw_g(R).
case(key, [R], key) :- rw_g(R).
case(cached_all, [Rs], cached_all_stats) :- rnd_int(1, 6, N), length(Rs, N), maplist(rw_g, Rs).
cached_all_stats(Rs, stats(Res, hits(H), misses(M))) :- cached_all(Rs, Res, H, M).
