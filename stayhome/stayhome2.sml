
(* The function 'parse' is based on the one publicly available here:
https://courses.softlab.ntua.gr/pl1/2013a/Exercises/countries.sml *)

fun parse file =
    let
  	    (* Open input file. *)
      	val inStream = TextIO.openIn file

        fun readLines acc =
          let
            val newLineOption = TextIO.inputLine inStream
          in
            if newLineOption = NONE
            then (List.rev acc)
            else ( readLines ( explode (valOf newLineOption ) :: acc ))
        end;

        val grid = readLines []
        val M = length (hd grid) - 1
        val N = length grid
    in
   	    (N,M,grid)
end;




fun tupleCompare ((x1,y1), (x2,y2)) =
  let
    val firstTuple = Int.compare (x1,x2)
    val secondTuple = Int.compare (y1,y2)
  in
    if (firstTuple = EQUAL) then
      secondTuple
    else firstTuple
  end

fun tupleMin (x1,y1) (x2,y2) =
  if x1 < x2 then
    (x1, y1)
  else if x1 = x2 andalso y1 < y2 then
    (x1,y1)
  else
    (x2,y2)


fun min x1 y1 =
  if x1 < y1 then
    x1
  else y1

fun secondFrom (_, x) = x

fun firstFromTwo (x, _) = x

structure M = BinaryMapFn(
  struct
    type ord_key = int * int
    val compare = tupleCompare
  end
)

fun print_map map 0 _ _ = ()
  | print_map map n m i =
    let
      fun printLines map i j =
        if j < m then
          let
            val item = (M.find(map, (i, j)))
            val value = firstFromTwo (valOf item)
            val pos = secondFrom (valOf item)
          in
            (print(Int.toString(value));
             print("("^(Int.toString(firstFromTwo pos))^","^(Int.toString(secondFrom pos))^") ");
             printLines map i (j+1) )
          end
        else ()
    in
      (printLines map (i)   (0);
       print("\n");
       print_map  map (n-1) (m) (i+1))
    end

(*returns an integer (time)*)
fun find_time item time airport corona_flood =
   case item of
      NONE    => ~2
    | SOME a  =>
        if a <> #"X" andalso a <> #"A" then
            time
        else if a = #"A" andalso corona_flood then
            if !airport = 0 then
                (airport := time;
                time)
            else
                time
        else if a = #"A" then
            time
        else
            ~1


(*returns a tuple of 4 integers*)
fun watch_neighbors time corona_pos map airport corona_flood =
  case corona_pos of
   (i1, i2, i3, i4) =>
     let
       val resl  = find_time (M.find(map, i1)) (time) (airport) (corona_flood)
       val resr  = find_time (M.find(map, i2)) (time) (airport) (corona_flood)
       val resd  = find_time (M.find(map, i3)) (time) (airport) (corona_flood)
       val resu  = find_time (M.find(map, i4)) (time) (airport) (corona_flood)
    in
       (resl, resr, resd, resu)
    end

fun outOfBounds (x1, y1) (x2, y2) =
  if (x1 >= x2) orelse (y1 >= y2) orelse x1 < 0 orelse y2 < 0 then
    true
  else false


(* returns updated map *)
fun update_world world q pos state parent =
  if M.find(world, pos) = NONE andalso state <> ~2   then
    if state <> ~1 then
      (Queue.enqueue (q, (pos, state));
       M.insert(world, pos, (state, parent)))
    else
      M.insert(world, pos, (state, parent))
  else
    world

(* returns  binary map after updating all neighbors *)
fun  my_world world (time) (pos : (int * int)) (map) (q) (airport)  (corona_flood) =
  let
    val x = #1 pos
    val y = #2 pos

    val l_p = (x, y-1)
    val r_p = (x, y+1)
    val d_p = (x+1,y)
    val u_p = (x-1, y)

    val neighbor_state = watch_neighbors (time) (l_p, r_p, d_p, u_p)  (map) (airport) (corona_flood)
    val left = #1 neighbor_state
    val right= #2 neighbor_state
    val down = #3 neighbor_state
    val up   = #4 neighbor_state

  
    val world1 = update_world (world)  (q) (d_p) (down)  (pos)
    val world2 = update_world (world1) (q) (l_p) (left)  (pos)
    val world3 = update_world (world2) (q) (r_p) (right) (pos)
    val world4 = update_world (world3) (q) (u_p) (up)    (pos)
  in
    world4
  end



fun push_airports time q [] corona parent = corona
  | push_airports time q (x::xs) corona parent =
    let
      val cor = M.find(corona, x)
    in
      if cor = NONE then
        (Queue.enqueue(q, (x, time));
        push_airports time q xs (M.insert(corona, x, (time, parent))) (parent) )
      else
        push_airports time q xs (corona) (parent)
    end




fun bfs_corona start N M  map l_air =
  let
    val q       = Queue.mkQueue () : ((int * int) * int  ) Queue.queue
    val temp    = Queue.enqueue(q, (start, 0))
    val cor     = M.empty
    val corona  = M.insert(cor, start, (0, (~1, ~1)))
    val airport = ref 0
    val air_inf = ref false
    fun aux_bfs q corona map time curr_pos =
    (* nowhere else to go *) (*virus has come to airport*)  (*airports not already infected*)
      if Queue.isEmpty(q) andalso !airport <> 0 andalso !air_inf <> true then
        (* virus now infects all other airports *)
         let
           val new_corona = push_airports (!airport + 5) (q) (l_air) (corona) (curr_pos)
          in
           (air_inf := true;
            aux_bfs (q) (new_corona) (map) (time+5) (curr_pos))
          end
      else if Queue.isEmpty(q) then corona
      else
        let
          val a_corona =
            if (!airport <> 0 andalso time - !airport = 4 andalso !air_inf <> true) then
               (air_inf := true;
                push_airports (!airport + 5) (q) (l_air) (corona) (curr_pos))
            else corona
          (*val temp = print("all ="^Int.toString(M.numItems(corona))^"\n")*)
          val posAndtime = Queue.dequeue(q)
          val pos = #1 posAndtime
          val time = #2 posAndtime
          (*val temp = print("pos = "^(Int.toString(#1 pos))^","^(Int.toString(#2 pos))^"\n")
          val temp2 = print("time = "^Int.toString(time)^"\n")*)
          val new_corona = my_world (a_corona) (time+2) (pos) (map) (q) (airport) (true)
        in
          aux_bfs q new_corona map (time+2) pos
        end
  in
    let
       val corona = aux_bfs q corona map 0 start
    in
      (*print_map (corona) (N) (M) (0);*)
      corona
    end
  end





fun findInfo map N M =
  let
    fun loop ~1 ~1 acc = acc
      | loop i j (S, T, W, list_airports) =
      let
        val item = valOf (M.find(map, (i, j)))

        val start =
          if item = #"S" then
            (i, j)
          else S
        val home =
          if item = #"T" then
            (i, j)
          else T
        val air =
          if item = #"A" then
            ((i, j) :: list_airports)
          else list_airports
        val cor =
          if item = #"W" then
            (i, j)
          else W

        val nextIter =
          if j = M-1 andalso i <> N-1 then
            (i+1,0)
          else if j = M-1 andalso i = N-1 then
            (~1,~1)
          else (i,j+1)
      in
        loop (#1 nextIter) (#2 nextIter) (start, home, cor, air)
      end
  in
    loop 0 0 ((~1, ~1), (~1, ~1), (~1,~1),[])
  end




fun insertLine map [] i row m  = map
  | insertLine map (x::xs) i row m =
    if  row < m then
      insertLine (M.insert(map, (i, row), x)) xs i (row+1) m
    else
      map



fun createMap  map [] _ m = map
  | createMap  map (x::xs) i m =
     createMap  (insertLine map (x) (i) 0 m) (xs) (i+1) m

fun print_list ([] : (int*int) list) = ()
  | print_list (x::xs) =
    (*(print("A = "^(Int.toString(#1 x))^","^(Int.toString(#2 x))^"\n");*)
    print_list xs

fun print_path ([] : char list) = print("\n")
  | print_path (x::xs) =
    (print(Char.toString(x));
     print_path xs
    )

fun  coronaVsSotiris (start_pos: int * int) (end_pos: int * int) (corona:  (int * (int * int)) M.map) (map: char M.map) N M =
  let
     val q = Queue.mkQueue () : ((int * int) * int) Queue.queue
     val temp = Queue.enqueue(q, (start_pos, 0))
     val sotos = M.empty
     val sotiris = M.insert(sotos, start_pos, (0, (~1, ~1)))

     val airport = ref 0
     fun bfs_aux (corona:  (int * (int * int)) M.map) (q) (sotiris: (int * (int * int)) M.map) (map: char M.map) (pos: int * int) (time: int) =
        if Queue.isEmpty(q) then (sotiris, pos, time)
        else
          let
            val posAndtime = Queue.dequeue(q) : (int * int) * int
            val pos = #1 posAndtime
            val time = #2 posAndtime

            val cor_cell = M.find(corona, pos)
            val cor_time =
              if cor_cell = NONE then  ~1
              else
                (firstFromTwo  (valOf (cor_cell)))

            (*val temp = print("cor_time = "^Int.toString(cor_time)^"\n")
            val temp = print("time = "^Int.toString(time)^"\n")
            val temp = print("pos = "^(Int.toString(#1 pos))^","^(Int.toString(#2 pos))^"\n")
            val temp2 = print("time = "^Int.toString(time)^"\n")*)
            val stop = cor_time <> ~1 andalso cor_time <= time


            val new_sotiris =
              if stop then sotiris
              else my_world (sotiris) (time+1) (pos) (map) (q) (airport)  (false)
          in
            if pos = end_pos then
                (Queue.clear(q);
                (new_sotiris, pos, time))
            else
              bfs_aux (corona) (q) (new_sotiris) (map) (pos) (time)
          end
  in
    bfs_aux (corona) (q)  (sotiris) (map) (start_pos) (0)
  end

fun find_move (x1, y1) (x2, y2) =
  case (x2 - x1) of
     1  => #"D"
  | ~1  => #"U"
  |  0  =>
        case (y2 - y1) of
           1 =>  #"R"
        | ~1 =>  #"L"



fun min_pos val1 val2 pos1 pos2 =
  if val2 = ~1 then (pos1, val1)
  else if val1 = ~1 orelse val2 < val1 then (pos2, val2)
  else (pos1, val1)



fun find_path (sotiris: (int * (int * int)) M.map) (pos: int * int) (acc : char list) =
    let
       val father = #2 (valOf (M.find(sotiris, pos)))
    in
       if father = (~1, ~1) then acc
       else find_path sotiris father ((find_move (father) (pos))::acc)
    end





fun stayhome inputFile =
  let
    val inputTuple = parse inputFile
    val n = #1 inputTuple
    val m = #2 inputTuple
    val grid = #3 inputTuple
    val map = createMap (M.empty) (grid) (0) (m)
    val (S, T, W, l_a) = findInfo map n m
    val t = print_list l_a
    val new_corona = bfs_corona (W) (n) (m) (map) (l_a)
    val (sot, end_pos,  time) = coronaVsSotiris (S) (T) (new_corona) (map) (n) (m)
  in
      if (end_pos <> T) then print("IMPOSSIBLE\n")
      else
        (print(Int.toString(time)^"\n");
        print_path (find_path (sot) (T) ([])))

  end
