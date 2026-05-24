#include <stdio.h>
#include <stdlib.h>

typedef enum{
	OBJ_INT,
	OBJ_PAIR
} ObjectType;

typedef struct sObject{

	ObjectType type;
	
	union {
		int value;

		struct{
		
			struct	sObject* first;

			struct	sObject* second;
		
		};
	};
} Object;

#define STACK_MAX 256

typedef struct{
	Object* stack[STACK_MAX];
	int stackSize;
}VM;

VM* newVM(){
	VM* vm=malloc(sizeof(VM));
	vm->stackSize=0;
	return vm;
}


void main(){
	VM *nvm=newVM();
	printf("%d \n",nvm->stackSize);
}

