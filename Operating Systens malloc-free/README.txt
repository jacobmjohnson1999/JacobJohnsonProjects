No driver funtion is provided. Including matrix.h also includes memoryManager.h since it depends on it. This means you do not have to include memoryManager.h if you have included matrix.h. 

Proper use of mem_manager_malloc is as such:
void* ptr = mem_manager_malloc(sizeOfSpace);
Where ptr is the name of the space to allocate and sizeOfSpace is the amount of space you want to allocate. Note: this does not include the size of the head for mmalloc_t which is added to the front of the space when freed.

Proper use of mem_manager_free is as such:
mem_manager_free(ptr);
Where ptr is the space you want to return to the available free space.

Note: Memory must be initilaized with init_mem(x);
Where x is the size of space to use throughout the program.

Compile using a linux enviorment (or wsl in windows) using gcc.