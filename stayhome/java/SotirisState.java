import java.util.*;

public class SotirisState {
  // false = west, true = east
  private int xplace, yplace;
  private int time;
  private SotirisState previous;

  public SotirisState(int x, int y, int t, SotirisState p) {
    xplace = x;
    yplace = y;
    time = t;
    previous = p;
  }

  public boolean isFinal(int fx, int fy) {
    return xplace == fx  && yplace == fy;
  }

  public boolean isBad(char [][] grid, int N, int M, int [][] coronaTime) {
    return xplace < 0 || xplace >= N
        || yplace < 0 || yplace >= M
        || grid[xplace][yplace] == 'X'
        || (coronaTime[xplace][yplace] != -1 && time >= coronaTime[xplace][yplace]);

  }





  public Collection<SotirisState> next() {
    Collection<SotirisState> states = new ArrayList<>();
    //down
    states.add(new SotirisState(xplace + 1, yplace, time + 1, this));
    //left
    states.add(new SotirisState(xplace, yplace - 1, time + 1, this));
    //right
    states.add(new SotirisState(xplace, yplace + 1, time + 1, this));
    // up
    states.add(new SotirisState(xplace - 1, yplace, time + 1, this));

    return states;
  }

  public SotirisState getPrevious() {
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
    SotirisState other = (SotirisState) o;
    return xplace == other.xplace && yplace == other.yplace;

  }
  public int hashCode() {
    return Objects.hash(xplace, yplace);
  }

}
