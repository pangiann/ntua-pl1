import java.util.*;

public class AirState {
  private int xplace, yplace;
  private static int time = 0;
  private static boolean infected = false;

  public AirState(int x, int y, int t) {
    xplace = x;
    yplace = y;
  }

  public int getX() {
    return xplace;
  }
  public int getY() {
    return yplace;
  }

  public void infected() {
    infected = true;
  }
  public int getTime() {
    return time;
  }
  public boolean getInf() {
    return infected;
  }
  public void initTime(int t) {
    time = t;
  }


}
