% Predicates that read the input
% https://courses.softlab.ntua.gr/pl1/2019a/Exercises/read_colors_SWI.pl

read_input(File, N, C) :-
    open(File, read, Stream),
    read_line(Stream, [N]),
    read_lines(Stream, N, [], C).

read_line(Stream, L) :-
    read_line_to_codes(Stream, Line),
    atom_codes(Atom, Line),
    atomic_list_concat(Atoms, ' ', Atom),
    maplist(atom_number, Atoms, L).

read_lines(_, 0, C, C).


read_lines(Stream, N, Acc, C) :-
    read_line(Stream, L),
    N1 is N - 1,
    read_lines(Stream, N1, [L|Acc], C)
.




push_one([], Res, J, J, Res).

push_one([X], Aux_list, J, _Sum, _N, ResJ, ResList) :-
    append([X], Aux_list, L1),
    reverse(L1, L2),
    push_one([], L2, J, ResJ, ResList), !
.

push_one([X, Y | Tail], Aux_list, J, Sum, N, ResJ, ResList) :-
    P is 2 ** (J+1),
    ( Sum + P - 1 > N ->
        append([Y, X], Aux_list, L1),
        reverse(L1, L2),
        append(L2, Tail, L3),
        push_one([], L3, J, ResJ, ResList)
     ;  X1 is X - 1,
        Y1 is Y + 1,
        J1 is J + 1,
        append([X1], Aux_list, L2),
        push_one([Y1|Tail], L2, J1, Sum, N, ResJ, ResList)
    ).



allTheWay([], Sum, N, Acc, L) :-
    ( Sum =\= N -> L = []
     ; L = Acc
    ).
allTheWay([X|Tail], N, Sum, List) :-
    ( Sum < N, X =\= 0 ->
        push_one([X|Tail], [], 0, Sum, N, J, ResList),
        P is 2 ** (J),
        Sum1 is Sum + P - 1,
        allTheWay(ResList, N, Sum1, List)
        ; allTheWay([], Sum, N, [X|Tail], List)
    ).



build1(First, X, N1, [First | L]) :-
    build(X, N1, L),!.

build(_,0,[]).


build(X, N1, [X|L]) :-
  N1 > 0,
  N is N1 - 1,
  build(X,N,L).


exp(Result, Result).
exp(M, Y, X, Count, Result) :-
    (X + Y =< M -> X1 is X * 2,
        CountN is Count + 1,
        exp(M, Y, X1, CountN, Result)
    ; Res is Count - 1,
      exp(Res, Result)
    ).



powers_aux([], Final, Final).
powers_aux([X, Y | Tail], Aux, Final) :-

    exp(X, Y, 1, 0, Nlog),
    /* Nlog variable is logN with base 2 */
    build1(Y, 0, Nlog, L),
    allTheWay(L, X, Y, Res),
    append([Res], Aux, L1),
    powers_aux(Tail, L1, Final)
    .




powers2(File, Answer) :-
    read_input(File, _, C),
    append(C, C1),
    powers_aux(C1, [], Answer),
    !
    .
