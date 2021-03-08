#ifndef __MATRIX_H
#define __MATRIX_H


/*
############################################################
						INCLUDES
############################################################
*/
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include "MemoryManager.h"

typedef struct __matrix{
	
	int num_rows;
	int num_cols;
	double* elements;
} matrix;

//Acts as a header for all defined functions

//Allocates for a matrix of size specified by num_cols and num_rows
matrix* matrix_malloc(int num_rows, int num_cols);

//Frees up space taken up by mat
void matrix_free(matrix* mat);

//Sets the element of an array
void set_element(matrix* mat, int row, int col, double val);

//Gets the element of mat at location row, col
double get_element(matrix* mat, int row, int col);

//Multiplies matricies and returns result
matrix* multiply(matrix* left, matrix* right);

//Displays the matrix
void display(matrix* mat);


matrix* matrix_malloc(int num_rows, int num_cols){

	int total_size = num_rows*num_cols;
	if (num_rows <= 0 || num_cols <= 0)
	{
		printf("Required to have rows and columns > 0\n");
		return 0;
	}
	
	matrix* temp_matrix = (matrix *)mem_manager_malloc(sizeof(matrix));
	temp_matrix->num_cols = num_cols;
	temp_matrix->num_rows = num_rows;
	temp_matrix->elements = (double *)mem_manager_malloc(total_size*(sizeof(double)));

	for (int i = 0; i < total_size; i++){
		temp_matrix->elements[i] = 0;
	}
	
	return temp_matrix;	
}

void matrix_free(matrix* mat){

	//Detects for matrix that does not exist
	if (mat->num_rows == 0 || mat->num_cols == 0){

		printf("No matrix to free!\n");
		return;
	}
	
	//Sets number of rows and columns to zero
	mat->num_rows = 0;
	mat->num_cols = 0;
	
	//Frees all space of the matrix
	mem_manager_free(mat->elements); //free all of the elements in the matrix
	mem_manager_free(mat);			 //free the matrix itself
}

void set_element(matrix* mat, int row, int col, double val){
	
	//Detects if matrix is not existant
	if (mat->num_rows == 0 || mat->num_cols == 0){
		printf("No matrix to give data!\n");
		return;
	}

	//Does math to determine where to set the element in the array
	int index = (row - 1)*mat->num_cols + col - 1;
	mat->elements[index] = val;
}

double get_element(matrix* mat, int row, int col){

	//Detects if matrix is not existant
	if (mat->num_rows == 0 || mat->num_cols == 0 || mat == NULL){
		printf("No matrix to get data from!\n");
		return 0;
	}

	//Does math to retrieve the element from the array
	int index = (row - 1)*mat->num_cols + col - 1;
	return mat->elements[index];
}

matrix* multiply(matrix* left, matrix* right){

	//Creates a new matrix based on the size of the two inputs
	int left_rows = left->num_rows;
	int left_cols = left->num_cols;
	int right_rows = right->num_rows;
	int right_cols = right->num_cols;
	matrix* result = matrix_malloc(left_rows, right_cols);
	
	//Does the actual multiplication
	for (int i = 1; i <= left_rows; i++){
		for (int j = 1; j <= right_cols; j++){
			
			double val = 0;
			for (int k = 1; k <= left_cols; k++){
				double element_left = get_element(left, i, k);
				double element_right = get_element(right, k, j);
				double mul = element_left * element_right;
				val += mul;
			}
			set_element(result, i, j, val);
		}
	}
	return result;
}

void display(matrix* mat){

	//Detects if matrix is not existant
	if (mat->num_rows == 0 || mat->num_cols == 0){
		printf("No matrix to display!\n");
		return;
	}

	//Iterates through the array, displaying in matrix format
	for (int rows = 1; rows <= mat->num_rows; rows++){

		for (int columns = 1; columns <= mat->num_cols; columns++){	

			int index = ((rows - 1)*mat->num_cols + columns - 1);
			printf("%f ", mat->elements[index]);
		}
		printf("\n");
	}
}

#endif /* __MATRIX_H */