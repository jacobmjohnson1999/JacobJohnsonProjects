#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include "Matrix.h"

int main(){

    init_mem(4096);
    void *ptr1 = mem_manager_malloc(100);
    void *ptr2 = mem_manager_malloc(100);
    void *ptr3 = mem_manager_malloc(100);
    void *ptr4 = mem_manager_malloc(100);
    void *ptr5 = mem_manager_malloc(100);
    mem_manager_free(ptr1);
    //mem_manager_free(ptr4);

    printf("Before issue:\n");
    traverse_free_list();
    void *ptr6 = mem_manager_malloc(400);
    void *ptr7 = mem_manager_malloc(400);
    mem_manager_free(ptr6);
    mem_manager_free(ptr5);
    mem_manager_free(ptr2);

    printf("Final call\n");
    void *ptr8 = mem_manager_malloc(500);

    

    /*mem_manager_free(ptr2);

    printf("\nIssue 2:\n");
    traverse_free_list();
    void *ptr9 = mem_manager_malloc(500);*/


    printf("\nAfter issue:\n");
    traverse_free_list();
    return 0;
}