//#include <shrUtils.h>
//#include <shrQATest.h>
#include <sdkHelper.h>
#include "cutil_inline.h"
#include <cuda_runtime.h>
#include<stdio.h>
#include<cstdlib>
#include<dos.h>
#include<conio.h>
#include<iostream>
#define MIN 0
#define MAX 1024
#define BLOCK_SIZE 16
using namespace std;
int val=512;
FILE *fp=fopen("data.txt","w");
typedef struct 
{ 
	int width; 
	int height; 
	float* elements; 
} Matrix;
__global__ void MatMulKernel(const Matrix A, const Matrix B, Matrix C) 
{ 

	// Each thread computes one element of C // by accumulating results into Cvalue 
	float Cvalue = 0; 
	int row = blockIdx.y * blockDim.y + threadIdx.y; 
	int col = blockIdx.x * blockDim.x + threadIdx.x; 
	for (int e = 0; e < A.width; ++e) 
	Cvalue += A.elements[row * A.width + e] * B.elements[e * B.width + col]; 
	C.elements[row * C.width + col] = Cvalue; 
}
void MatMul(const Matrix A, const Matrix B, Matrix C) 
{ 
	// Load A and B to device memory 
	Matrix d_A; 
	d_A.width = A.width; 
	d_A.height = A.height; 
	size_t size = A.width * A.height * sizeof(float); 
	cudaMalloc(&d_A.elements, size); 
	cudaMemcpy(d_A.elements, A.elements, size, cudaMemcpyHostToDevice); 
	Matrix d_B; 
	d_B.width = B.width; 
	d_B.height = B.height; 
	size = B.width * B.height * sizeof(float); 
	cudaMalloc(&d_B.elements, size); 
	cudaMemcpy(d_B.elements, B.elements, size, cudaMemcpyHostToDevice);
	// Allocate C in device memory 
	Matrix d_C; 
	d_C.width = C.width; 
	d_C.height = C.height; 
	size = C.width * C.height * sizeof(float); 
	cudaMalloc(&d_C.elements, size); 
	// Invoke kernel 
	dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE); 
	dim3 dimGrid(B.width / dimBlock.x, A.height / dimBlock.y); 
	StopWatchInterface * timer_mul=NULL;
	sdkCreateTimer(&timer_mul);
	sdkStartTimer(&timer_mul);
	MatMulKernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C); 
	// Read C from device memory 
	sdkStopTimer(&timer_mul);
	cudaMemcpy(C.elements, d_C.elements, size, cudaMemcpyDeviceToHost); 
	
	float dSeconds = sdkGetTimerValue(&timer_mul);
	//cout<<"Matrix size : "<<val<<"x"<<val<<endl;
	//cout<<"Multiplication Time = "<<dSeconds<<"ms"<<endl;
	printf("%d\t%f\n",val,dSeconds);
	fprintf(fp,"%d\t%f\n",val,dSeconds);
	//getch();
	sdkDeleteTimer(&timer_mul);
	// Free device memory 
	cudaFree(d_A.elements); 
	cudaFree(d_B.elements); 
	cudaFree(d_C.elements); 
}
int main()
{
	Matrix l_a,l_b,l_c;
	int i,j,k=1;
	while(val<=12300)
	{
		l_a.width=l_a.height=l_b.width=l_b.height=l_c.width=l_c.height=val;
		l_a.elements=(float*)malloc(l_a.width*l_a.height*sizeof(float));
		l_b.elements=(float*)malloc(l_b.width*l_b.height*sizeof(float));
		l_c.elements=(float*)malloc(l_c.width*l_c.height*sizeof(float));
		for(i=MIN;i<val;i++)
		{
                     for(j=MIN;j<val;j++)
                     {
                                      l_a.elements[i*val+j]=(rand() / (float)RAND_MAX);
                                      l_b.elements[i*val+j]=(rand() / (float)RAND_MAX);
                     }
		}
		MatMul(l_a,l_b,l_c);
		free(l_a.elements);
		free(l_b.elements);
		free(l_c.elements);
		val=val+512;
		//else
			//val=val*2;
		//k++;
	}
	fclose(fp);
	getch();
    return 0;
}
