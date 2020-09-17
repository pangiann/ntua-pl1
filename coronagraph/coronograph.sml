
(*****************************************************************************************************
  Course    : Programming Languages 1 - Assignment 2 - Exercise 1
  Author   : pangiann (aka Panagiotis Giannoulis) (pangiann134ever@gmail.com)
  Date      : April, 2020
  Note      : Solved the problem in five steps:
              1) After we have parsed the input, we create the graph.
              2) Check if # edges == # vertices , if not exit with no corona
              2) else for each graph we check if it's connected.
              3) If so, we know that we have exactly one cycle, we find it 
              4) Then we find number of vertices of trees with
              root vertex inlcuded in cycle else return NO CORONA
  -----------
  School of ECE, National Technical University of Athens.
******************************************************************************************************)


(* The function 'parse' is based on the one publicly available here:
https://courses.softlab.ntua.gr/pl1/2013a/Exercises/countries.sml *)

local
  fun parse file =
      let
        (* A function to read an integer from specified input. *)
        fun readInt input =
           Option.valOf (TextIO.scanStream (Int.scan StringCvt.DEC) input)

           (* Open input file. *)
           val inStream = TextIO.openIn file

           (* Read T and consume newline. *)
           val t = readInt inStream

           val  _ = TextIO.inputLine inStream
           
           (* Read t graphs *)
           fun readtgraphs t l1 = 
             if t <> 0 then
               let
                 val v = readInt inStream
                 val e = readInt inStream
                 (* A function to read 2 * edges ( 2 vertices for each edge )  integers  *)
                 fun readInts 0 (acc : int list) = acc (*Replace with 'rev acc' for proper order. *)
                     | readInts i acc = readInts (i - 1) (readInt inStream :: acc)
               in
                 (readtgraphs (t-1) (readInts (2*e) (e::v::l1)))
               end
             else
               l1        
      in
          (t, readtgraphs (t) [])
      end

  fun first (x, _, _) = x
  fun firstFrom2 (x, _) = x

  fun second (_, x, _) = x
  fun secondFrom2 (_, x) = x



  (* A signature for undirected graphs.*)
  signature GRAPH = sig
    type graph  (* A undirected graph comprising a set of vertices
                 * V and undirected edges E  *)
    type vertex (* A vertex, or node, of the graph *)
    type edge   (* A edge of the graph *)

    val create_graph: int -> graph

    (* add_edge(src,dst) adds an edge from src to dst *)

    val add_edge: graph * int * int  -> graph
    (* checks if graph is connected *)
    val connected_graph: graph -> bool
    (* dfs , we all know what it is *)
    val dfs : graph * bool array * int * int ref -> unit
    (* find cycles in a graph *)
    val cycle : graph * int * int * int array * bool array * int list  -> unit
   end

  structure Graph : GRAPH = struct 
    type vertex = (int list) 
    type edge = int*int
    type graph = vertex array

    (* create an empty graph of v vertices *)
    fun create_graph (v : int) =
       Array.array(v, [])
    (* add_edge in undirected graph and return the updated graph *)
    fun add_edge(g: graph, src: int, dst: int) =
      let
        val v1 = Array.sub(g, src)
        val v2 = Array.sub(g, dst)
      in
        Array.update(g, src, dst::v1);
        Array.update(g, dst, src::v2);
        g
      end



    (* this is a dfs implementation with a pointer (ref) to an integer counter so as 
     * to count vertices we passed through *) 
    fun dfs (g: graph, visited : bool array, x: int, count: int ref) = 
      let
        val l1 = Array.sub(g, x)
        val t1 = Array.update(visited, x, true)
      in
        let
          fun aux [] visited = ()
            | aux (x::xs) visited =
              if Array.sub(visited, x) = true then 
                aux (xs) (visited)
              else
                  (dfs (g, visited, x, count);
                  aux (xs) (visited);
                  ())
        in
          (count := (!count) + 1;
          aux l1 visited;
          ())
        end
      end

    fun connected_graph(g : graph) = 
      let 
        val len = Array.length g;
        val visited = Array.array(len, false)
        val count = ref 0
      in
        (dfs (g, visited, 0, count);
        if !count <> len then
          false
        else
          true)
        
      end
      
    (* print list of integers *)
    fun print_list [] = ()
      | print_list [x] = print(Int.toString(x)^"\n")
      | print_list (x::xs) = 
          (print(Int.toString(x)^(" ")); print_list xs)
    
    (* print array of integers *)
    fun print_arr arr cnt = 
      if (cnt = Array.length(arr) - 1) then
        (print(Int.toString(Array.sub(arr, cnt))^"\n"))
      else
        (print(Int.toString(Array.sub(arr, cnt))^" "); print_arr arr (cnt+1))


    (* strange function, when I wrote it only me and God knew what this function
    * does, now only God knows *)    
    fun cycle (g: graph,  v: int, par: int, colors: int array, res: bool array, path: int list) =
      (* if we find an already 
       * completely visited vertex *)
      if Array.sub(colors, v) = 2 then ()
      
      (* cycle detected *)
      else if Array.sub(colors, v) = 1 then
        let
          (*val k = (print("v = "^Int.toString(v)^"\n"))*)
          fun aux (v, [], l1 : int list) = ()
            | aux (v, (x::xs), []) = 
              if x <> v then 
                aux (v, xs, [])
              else
                (Array.update(res, x, true); aux (v, xs, [x]))
            | aux (v, (x::xs), l1) = 
                (Array.update(res, x, true); aux (v, xs, x::l1))
        in
          aux (v, List.rev (v::path), [])
        end
      else
        let 
          val temp = Array.update(colors, v, 1)
          val l = Array.sub(g, v)
          fun cycle_aux ([], v, par, colors, path) = ()
            | cycle_aux (x::xs, v, par, colors, path) = 
              if x = par then 
                cycle_aux(xs, v, par, colors, path)
              else
                (*let 
                  (*val k = print("x = "^Int.toString(x)^"\n")
                  *val w = print("v = "^Int.toString(v)^"\n")
                  *val k = print("par = "^Int.toString(par)^"\n")
                  *val k = (print("path = "); print_list path)
                  *val k = (print("colors = "); print_arr (colors) (0))
                  *)
                  val temp = cycle(g, x, v, colors, res, path, counter) 

                in*)
                  (cycle(g, x, v, colors, res, path); 
                  cycle_aux(xs, v, par, colors, path))
                (*end*)

        in
          cycle_aux(l, v, par, colors, v::path);
          Array.update(colors, v, 2)
        end
  end



  fun find_num_vert (g, visited, in_cycle, cnt, num, res, s) =
    if cnt = num then !s
    (* if vertex is part of cycle call dfs with start point this vertex else
      * go to the next vertex *)
    else if Array.sub(in_cycle, cnt) = false then 
      find_num_vert(g, visited, in_cycle, cnt+1, num, res, s)
    else 
      let 
        open Graph
        val counter = ref 0
      in
        (dfs(g, visited, cnt, counter);
        Array.update(res, cnt, !counter); s := (!s) + 1;
        find_num_vert (g, visited, in_cycle, cnt+1, num, res, s); !s)
      end


  fun corona (g, num: int) =
    let
      (* create all necessary structures for our problem *)
      open Graph
      val colors   = Array.array(num, 0) 
      val in_cycle = Array.array(num, false)
      val vis      = Array.array(num, false)
      (* call cycle to see if we have one cycle and the vertices included in that cycle *)
      val temp     = cycle(g, 0, 0,  colors, in_cycle, []) 
      fun print_arr arr cnt = 
        if (cnt = Array.length(arr) - 1) then
          (print(Int.toString(Array.sub(arr, cnt))^"\n"))
        else
          if (Array.sub(arr, cnt) = 0) then
            print_arr (arr) (cnt+1)
          else
            (print(Int.toString(Array.sub(arr, cnt))^" "); print_arr arr (cnt+1))
    in
      (*else find number of vertices for each tree with root a vertex included in cycle*)
      let
        val visited = Array.array(num, false)
        val res     = Array.array(num, 0)
        val temp    = Array.copy {di=0, dst=visited, src=in_cycle}
        val s       = ref 0
        val s       = find_num_vert (g, visited, in_cycle, 0, num, res, s)  
      in 
        (print ("CORONA "^Int.toString(s)^"\n"); ArrayQSort.sort Int.compare (res); print_arr (res) (0))
      end
    end



  fun print_list [] = ()
    | print_list [x] = print(Int.toString(x)^"\n")
    | print_list (x::xs) = 
        (print(Int.toString(x)^(" ")); print_list xs)
in
  fun coronograph inputFile = 
    let
      open Graph
      val inputTuple = parse inputFile
      val t = firstFrom2 inputTuple
      val l1 = secondFrom2 inputTuple (* a list of the input after the given number of graphs reversed*)
      fun coronograph_aux [] = ()
        | coronograph_aux [x] = ()
        | coronograph_aux (v::e::xs) = (* take num of vertices and edges *) 
        if v = e then 
          let
            val g1 = create_graph v 
            fun create (g1) (0) [] = []
              | create (g1)  _  [] = []
              | create (g1) (0) (l) = l
              | create (g1) (_) ([x]) = [x]
              | create (g1) (y) (v1::v2::xs) = 
                 (add_edge(g1, (v1-1), (v2-1)); create (g1) (y-1) (xs))
          in
            let
              val l = create (g1) (e) (xs) (* create one graph at a time and run corona for that *) 
              val temp = connected_graph(g1)
            in
              (if temp = true then  
                corona(g1, v)
              else
                print("NO CORONA\n"));
              coronograph_aux l
            end
        end
        else 
          let
            fun parse_input 0 [] = []
              | parse_input _ [] = []
              | parse_input 0 l  =  l
              | parse_input _ [x] = [x]
              | parse_input y (v1::v2::xs) = 
                parse_input (y-1) (xs)
          in
            (print("NO CORONA\n");
            coronograph_aux (parse_input e xs))
          end
   in
     coronograph_aux (List.rev l1)
   end
(*
   fun main() =
    let
        inputFile = CommandLine.arguments ()
    in
        coronograph (hd inputFile)
    end
    val _ = main()
    *)
end
