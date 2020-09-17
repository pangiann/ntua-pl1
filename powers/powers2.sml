
(*****************************************************************************************************
  Course    : Programming Languages 1 - Assignment 1 - Exercise 1
  Author   : pangiann (aka Panagiotis Giannoulis) (pangiann134ever@gmail.com)
  Date      : April, 2020
  -----------
  School of ECE, National Technical University of Athens.
******************************************************************************************************)


local

  type long = Int64.int

  (* The function 'parse' is based on the one publicly available here:
  https://courses.softlab.ntua.gr/pl1/2013a/Exercises/countries.sml *)


  fun parse file =
      let
        (* A function to read an integer from specified input. *)
        fun readInt input =
           Option.valOf (TextIO.scanStream (Int64.scan StringCvt.DEC) input)

           (* Open input file. *)
           val inStream = TextIO.openIn file

           (* Read T and consume newline. *)
           val t = 2*(readInt inStream)
           val  _ = TextIO.inputLine inStream
        (* A function to read 2 * T integers  *)
        (* List.rev from List lib is used to reverse a list *)
        fun readInts 0 (acc : long list)  = List.rev acc (*Replace with 'rev acc' for proper order. *)
          | readInts i acc = readInts (i - 1) (readInt inStream :: acc)
      in
          (t, readInts (t) [])
      end


  fun first (x, _, _) = x
  fun firstFrom2 (x, _) = x

  fun second (_, x, _) = x
  fun secondFrom2 (_, x) = x

  fun max x y =
    if x > y
    then x
    else y

  fun power (base : long, exp) =
     if exp = 0 then 1
     else if exp mod 2 = 0 then power (base*base, exp div 2)
     else base * power (base*base, (exp - 1) div 2)


  (* find max power of 2 to smaller of x *)
  fun exp (x : long) l count =
    if l <= x then
      exp (x) (l * 2) (count+1)
    else
      count - 1

  fun print_list [] _ = ()
    | print_list (x::xs) 0 =
       (print(Int64.toString(x));
        () )
    | print_list (x::xs) pr = 
       (print(Int64.toString(x)^",");
        print_list (xs) (pr-1);
        ())
       

  fun push_one_aux ([] : long list) (aux : long list) j (sum : long) (n : long) = (List.rev aux, j)
    | push_one_aux [x] aux j sum n = (List.rev (x::aux), j)   
    | push_one_aux (x::y::xs) aux j sum n = 
      let
        val p = power (2, j)
      in
        if sum + p - 1 <= n then
          let
            val x = x - 1
            val y = y + 1
          in
           push_one_aux (y::xs) (x::aux) (j+1) (sum) (n)
          end
        else
          ((List.rev (y::x::aux)) @ xs, j)
      end



  fun allTheWay ([] : long list)  (sum : long)  (n : long) res pr = ()
    | allTheWay (x::xs) (sum) (n) res pr =
      if sum < n andalso  x <> 0 then
          let
            val (l1, j) = push_one_aux (x::xs) ([]) (1) (sum) n
            val j = secondFrom2 (l1, j)
            val l1 = firstFrom2 (l1, j)
            val pr = max pr (j-1)
            val sum = sum + power (2, j-1) - 1
          in
            allTheWay (l1) (sum) (n) (res) pr
          end
      else
        if sum <> n then
          print("[]\n")
        else
          (print("[");
          print_list (x::xs) pr;
          print("]\n");
          ())

  fun create_list (mylist : long list) x  = 
    if x <> 0 then
      create_list (0 :: mylist) (x-1)
    else
      mylist
  in

  fun powers2 inputFile =
      let
        val inputTuple = parse inputFile
        val t = firstFrom2 inputTuple
        val (l1 : long list)  = secondFrom2 inputTuple
        fun powers_aux ([] : long list)  = ()
          | powers_aux [x] = () 
          | powers_aux (x::y::xs) =
              let
                val l = exp (x) 1 0
                val mylist = List.rev (create_list [y] (l))
              in
                allTheWay (mylist) (y) (x) (l+1) 0;
                powers_aux xs
              end
      in
        powers_aux l1
      end
end
