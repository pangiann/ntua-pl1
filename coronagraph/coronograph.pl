% Predicates that read the input
% https://courses.softlab.ntua.gr/pl1/2019a/Exercises/read_colors_SWI.pl

%------------------------------------------------------------%
read_input(File, N, G, TempAns, Answer) :-
  open(File, read, Stream),
  read_line(Stream, [N]),
  read_graph(Stream, N, G, TempAns, [], Answer), !.


read_graph(_, 0, _, _, Answer, Answer).
read_graph(Stream, N, G, TempAns, Aux, Answer) :-
  read_line(Stream, [V, E]),
  read_lines(Stream, E, [], C),
  append(C, C1),
  (V =\= E -> append(["'NO CORONA'"], Aux, Naux)
   ; create_graph(V, E, C1, G, TempAns),
      append([TempAns], Aux, Naux)
  ),
  N1 is N - 1,
  read_graph(Stream, N1, _G, _T,  Naux, Answer)
.

read_line(Stream, L) :-
  read_line_to_codes(Stream, Line),
  atom_codes(Atom, Line),
  atomic_list_concat(Atoms, ' ', Atom),
  maplist(atom_number, Atoms, L)
.

read_lines(_, 0, C, C).
read_lines(Stream, N, Acc, C) :-
  read_line(Stream, L),
  N1 is N - 1,
  read_lines(Stream, N1, [L|Acc], C)
.

%------------------------------------------------------------%

add_edges(_, [], _).
add_edges(E, [V1, V2 | Tail], G) :-

   ( arg(V1, G, L), var(L) -> arg(V1, G, [V2])
   ; arg(V1, G, L),
     setarg(V1, G, [V2 | L])
   ),

   ( arg(V2, G, L1), var(L1) -> arg(V2, G, [V1])
   ; arg(V2, G, L1),
     setarg(V2, G, [V1 | L1])
   ),
   add_edges(E, Tail, G)
.

%------------------------------------------------------------%
%-------------------INITIALIZE ARRAYS------------------------%

initialize(Vis, 0, Vis).
initialize(Visited, V, Vis) :-
  arg(V, Visited, 0),
  V1 is V - 1,
  initialize(Visited, V1, Vis)
.


%------------------------------------------------------------%
%------------------------DFS---------------------------------%
parse_list([], _, VisN, _, VisN).
parse_list([X | Tail], G, Visited, Cnt, VisN) :-
  ( arg(X, Visited, B), B = 1 -> parse_list(Tail, G, Visited, Cnt, VisN)
  ; dfs(G, Visited, X, Cnt, VisN),
    parse_list(Tail, G, Visited, Cnt, VisN)
  ).


dfs(G, Visited, Vi, Cnt, VisN) :-
  arg(Vi, G, Li),
  arg(1, Cnt, T),
  T1 is T + 1,
  setarg(1, Cnt, T1),
  setarg(Vi, Visited, 1),
  parse_list(Li, G, Visited, Cnt, VisN)
.

%------------------------------------------------------------%
%--------CHECK IF ALL VERTICES ARE VISITED-------------------%

isConnected(_, 0, Res, IsC) :- IsC = Res.
isConnected(Visited, V, _, IsC) :-
  ( arg(V, Visited, B), B = 0 -> isConnected(_V, 0, false, IsC)
  ; V1 is V - 1,
    isConnected(Visited, V1, true, IsC)
  ).

%------------auxiliary-predicators-to-find-cycle-------------%
%------------------------------------------------------------%
cycle_aux2([], _, _, _, _, _, _Path, _InCycle).
cycle_aux2([H | T], G, Res, X, Par, Col, Path, InCycle) :-
( H = Par -> cycle_aux2(T, G, Res, X, Par, Col, Path, InCycle)
; cycle(G, H, X, Col, Res, Path, InCycle),
  cycle_aux2(T, G, Res, X, Par, Col, Path, InCycle)
).



%------------------------------------------------------------%
cycle_aux_first(X, [H | T], [], Res, InCycle) :-
( H =\= X -> cycle_aux_first(X, T, [], Res, InCycle)
; setarg(H, Res, 1),
  cycle_aux(X, T, [H], Res, InCycle)
).
cycle_aux(_, [], _, Res, InCycle) :- InCycle = Res.
cycle_aux(X, [H | T], Acc, Res, InCycle) :-
  setarg(H, Res, 1),
  cycle_aux(X, T, Acc, Res, InCycle)
.

%------------------------------------------------------------%



stop(X, T) :- T = X.
cycle(G, X, Par, Col, Res, Path, InCycle) :-
(
  % completely visited a vertex
  arg(X, Col, N), N = 2 -> stop(X, _T)

  % found cycle
 ; arg(X, Col, N1), N1 = 1 ->
   append([X], Path, NewPath),
   reverse(NewPath, PathC),
   % save cycle path to an array
   cycle_aux_first(X, PathC, [], Res, InCycle), !

 % first time we visit this vertex
 ; arg(X, Col, N2), N2 = 0 ->
   setarg(X, Col, 1),
   arg(X, G, L),
   append([X], Path, NewPath),
   % parse all neighbors of a vertex
   cycle_aux2(L, G, Res, X, Par, Col, NewPath, InCycle),
   setarg(X, Col, 2)

).

%------------------COPY TWO ARRAYS---------------------------%
copy(Nvis, _, 0, Vis1) :- Vis1 = Nvis.
copy(Nvis, InCycle, V, Vis1) :-
  arg(V, InCycle, I),
  arg(V, Nvis, I),
  V1 is V - 1,
  copy(Nvis, InCycle, V1, Vis1).

%------------------------------------------------------------%


%------------------------------------------------------------%
%------------count-number-of-vertices------------------------%
end(L1, List) :- List = L1.
count_trees(G, Vis1, InCycle, Cnt, V, L1, List) :-
  ( V = 0 -> end(L1, List)
  ; arg(V, InCycle, X), X = 0 -> V1 is V - 1, count_trees(G, Vis1, InCycle, Cnt, V1, L1, List)
  ; dfs(G, Vis1, V, Cnt, VisN),
    arg(1, Cnt, I),
    setarg(1, Cnt, 0),
    append([I], L1, Ln),
    V1 is V - 1,
    count_trees(G, VisN, InCycle, Cnt, V1, Ln, List)
  ).


%------------------------------------------------------------%

create_graph(V, E, C, G, Ans) :-
  functor(G, graph, V),    % create graph (array of lists)
  add_edges(E, C, G),      % add all edges
  functor(Visited, visited, V),
  initialize(Visited, V, Vis),
  functor(Cnt, counter, 1),
  arg(1, Cnt, 0),
  dfs(G, Vis, 1, Cnt, VisN), % call dfs to check if graph is connected
  isConnected(VisN, V, _, IsC), % graph is connected if all vertices are visited from one
  (IsC = false -> Ans = "'NO CORONA'", !  % if not 'print' no corona
  ; functor(Colors, colors, V),   % else create Colors Result and InCycle arrays
    initialize(Colors, V, Col),
    functor(Result, result, V),
    initialize(Result, V, Res),
    cycle(G, 1, 1, Col, Res, [], InCycle),  % find cycle
    functor(Nvis, vis, V),
    copy(Nvis, InCycle, V, Vis1),
    setarg(1, Cnt, 0),
    count_trees(G, Vis1, InCycle, Cnt, V, [], List),  % count numb_of_vert for every vertex included in cycle
    length(List, R),
    msort(List, S),
    append([R, S], [], Ans)
  ).

%------------------------------------------------------------%
coronograph(File, Answer) :-
  read_input(File, _X, _G, _T, Ans),
  reverse(Ans, Answer).
