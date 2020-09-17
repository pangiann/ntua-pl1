import java.util.*;

public class CoronaState {
  // false = west, true = east
  private int xplace, yplace;
  private int time;
  private CoronaState previous;

  public CoronaState(int x, int y, int t, CoronaState p) {
    xplace = x;
    yplace = y;
    time = t;
    previous = p;
  }

  public boolean isFinal() {
    return false;
  }

  public boolean isBad(char [][] grid, int N, int M) {
    return xplace < 0 || xplace >= N
        || yplace < 0 || yplace >= M
        || grid[xplace][yplace] == 'X';

  }





  public Collection<CoronaState> next() {
    Collection<CoronaState> states = new ArrayList<>();
    //down
    states.add(new CoronaState(xplace + 1, yplace, time + 2, this));
    //left
    states.add(new CoronaState(xplace, yplace - 1, time + 2, this));
    //right
    states.add(new CoronaState(xplace, yplace + 1, time + 2, this));
    // up
    states.add(new CoronaState(xplace - 1, yplace, time + 2, this));

    return states;
  }

  public CoronaState getPrevious() {
    return previous;
  }

  public int getX() {
    return xplace;
  }
  public int getY() {
    return yplace;
  }

  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    CoronaState other = (CoronaState) o;
    return xplace == other.xplace && yplace == other.yplace;

  }
  public int hashCode() {
    return Objects.hash(xplace, yplace);
  }

}
