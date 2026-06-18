#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#define MAX_OBJ 25;

typedef enum{
	OBJ_INT,
	OBJ_PAIR
} ObjectType;

typedef struct sObject{

	unsigned char marked;
	ObjectType type;
    struct sObject* next;	
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
	Object* firstObject;
	Object* stack[STACK_MAX];
	
	int numObjects;
	int maxObjects;
	

	int stackSize;
}VM;

VM* newVM(){ 
	VM* vm=malloc(sizeof(VM));
	vm->stackSize=0;
	vm->firstObject=NULL;
	vm->numObjects=0;
	vm->maxObjects=MAX_OBJ;
	return vm;
}

void gc(VM* vm);

void push(VM *vm,Object* obj){
	assert(vm->stackSize<STACK_MAX);
	vm->stack[vm->stackSize++]=obj;
}

Object* pop(VM* vm){
	assert(vm->stackSize>0);
	return vm->stack[--vm->stackSize];
}

Object* newObject(VM* vm,ObjectType type){
	if(vm->numObjects == vm->maxObjects) gc(vm);

	Object* object=malloc(sizeof(Object));
	object->type=type;
	object->marked=0;
	
	if (vm->firstObject==NULL){
		vm->firstObject=object;
		return object;
	}
	
	object->next=vm->firstObject;
	vm->firstObject=object;

	vm->numObjects++;
	
	return object;
}


void sweep(VM* vm){
	Object** obj=&vm->firstObject;
	while(*obj){
		if((*obj)->marked==0){
			Object* temp=*obj;
			*obj=temp->next;
			free(temp);
			--vm->numObjects;
			continue;
		}
		(*obj)->marked=0;//prepare for next sweep if not in stack
		obj=&(*obj)->next;
	}
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



void mark(Object* obj){
	if (obj->marked) return; 

	obj->marked=1;

	if(obj->type==OBJ_PAIR){
		mark(obj->first);
		mark(obj->second);
	}

}

void markAll(VM* vm){
	for(int i=0;i<vm->stackSize;++i){
		mark(vm->stack[i]);
	}

}



void gc(VM* vm){
	int numObj=vm->numObjects;

	markAll(vm);
	sweep(vm);

	vm->maxObjects=vm->numObjects*2;

	printf(" Before num:%d \nafter num :%d \n",numObj,vm->numObjects);
}
void checkPerformance(VM* nwvm){
	for(int i=0;i<600;i++){
		for(int j=0;j<8;j++){
			pushInt(nwvm,i);
		}

		for (int k=0;k<6;k++){
			pop(nwvm);
		}
		
	}
	
}

void main(){
	VM *nwvm=newVM();
	pushInt(nwvm,5);
	printf("%d \n",nwvm->stackSize);
	checkPerformance(nwvm);
}

