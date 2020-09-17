#include <iostream>
#include <cstring>
#include <fstream>
#include <math.h>
using namespace std;
void pangiann (unsigned long long  n, unsigned long long k) 
{
	int powers = log2(n);
	long  dp[powers+1];
	memset(dp, 0, sizeof(dp));
	dp[0] = k;
	unsigned long long sum = k;
	int j;
	while (sum < n && dp[0] != 0) {
		for (j = 1; j <= powers; j++) {
			if (sum + pow(2, j) - 1 <= n) {
				dp[j-1]--;
				dp[j]++;
			}
			else {
				break;
			}

		}
		sum += (pow(2, j-1) - 1);
	}
	while (dp[powers] == 0) powers--;
	if (sum != n) 
		puts("[]");
	else {
		putchar('[');
		for (int j = 0; j < powers; j++) 
				printf("%ld,", dp[j]);
		printf("%ld]\n", dp[powers]);
	}
}
int main (int argc, char *argv[])
{
	unsigned long long  n, k;

	FILE *inputFile;
	inputFile = fopen(argv[1], "rt");
	int t;
	if(fscanf(inputFile, "%d", &t) != 1 )
			perror("problem reading file\n");
	for (int i = 0; i < t; i++) {
		if (fscanf(inputFile, "%llu %llu", &n, &k) != 2)
			perror("problem reading file\n");
		pangiann(n, k);
	}
	
	return 0;
}

