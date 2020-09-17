# Programming Languages I

In this course we explore and compare the different types of programming:

* Functional (Standard ML)
* Logical (Prolog)
* Imperative (C++, Python, Java)
* Object Oriented (Java)
* Scripting (Python)

As a lab assignment we are given 4 algorithmic problems to be solved with various languages, so we can compare the different programming styles.

## Problems

### Powers2

[Definition in Greek](exerc20-1.pdf)

We are given two numbers N and K. We must find the lexicographically smallest way to write 
number N in sum of K numbers which are power of 2.

This problem is solved in [Standard ML](powers/powers2.sml),  [C++](powers/powers2.cpp) and [Prolog](powers/powers2.pl)

### Coronagraph 

[Definition in Greek](exerc20-1.pdf)

We are given an undirected graph. Our task is to find wehter or not this graph represents the structure 
of coronavirus and then print the attributes of the virus. We are aware of the virus' valid structure from the exercise's definition.
Some of the requirements for a graph to depict a coronavirus are:
 * To be a connected graph
 * To have exactly one cycle

We could solve this problem in few steps:
After creating the given graph, we check if the number of edges equals to the number of vertices. Because 
graph must be connected and have exactly one graph. Then, we know that we have only one cycle and we find it. 
Last, we find the number of vertices of trees with roots included in cycle. 

This problem is solved in [Standard ML](coronagraph/coronagraph.sml),  [C++](coronagraph/coronagraph2.cpp) and [Prolog](coronagraph/coronagraph.pl)


### Stayhome

[Definition in Greek](exerc20-2.pdf)


We are given a 2D map with some airports (A), some obstacles (X), Sotiris' start position (probably Tsiodras) (S), Sotiris' home (F) and CoronaVirus (W). As time passes by, virus infects neighboring cells! We must navigate Sotiris to his home safe. If there are more than one solutions, path must be the lexicographically smallest.

We first calculate how much time it takes for virus to infect each cell. To achieve this, we run a BFS algorithm with our initial queue containing CoronaVirus starting position. We then run a BFS algorithm from Sotiris's position and search for a cell that is not infected yet. 

This problem is solved in [Standard ML](stayhome/Stayhome2.sml),  [Python](stayhome/Stayhome.py) and [Java](stayhome/java)

### Vaccine 

[Definition in Greek](exerc20-3.pdf)

Obviously, the last part of the puzzle is to find the vaccine of coronavirus and save the world.
To do that, we are given a stack with virus' RNA, one empty stack which represents the vaccine and 3 available moves. 
 * push (p): push the last element of first stack to the top of second stack
 * complement (c): replace every element of RNA with its complement
 * reverse (r): reverse second stack

Ofcourse, there are some prerequisites in order to create a valid vaccine. Each one of the above moves gives us a potential vaccine. To be valid, the left stack has to be empty, and the right one to have all bases(A, G, U, T) together.

This problem is solved in [Python](vaccine/vaccine.py) and [Java](vaccine/java).


