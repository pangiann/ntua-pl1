import java.util.*;
import java . io .*;

public class Stayhome {

  public static void main (String[] args) {
    int N, M;
    char[][] grid = new char[1000][1000];
    ArrayList<AirState> airInfection = new ArrayList<AirState>();
    CoronaState cor_initial = new CoronaState(0, 0, 0, null);
    SotirisState sot_initial = new SotirisState(0, 0, 0, null);

    //boolean air_inf = false;
    int fx = 0;
    int fy = 0;
    int nl = 0;

    try {
      File input = new File(args[0]);
      BufferedReader reader = new BufferedReader (new FileReader(input));
      String line = null;
      while ((line = reader.readLine()) != null) {
        grid[nl] = line.toCharArray();
        nl++;
      }


    } catch (Exception e) { // Bad practice !
      System.out.println(" Something went wrong : " + e);
    }
    N = nl;
    M = grid[0].length;
    // find starting positions for sotiris, corona and the others
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < M; j++) {
        if (grid[i][j] == 'W') {
          cor_initial = new CoronaState(i, j, 0, null);
        }
        if (grid[i][j] == 'A') {
          airInfection.add(new AirState(i, j, -1));

        }
        if (grid[i][j] == 'S') {
          sot_initial = new SotirisState(i, j, 0, null);

        }
        if (grid[i][j] == 'T') {
          fx = i;
          fy = j;
        }
      }
    }
    // find corona virus spread array
    int [][]covid = coronaBfs(grid, N, M, cor_initial, airInfection);

    // find sotiris final position
    SotirisState kapa = sotirisVsCorona(sot_initial, grid, covid, N, M, fx, fy);
    String path;
    if (kapa == null) {
      System.out.print("IMPOSSIBLE\n");
    }
    else {
      path = findPath(kapa);
      System.out.println(path.length());
      System.out.println(path);
    }



  }
  public static int[][] coronaBfs(char [][]grid, int N, int M, CoronaState virus, ArrayList<AirState> initialStates) {
    int[][] time = new int[N][M];
    Queue<CoronaState> remaining = new ArrayDeque<>();
    Set<CoronaState> seen = new HashSet<>();
    AirState gen_air = new AirState(-1, -1, -1);
    int air_time, cor_time;
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < M; j++) {
        time[i][j] = -1;
      }
    }
    // if airports exist get first one to have access to static vars of airstate class
    if (initialStates.size() != 0)
       gen_air = initialStates.get(0);

    // push to queue
    remaining.add(virus);
    seen.add(virus);
    time[virus.getX()][virus.getY()] = 0;
    while (true) {
      // nowhere to go and  virus has arrived to airport but other airports not infected yet
      if (remaining.isEmpty() && gen_air.getTime() != 0 && gen_air.getInf() != true) {
        // infect all airports
        gen_air.infected();
        for (AirState a : initialStates) {
          int x = a.getX();
          int y = a.getY();
          if (time[x][y] == -1 && (x != virus.getX() || y != virus.getY())) {
            time[x][y] = gen_air.getTime() + 5;
            CoronaState c = new CoronaState(x, y, gen_air.getTime() + 5, virus);
            remaining.add(c);
            seen.add(c);

          }
        }
        continue;
      }
      // nowhere to go, no airports to push -> bye bye...
      else if (remaining.isEmpty()) {
        break;
      }
      virus = remaining.remove();

      air_time = gen_air.getTime();

      cor_time = time[virus.getX()][virus.getY()];

      // virus' first time in airport
      // enable air_time
      if (air_time == 0 && grid[virus.getX()][virus.getY()] == 'A') {
        gen_air.initTime(cor_time);
      }
      // necessary air_time passed, virus now infects all airports
      if (air_time != 0 && cor_time - air_time == 4) {
        gen_air.infected();
        for (AirState a : initialStates) {


          int x = a.getX();
          int y = a.getY();
          if (time[x][y] == -1 && (x != virus.getX() || y != virus.getY())) {
            time[x][y] = air_time + 5;
            CoronaState c = new CoronaState(x, y,  air_time + 5, virus);
            remaining.add(c);
            seen.add(c);
          }
        }
      }
      // find neighbors and infect them
      for (CoronaState n : virus.next()) {
        if (!seen.contains(n) && !n.isBad(grid, N, M)) {
          remaining.add(n);
          seen.add(n);
          time[n.getX()][n.getY()] = time[virus.getX()][virus.getY()] + 2;
        }
      }


    }
    return time;

  }



  private static SotirisState sotirisVsCorona(SotirisState initial, char [][]grid, int[][] covid, int N, int M, int fx, int fy) {

    Queue<SotirisState> remaining = new ArrayDeque<>();
    Set<SotirisState> seen = new HashSet<>();
    remaining.add(initial);
    seen.add(initial);
    while (!remaining.isEmpty()) {
      SotirisState s = remaining.remove();
      int x = s.getX();
      int y = s.getY();
      if (s.isFinal(fx, fy)) return s;

      for (SotirisState n : s.next()) {
        // check if sotiris is not as fast as corona or this grid is a 'X' and other bad situations
        if (!seen.contains(n) && !n.isBad(grid, N, M, covid)) {
          remaining.add(n);
          seen.add(n);
        }
      }

    }
    return null;

  }

  private static String findPath(SotirisState s){
     // go to all previous sotiris states from final pos to start pos
     SotirisState previous = s.getPrevious();
     SotirisState current = s;
     ArrayList<Character> path = new ArrayList<Character>();

     while(previous != null){
       path.add(findMove(previous, current));
       current = previous;
       previous = current.getPrevious();
     }

     StringBuilder builder = new StringBuilder();
     for(int i = path.size() - 1; i >= 0; i--){
       builder.append(path.get(i));
     }
     return builder.toString();
   }

   private static char findMove(SotirisState a, SotirisState b){
     // be careful we want the best lexicographically move
     int x1 = a.getX(), y1 = a.getY();
     int x2 = b.getX(), y2 = b.getY();
     if(y1 == y2){
       if (x2 == x1 + 1){
         return 'D';
       }
       return 'U';
     }
     else {
       if(y2 == y1 + 1){
         return 'R';
       }
       return 'L';
     }
   }


}
