This project is intended to recreate a malloc/free function used in an operating system. This is done in C language and is run using Windows Subsystem for Linux (WSL).

This project was assigned as part of CSC 4100 Operating Systems at Tennessee Technological University. The professor is Dr. Mark A Boshart.

Proper use of mem_manager_malloc is as such:
void* ptr = mem_manager_malloc(sizeOfSpace);
Where ptr is the name of the space to allocate and sizeOfSpace is the amount of space you want to allocate. Note: this does not include the size of the head for mmalloc_t which is added to the front of the space when freed.

Proper use of mem_manager_free is as such:
mem_manager_free(ptr);
Where ptr is the space you want to return to the available free space.

Note: Memory must be initilaized with init_mem(x);
Where x is the size of space to use throughout the program.

This project was also completed with the help of Tyler D McCormick.