#include <stdio.h>
#include <assert.h>
#include <stdlib.h>

typedef enum{
	OBJ_INT,
	OBJ_PAIR
} ObjectType;

typedef struct sObject{

	unsigned char marked;
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

void push(VM *vm,Object* obj){
	assert(vm->stackSize<STACK_MAX);
	vm->stack[vm->stackSize++]=obj;
}

Object* pop(VM* vm){
	assert(vm->stackSize>0);
	return vm->stack[--vm->stackSize];
}

Object* newObject(VM* vm,ObjectType type){
	Object* object=malloc(sizeof(Object));
	object->type=type;
	return object;
}

void pushInt(VM* vm,int intValue){
	Object* object=newObject(vm,OBJ_INT);
	object->value=intValue;
	push(vm,object);
}


Object* pushPair(VM* vm){
	Object* object=newObject(vm,OBJ_PAIR);
	object->first=pop(vm);
	object->second=pop(vm);
	push(vm,object);
	return object;
}

void main(){
	VM *nvm=newVM();
	pushInt(nvm,5);
	printf("%d \n",nvm->stackSize);
}

