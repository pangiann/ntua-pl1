#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <cstring>
#include <stack>

using namespace std;


class Graph
{
	protected:
		int V;
		vector<int> *adj;

	public:
		Graph(int V) 
		{
			this->V = V;
			adj = new vector<int>[V];
		}

		~Graph() {} 

		void addEdge(int u, int v)
		{
			adj[u-1].push_back(v-1);
			adj[v-1].push_back(u-1);
		}
		// The function 'dfs' is based on the one available here
		// https://www.geeksforgeeks.org/iterative-depth-first-traversal/
		void dfs(int s, vector<bool> &visited, int &count) 
		{ 
		  
			stack<int> stack; 
		  
			stack.push(s); 
		  
			while (!stack.empty()) 
			{ 
				s = stack.top(); 
				stack.pop(); 
		  
				if (!visited[s]) 
				{ 
					count++;
					visited[s] = true; 
				} 
		  
				for (auto i = adj[s].begin(); i != adj[s].end(); ++i) 
					if (!visited[*i]) 
						stack.push(*i); 
			} 
		} 
		bool is_connected(int V)
		{
			vector<bool> visited(V, false);
			int temp = 0;
			dfs(0, visited, temp);
			return temp == V? true : false;
		}

		void corona(vector<int> path) 
		{
			
			vector<int> color(V, 0);
			vector<bool> cycle(V, false);
			vector<bool> visited(V, false);
			cycle_aux(0, -1, color, cycle,  path);
			
			for (int i = 0; i < V; i++)
				visited[i] = cycle[i];

			int j = 0;
			vector<int> count;
			for (int i = 0; i < V; i++) {
				if (cycle[i]) {
					count.push_back(1);
					dfs(i, visited, count[j]);
					j++;
				}
			}

			cout << "CORONA " << count.size() << endl;

			// used sort from STL library of c++ 
			sort(count.begin(), count.end());
			for (unsigned int i = 0; i < count.size(); i++) {
				printf("%d", count[i]); 
				i == count.size()-1? putchar('\n') : putchar(' ');
			}
		}

		// okay I'll say fuck you stack overflow.. I had to throw away recursion @@@!@!!@ and now
		// this code sucks..and probably in one day or in one hour I'll forget how this code really works.
		void cycle_aux(int v, int par,  vector<int> &color, vector<bool> &cycle,  vector <int> &cycle_path)
		{

			// keep stack with vertex and their parent
			stack<pair<int, int> > stack;
			stack.push(make_pair(v,-1));

			while (!stack.empty()) 
			{
				v = stack.top().first;
				if (color[v] == 2) 
					continue;
				else if (color[v] == 1) {
					// okay second time a vertex is visited
					// two possibilities
					if (par == v) {
						//one: vertex completely visited 
						// throw it away from path and stack
						par = stack.top().second;
						cycle_path.pop_back();
						stack.pop();
						color[v] = 2;
						continue;
					}
					// two: we found a cycle 
					int count = 0;
					vector<int>::const_iterator i;
					for (i = cycle_path.begin(); i != cycle_path.end(); ++i) {
						if (*i != v) 
							count++;
						else break;
					}
					if (count != 0)
						cycle_path.erase(cycle_path.begin(), cycle_path.begin() + count);
					for (unsigned int i = 0; i < cycle_path.size(); ++i) 
						cycle[cycle_path[i]] = true;
					break;
				}

				vector<int>::const_iterator k;
				int counter = 1;
				cycle_path.push_back(v);
				color[v] = 1;
				int temp = stack.top().second;
				for (k = adj[v].begin(); k != adj[v].end(); ++k) {
					if (*k == temp) 
						continue;
					stack.push(make_pair(*k, v));
					counter++;
				}
				if (counter == 1) {
					// this is a leaf and ofcourse is not part of the cycle and completely visited
					// so we throw it away from cycle_path and stack
					par = stack.top().second;
					stack.pop();
					cycle_path.pop_back();
					color[v] = 2;
				}

			}
		}

};

int main (int argc, char *argv[]) 
{
	

	int V, E;
	FILE *inputFile;
	inputFile = fopen(argv[1], "rt");
	int t;
	if (fscanf(inputFile, "%d", &t) != 1) 
		perror("problem reading file\n");
	for (int i = 0; i < t; i++) {
		if (fscanf(inputFile, "%d %d", &V, &E) != 2)
			perror("problem reading file\n");
		if (V == E) {
			Graph g(V);
			for (int i = 0; i < E; i++) {
				int u, v;
				if (fscanf(inputFile, "%d %d", &u, &v) != 2)
					perror("problem reading file\n");
				g.addEdge(u, v);
			}
			if (g.is_connected(V)) {
				vector<int> path;
				g.corona(path);
			}
			else {
				puts("NO CORONA");
				continue;
			}
		}
		else {
			for (int i = 0; i < E; i++) {
				int u, v;
				if (fscanf(inputFile, "%d %d", &u, &v) != 2)
					perror("problem reading file\n");
			}
			puts("NO CORONA");
		}
	}
	return 0;
}
