from collections import deque
import sys



def print_list(list):
    for i in range(len(list)):
        print(list[i], end=" ")
    print("")



def watch_neighbors(pos, grid, N, M):

    neighbors = []
    i = pos[0]
    j = pos[1]
    # down
    if i+1 < N and grid[i+1][j] != "X":
        neighbors.append([i+1, j])

    # left
    if j-1 >= 0 and grid[i][j-1] != "X":
        neighbors.append([i, j-1])
    # right
    if j+1 < M and grid[i][j+1] != "X":
        neighbors.append([i, j+1])

    # up
    if i-1 >= 0 and grid[i-1][j] != "X":
        neighbors.append([i-1, j])

    return neighbors

def coronaBfs(corona, N, M, start_pos, airports, map):
    corQueue = deque(start_pos)
    top = start_pos[0]
    air_time = 0
    cor_time = 0
    air_inf = False
    while (True):
        # nowhere to go and  virus has arrived to airport but other airports not infected yet
        if (len(corQueue) == 0 and air_time != 0 and air_inf != True):
            # infect all airports
            air_inf = True
            for i in airports:
                if (i[0] != top[0] or i[1] != top[1]) and corona[i[0]][i[1]] == -1:
                    corona[i[0]][i[1]] = air_time + 5
                    corQueue.append(i)
            continue
        # nowhere to go, no airports to push -> bye bye...
        elif len(corQueue) == 0:
            break


        top = corQueue.popleft()
        cor_time = corona[top[0]][top[1]]

        # virus' first time in airport
        # enable air_time
        if air_time == 0 and map[top[0]][top[1]] == "A":
            air_time = cor_time

        # necessary air_time passed, virus now infects all airports
        if air_time != 0 and cor_time - air_time == 4:
            air_inf = True
            for i in airports:
                if (i[0] != top[0] or i[1] != top[1]) and corona[i[0]][i[1]] == -1:
                    corona[i[0]][i[1]] = air_time + 5
                    corQueue.append(i)

        # find neighbors and infect them
        neighbors = watch_neighbors(top, corona, N, M)
        #print_list(neighbors)
        for pos in neighbors:
            if corona[pos[0]][pos[1]] == -1:
                corona[pos[0]][pos[1]] = cor_time + 2
                corQueue.append(pos)


    return corona


def sotirisVsCorona(sotiris, corona, N, M, start_pos, end_pos, map):

    sotQueue = deque(start_pos)

    sot_time = 0
    while len(sotQueue) != 0:

        top = sotQueue.popleft()
        sot_time = sotiris[top[0]][top[1]]
        cor_time = corona[top[0]][top[1]]

        # sotiris is not as fast as corona :(
        if cor_time != -1 and cor_time <= sot_time:
            parent[top[0]][top[1]] = [-1, -1]
            continue

        # sotiri, go to neighborhood to meet new people :)
        neighbors = watch_neighbors(top, sotiris, N, M)

        for n in neighbors:
            if sotiris[n[0]][n[1]] == -1:
                sotiris[n[0]][n[1]] = sot_time + 1
                parent[n[0]][n[1]] = top
                sotQueue.append(n)


    return sotiris




def find_next (x1, y1, x2, y2):
    if y1 == y2:
        if x2 == x1 - 1:
            return "U"
        return "D"
    else:
        if y2 == y1 - 1:
            return "L"
        return "R"




def print2Dmap(grid):
    for i in range(N):
        for j in range(M):
            print(grid[i][j], end=" ")
        print("")



def find_path(parent, end_pos):

    path = []
    curr_pos = end_pos
    while(True):
        prev_in_path = parent[curr_pos[0]][curr_pos[1]]
        if prev_in_path == [-1, -1]:
            break

        path.append(find_next(prev_in_path[0], prev_in_path[1], curr_pos[0], curr_pos[1]))
        curr_pos = prev_in_path

    path.reverse()
    return ''.join(path)

if __name__ == "__main__":
    with open(sys.argv[1], "rt") as inputFile:
        map = inputFile.read().split('\n')[:-1]
    N = len(map)
    M = len(map[0])
    airports = []
    cor_start_pos = []
    sot_start_pos = []

    corona  = [[-1 for j in range(M)] for i in range(N)]
    sotiris = [[-1 for j in range(M)] for i in range(N)]
    parent = [[[-1,-1] for j in range(M)] for i in range(N)]

    #print2Dmap(map)


    #find all necessary info
    for i in range(N):
        for j in range(M):
            if map[i][j] == "S":
                sot_start_pos.append((i,j))
                sotiris[i][j] = 0
            elif map[i][j] == "T":
                sot_end_pos = [i, j]
            elif map[i][j] == "A":
                airports.append((i,j))
            elif map[i][j] == "W":
                cor_start_pos.append((i,j))
                corona[i][j] = 0
            elif map[i][j] == "X":
                corona[i][j] = "X"
                sotiris[i][j] = "X"
    #print(cor_start_pos[0])
    #print_list(airports)
    corona = coronaBfs(corona, N, M, cor_start_pos, airports, map)
    print2Dmap(corona)
    sotiris = sotirisVsCorona(sotiris, corona, N, M, sot_start_pos, sot_end_pos, map)
    #print2Dmap(sotiris)



    path = find_path(parent, sot_end_pos)
    if (len(path) == 0):
        print("IMPOSSIBLE")
    else:
        print(len(path))
        print(path)
