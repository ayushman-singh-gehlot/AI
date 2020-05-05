#include<stdio.h>
int square(int n)
{
	n=n*n;
	return n;
}

int main()
{

	int num1;
	float num2;
	num1=4;
	num2=4.0;
	square(num1);
	square(num2);
	// actual parameter is float
	// and formal parameter is integer 
}