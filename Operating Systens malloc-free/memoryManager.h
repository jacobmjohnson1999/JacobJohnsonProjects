#ifndef MEMORYMANAGER_H
#define MEMORYMANAGER_H

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

#define MAGIC 1234567

//Defines an allocated space requested for a process
typedef struct __mmalloc_t{
	int size;
	int magic;
	double padding;
} mmalloc_t;

//Defines a free space once a program is no longer used and freed
typedef struct __mmfree_t{
	int size;
	struct __mmfree_t *next;
	
} mmfree_t;

//Creates a free space to point to all other free spaces
mmfree_t* head;

//Acts as a header for all defined functions

//Allocates for a space the size of "space" plus the size of header
//Returns the address of the space requested
void* mem_manager_malloc(int size);

//Frees a space pointed to by "ptr" and adds to the total free space
void mem_manager_free(void* ptr);

//Displays information to the screen about the free space available
void traverse_free_list();

//Should be the first function called by the user to set up the space for requesting
//free_space_size is the amount of space desired for use by the user
void init_mem(int free_space_size);

//Called by mem_manager_malloc. Is used to find an available space where a process can go
//Uses the first fit method for locating
mmfree_t* locate_split(mmfree_t* curr,int total_requested_size);

//Called by mem_manager_free. Traverses free list to find where in the linked list of free
//spaces to insert the newly freed space
mmfree_t* find_sorted_location(mmfree_t* head, mmfree_t* to_insert);

//Called by mem_manager_free. Used to make the linked list of free spaces smaller so that there
//are fewer nodes with larger spaces
void coalesce();

void* mem_manager_malloc(int size){

	//Inmitializes variables for use
	int newSize = 0;
	void *tempPoint = NULL;
	mmfree_t* tmp = head;

	//tempPoint gets the address of the available free space to insert the process
	tempPoint = locate_split(tmp,size);

	//This is called if locate split either fails or there is no space to return to the user
	if (tempPoint == NULL){
        return NULL;
    }

	//Gets the item that points to the new space
	mmfree_t* currentHead = head;
	while (currentHead->next != tempPoint && currentHead->next != NULL){
		currentHead = currentHead->next;
	}

	//Creates a temporary head to operate on as a free space
    mmalloc_t* tempHead = (mmfree_t*)tempPoint;
    int currentSize = tempHead->size;
    tempHead->magic = MAGIC;
    tempHead->size = size;

	//Puts the free space in the correct place to account for the mmalloc_t
    void* tempPointer = ((void*)tempHead) + sizeof(mmalloc_t);
    tempPoint = tempPoint + size + sizeof(mmalloc_t);
    mmfree_t* tempPoint2 = (mmfree_t*)tempPoint;	
    
	//Determines if the current process is going to take up the entirety of the space it can take
	if(currentSize == size+16){
		head = head->next;

	}else{
		tempPoint2->size = currentSize - size - sizeof(mmalloc_t);
	}

	//Determines if the head is not the process being modified so that the head is not changed
	if((void*)head != tempPoint - size - sizeof(mmalloc_t)){

		tempPoint2->size = currentSize - size - sizeof(mmalloc_t);
		if(tempPoint2->size == 0){

			currentHead->next = NULL;
		}else{
			
			tempPoint2->next = currentHead->next->next;
			currentHead->next = tempPoint2;
		}
	}else{

		void* tempNext = head->next;
		head = tempPoint;
		head->next = tempNext;
		//tempPoint2->next = currentHead;
	}
	
	//Returns the address of the allocated space for the process
    return tempPointer;
}

void mem_manager_free(void *ptr){
	
	//Operates on the pointer to get the size of the head back
	void* returnedAddress = ptr - sizeof(mmalloc_t);
	mmalloc_t* tempHead = (mmalloc_t*)returnedAddress;
	int currentFreeSize = tempHead->size;

	//Forces returnedAddress into a free node so that it can be inserted to the free list
	mmfree_t* myTemp = (mmfree_t*)returnedAddress;
	myTemp->size = currentFreeSize;
	
	//Finds the place where myTemp should be inserted
	mmfree_t* newSortedSpot = find_sorted_location(head, myTemp);
	
	//Detects how to insert the returned node
	//If the head is returned, additional calculations are needed to determine the correct order
	if(newSortedSpot == head && ((long)head - (long)myTemp > 0)){

		myTemp->next = head;
		head = myTemp;
		//myTemp->next->next = NULL;
	}else{
		mmfree_t* newSortedSpot_old = newSortedSpot->next;
		newSortedSpot->next = myTemp;
		myTemp->next = newSortedSpot_old;
	}
	
	//Makes the linked list smaller if possible
	//Needs to be run twice to do cleanup for the end
	coalesce();
	coalesce();
	
}


void traverse_free_list(){
    
	//Creates temporary variable for traversing
	mmfree_t *tempHead = head;
    
	//Iterates through the free list, displaying along the way
	while (tempHead){
        printf("Size: %d\t\tLocation: %p\n",tempHead->size,tempHead);
        tempHead = tempHead->next;
        if(tempHead == NULL){
        	break;
        }
    }
}

void init_mem(int free_space_size){
	
	//Given by the textbook
	head = (mmfree_t*)mmap(NULL, free_space_size, PROT_READ|PROT_WRITE, MAP_ANON|MAP_PRIVATE, -1, 0); 
	head->size = free_space_size - sizeof(mmfree_t);
	head->next = NULL;
}

mmfree_t* locate_split(mmfree_t *curr,int total_requested_size){
	
	//Creates variable for traversal
	mmfree_t* myTempIterator = curr;
	total_requested_size = total_requested_size + sizeof(mmalloc_t);
	
	//Iterates through until the end is reached or the requested size is found
	while (myTempIterator != NULL){
		if(myTempIterator->size >= (total_requested_size)){
			return myTempIterator;
		}
		else if(myTempIterator == myTempIterator->next){
			myTempIterator->next = NULL;
		}else{	
			myTempIterator = myTempIterator->next;
		}
	}
	return NULL;
}

mmfree_t* find_sorted_location(mmfree_t* head, mmfree_t* to_insert){
	
	//Creates varibale for traversal and one for previous traversal
	mmfree_t* myTempIterator = head;
	mmfree_t* previous = myTempIterator;

	//Creates variable for difference in addresses
	long addressDiff = (long)to_insert - (long)myTempIterator;
	
	//Checks if head is the only node
	if(myTempIterator->next == NULL){
		return head;
	}

	//Traverses the list and chooses the spot to put the node in
	while((long)addressDiff > 0 && (myTempIterator->next != NULL)){
		previous = myTempIterator;
		myTempIterator = myTempIterator->next;
		addressDiff = (long)to_insert - (long)myTempIterator;
	}
	return previous;
}

void coalesce(){

	//Creates variable for traversal
	mmfree_t* myTempIterator = head;

	//Iterates through the free list and coalesces as it is available
	//Only the current and next node need to be looked at since the list is ordered
	while(myTempIterator){
		
		if((long)(myTempIterator->next)-(long)myTempIterator == ((myTempIterator->size) + sizeof(mmalloc_t))){
			myTempIterator->size = myTempIterator->size + myTempIterator->next->size + sizeof(mmalloc_t);
			myTempIterator->next = myTempIterator->next->next;
		}
		myTempIterator = myTempIterator->next;
	}

}

#endif /* MEMORYMANAGER_H */