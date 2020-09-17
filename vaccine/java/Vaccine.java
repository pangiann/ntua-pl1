import java.util.*;
import java.io.*;

public class Vaccine {
  public static char compl(char x) {
    if (x == 'A') return 'U';
    if (x == 'U') return 'A';
    if (x == 'C') return 'G';
    if (x == 'G') return 'C';
    return x;

  }

  public static void main (String[] args) {
    char[] temp = new char[100];
    Vector<Character> rna = new Vector<Character>();
    Vector<Character> vaccine = new Vector<Character>();
    Hashtable<Character, Integer> inVaccine = new Hashtable<Character, Integer>();
    StackState result;

    try {
      File input = new File(args[0]);
      BufferedReader reader = new BufferedReader (new FileReader(input));
      String line = null;
      int t;
      t = Integer.parseInt(reader.readLine());
      for (int i = 0; i < t; i++) {
        rna.clear();
        vaccine.clear();
        inVaccine.put('A', 0);
        inVaccine.put('U', 0);
        inVaccine.put('G', 0);
        inVaccine.put('C', 0);
        line = reader.readLine();
        temp = line.toCharArray();
        for (int j = 0; j < line.length(); j++) {
          rna.add(temp[j]);
        }
        //vaccine.add(rna.remove(rna.size() - 1));
        //inVaccine.put(vaccine.get(0), 1);

        StackState first = new StackState(rna, vaccine, 'p', inVaccine, null);
        result = bfsSolver(first);
        String path;
        path = findPath(result);
        System.out.println(path);

      }


    } catch (Exception e) { // Bad practice !
      System.out.println(" Something went wrong : " + e);
    }


  }

  public static  StackState bfsSolver(StackState first) {
    Vector<Character> vaccine = new Vector<Character>();
    Queue<StackState> remaining = new ArrayDeque<>();
    Set<StackState> seen = new HashSet<>();
    StackState res = first;


    remaining.add(first);
    seen.add(first);
    while (!remaining.isEmpty()) {
       StackState s = remaining.remove();
       char m = s.getMove();
       Vector<Character> r = s.getRna();
       Vector<Character> v = s.getVaccine();
       Hashtable<Character, Integer> in = s.getInVaccine();

       //System.out.println(r);
       //System.out.println(v);
       //System.out.println(m);

       //System.out.println(in);


       if (m == 'p') {
         r = (Vector<Character>) r.clone();
         v = (Vector<Character>) v.clone();
         in = (Hashtable<Character, Integer>) in.clone();
         v.add(r.remove(r.size() - 1));
         in.put(v.get(v.size() - 1), 1);
         for (StackState n : s.next(r, v, in)) {
           if (!seen.contains(n)) {
             remaining.add(n);
             seen.add(n);
           }
         }

       }
       else if (m == 'r') {
         Collections.reverse(v);
         v = (Vector<Character>) v.clone();
         in = (Hashtable<Character, Integer>) in.clone();
         r = (Vector<Character>) r.clone();

         for (StackState n : s.next(r, v, in)) {
           if (!seen.contains(n)) {
             remaining.add(n);
             seen.add(n);
           }

         }

       }
       else if (m == 'c') {
         r = (Vector<Character>) r.clone();
         in = (Hashtable<Character, Integer>) in.clone();
         v = (Vector<Character>) v.clone();

         for (int i = 0; i < r.size(); i++)
             r.set(i,compl(r.get(i)));

         for (StackState n : s.next(r, v, in)) {
           if (!seen.contains(n)) {
             remaining.add(n);
             seen.add(n);
           }
         }

       }
       if (r.size() == 0) {
         Collections.reverse(v);
         res = s;
         break;
       }



    }
    return res;

  }
  private static String findPath(StackState s) {
    StackState previous = s.getPrevious();
    StackState current = s;
    ArrayList<Character> path = new ArrayList<Character>();
    path.add(current.getMove());
    while (previous != null) {
      path.add(previous.getMove());
      current = previous;
      previous = current.getPrevious();
    }
    StringBuilder builder = new StringBuilder();
    for(int i = path.size() - 1; i >= 0; i--){
      builder.append(path.get(i));
    }
    return builder.toString();

  }
}
