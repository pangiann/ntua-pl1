#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <cstring>
#include <stack>

using namespace std;


class Graph
{
	private:
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

		bool connected(int V)
		{
			vector<bool> visited(V, false);
			int temp = 0;
			dfs(0, visited, temp);
			for (int i=0; i<V; i++){
				if (!visited[i]){
					return false;
				}
			}
			return true;
		}

		void corona(vector<int> path) 
		{

			vector<int> color(V, 0);
			vector<bool> cycle(V, false);
			vector<bool> visited(V, false);
			cycle_aux(0, 0, color, cycle,  path);
			for (int i = 0; i < V; i++)
				visited[i] = cycle[i];

			int j = 0;
			vector<int> count;
			for (int i = 0; i < V; i++) {
				if (cycle[i]) {
					count.push_back(1);
					dfs(i, visited, count[j]);
					//cout << "count[" << j << "] = " << count[j] << endl;
					j++;
				}
			}

			cout << "CORONA " << count.size() << endl;

			//used sort from STL library of c++ 
			sort(count.begin(), count.end());
			for (unsigned int i = 0; i < count.size(); i++) {
				printf("%d", count[i]); 
				i == count.size()-1? putchar('\n') : putchar(' ');
			}
		}
		bool find = false;

		void cycle_aux(int v, int par,  vector<int> &color, vector<bool> &cycle,  vector <int> &cycle_path)
		{

			if (color[v] == 2 || find) 
				return;
			else if (color[v] == 1) {
				int count = 0;
				vector<int>::const_iterator i;
				for (i = cycle_path.begin(); i != cycle_path.end(); ++i) {
					if (*i != v) 
						count++;
					else break;
				}
				cycle_path.erase(cycle_path.begin(), cycle_path.begin() + count);
				//cout << "CYCLE: ";
				//for (unsigned int i = 0; i < cycle_path.size(); ++i) 
				//		cout << cycle_path[i] << (i == cycle_path.size()-1? "\n" : " ");
				//	
				for (unsigned int i = 0; i < cycle_path.size(); ++i) 
					cycle[cycle_path[i]] = true;
				find = true;
				return;
			}
			//	for (unsigned int i = 0; i < cycle_path.size(); ++i) 
			//		cout << cycle_path[i] << (i == cycle_path.size()-1? "\n" : " ");
			//	

			color[v] = 1;
			cycle_path.push_back(v);
			vector<int>::const_iterator k;
			for (k = adj[v].begin(); k != adj[v].end(); ++k) {
				if (*k == par) 
					continue;
				cycle_aux(*k, v, color, cycle, cycle_path);
			}
			color[v] = 2;
			cycle_path.pop_back();

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
			if (g.connected(V)) {
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
