import java.util.*;

public class StackState {
  private Vector<Character> vaccine, rna;
  private char move;
  private Hashtable<Character, Integer> inVaccine;
  private StackState previous;

  public StackState(Vector<Character> r, Vector<Character> v, char m, Hashtable<Character, Integer> in, StackState p) {
    vaccine = v;
    rna = r;
    move = m;
    inVaccine = in;
    previous = p;
  }
  public char compl(char x) {
    if (x == 'A') return 'U';
    if (x == 'U') return 'A';
    if (x == 'C') return 'G';
    if (x == 'G') return 'C';
    return x;

  }

  public boolean isFinal(Vector<Character> r) {
      return r.isEmpty();
  }

  public Collection<StackState> next(Vector<Character> r, Vector<Character> v, Hashtable<Character, Integer> in) {
    boolean more = false;
    Collection<StackState> states = new ArrayList<>();
    if (r.isEmpty()) {
      return states;
    }

    if (r.get(r.size() - 1) == v.get(v.size() - 1)) {
      states.add(new StackState(r, v, 'p', in, this));

      return states;
    }
    char compl_rna = compl(r.get(r.size() - 1));

    if (compl_rna == v.get(v.size() - 1) || compl_rna == v.get(0) || in.get(compl_rna) == 0 && move != 'c') {

        states.add(new StackState(r, v, 'c', in, this));
    }

    if (in.get(r.get(r.size() - 1)) == 0 || r.get(r.size() -1) == v.get(v.size() - 1)) {

        states.add(new StackState( r, v, 'p', in, this));
    }

    if (v.size() != 1 && (r.get(r.size() -1) == v.get(0) || in.get(r.get(r.size() - 1)) == 0) && move != 'r' ) {

        states.add(new StackState( r, v, 'r', in, this));
    }
    return states;


  }

  public StackState getPrevious() {
    return previous;
  }

  public Vector<Character> getRna() {
    return rna;
  }


  public Vector<Character> getVaccine() {
    return vaccine;
  }

  public char getMove() {
    return move;
  }

  public Hashtable<Character, Integer> getInVaccine() {
    return inVaccine;
  }
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    StackState other = (StackState) o;
    return vaccine.equals(other.vaccine) && rna.equals(other.rna) && move == other.move && inVaccine.equals(other.inVaccine);

  }
  public int hashCode() {
    return Objects.hash(rna, vaccine, move, inVaccine);
  }


}
