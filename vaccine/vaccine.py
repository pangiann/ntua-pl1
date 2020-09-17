from collections import deque
import sys
import os
import psutil

compl = lambda x : "U" if x == "A" else ("A" if x == "U" else ("G" if x == "C" else "C"))



def find_moves(rna, vaccine, in_vaccine, father, curr_move):
    nextMove = []
    # we are already in this position earlier, no reason to go again
    key = ''.join(rna) + "," + ''.join(vaccine)
    if key in father:
        #print("hellooooo")
        return nextMove

    if len(rna) == 0: return nextMove;


    if rna[-1] == vaccine[0]:
        nextMove.append([rna.copy(), vaccine.copy(), "p", in_vaccine.copy()])
        return nextMove

    compl_rna = compl(rna[-1])
    #complement
    if compl_rna == vaccine[0] or compl_rna == vaccine[-1] or in_vaccine[compl_rna] == 0 and curr_move != "c":
        nextMove.append([rna.copy(), vaccine.copy(), "c", in_vaccine.copy()])

    #push
    if in_vaccine[rna[-1]] == 0 or rna[-1] == vaccine[0]:
        nextMove.append([rna.copy(), vaccine.copy(), "p", in_vaccine.copy()])


    #reverse
    if len(vaccine) != 1 and (rna[-1] == vaccine[-1] or in_vaccine[rna[-1]] == 0) and curr_move != "r":
        nextMove.append([rna.copy(), vaccine.copy(), "r", in_vaccine.copy()])


    return nextMove

def bfsSolve(N, rna):
    in_vaccine = {"A" : 0, "U" : 0, "C" : 0, "G" : 0}
    father = {}
    vaccine = []
    first_key = ''.join(rna) + "," + ''.join(vaccine)
    father[first_key] = ["s", []]
    # first move is always a push
    queue = deque([[rna, vaccine, "p", in_vaccine]])

    nextMove = []
    final = []
    while len(queue) != 0:
        #print("father = ", end=" ")
        #print(father)
        #print("queue = ", end=" ")
        #print(queue)
        top = queue.popleft()

        #print("top = ", end=" ")
        #print(top)

        old = ''.join(top[0]) + "," + ''.join(top[1])

        if top[2] == "p":
            top[1].insert(0,top[0].pop())
            top[3][top[1][0]] = 1

            nextMove = find_moves(top[0], top[1], top[3], father, top[2])

        elif top[2] == "r":
            top[1].reverse()
            nextMove = find_moves(top[0], top[1], top[3], father, top[2])

        elif top[2] == "c":
            for i in range(len(top[0])):
                top[0][i] = compl(top[0][i])
            nextMove = find_moves(top[0], top[1], top[3], father, top[2])

        if nextMove != [] or len(top[0]) == 0:
            key = ''.join(top[0]) + "," + ''.join(top[1])
            father[key] = [top[2], old]

        if len(top[0]) == 0:
            final = top[1]
            break

        for n in nextMove:
            #print("next move = ", end=" ")
            #print(n)
            queue.append(n);

    return (father, final)

def find_path(father, final):
    result = ""
    [move, prev] = father[final]

    while True:
        if move == "s":
            return result
        #print(result)
        result = result + move
        newX = prev
        [move, prev] = father[newX]



if __name__ == "__main__":
    with open(sys.argv[1], "rt") as inputFile:
        N = int(inputFile.readline())
        for i in range(N):
            #print(process.memory_info())

            father = {}
            rna = inputFile.readline()[:-1]
            qrna = deque(rna)
            (father, final) = bfsSolve(N, qrna)
            #print(father)
            #print(final)
            path = find_path(father, "," + ''.join(final))
            print(path[::-1])
