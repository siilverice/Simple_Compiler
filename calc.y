%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>

#define YYSTYPE int64_t

int64_t regis[10]={0};
int64_t acc,temppop;
int64_t *top;
struct stack
{
    int64_t info;
    struct stack *link;
};

struct stack *start=NULL;

int64_t* getTopPtr();
char top_flag = 0;
char show_flag = 0;
%}

%token NUMBER
%token BINNUM
%token HEXNUM
%token SHOW
%token PLUS MINUS DIVIDE MOD TIMES
%token LEFT RIGHT
%token CLEFT CRIGHT
%token REG 
%token ERROR
%token END
%token LOOP IF EQ


%left PLUS MINUS
%left DIVIDE MOD TIMES

%start Input
%%

Input:
     | Input Line
;

Line:
     END
	| Expression END
        {
            if(!top_flag)
            {
                printf("Result: %"PRId64"\n", $1);
                if(!show_flag)
                    acc=$1;
                else
                    show_flag = 0;
            }
            else
            {
                top_flag = 0;
            }
        }
	| Error END {printf("ERROR\n");}
	| error END {printf("ERROR\n");}
;

Expression:
     NUMBER { $$=$1; }
    | HEXNUM { $$=$1; }
	| Expression PLUS Expression { $$=$1+$3; }
	| Expression MINUS Expression { $$=$1-$3; }
	| Expression TIMES Expression { $$=$1*$3; }
	| Expression DIVIDE Expression { $$=$1/$3; }
	| Expression MOD Expression { $$=$1%$3; }
    | LEFT Expression RIGHT { $$=$2; }
    | CLEFT Expression CRIGHT { $$=$2; }
    | SHOW Reg { $$=$2; show_flag=1; }
	| Reg { $$ = $1; }
;

Reg:
    REG NUMBER { $$=regis[$2]; }
;

Error:
	ERROR {}
	| Error ERROR {}

%%

int yyerror(char *s) {
    printf("%s\n", s);
}

int main() {

    if (yyparse())
        fprintf(stderr, "Successful parsing.\n");
    else
        fprintf(stderr, "error found.\n");

}


push(int64_t data)
{
    struct stack *new,*temp;
    int64_t i=0;

    new=(struct stack *)malloc(sizeof(struct stack));
    new->info = data;
    new->link=start;
    start=new;
}

pop(int64_t id)
{
    struct stack *temp,*temp2;
    int64_t i=0;

    for(temp=start;temp!=NULL;temp=temp->link)
    {
        i++;
    }

    if(i==0)
    {
        fprintf(stderr, "error: stack empty.\n");
    }

    else
    {
        regis[id] = getTop();
        temp2=start->link;
        start=temp2;
        printf("\n***The value has been poped***\n");
    }
}

display()
{
    struct stack *temp;
    printf("\n****Stack Values****\n");
    printf("TOP : %"PRId64"\n", getTop());
    for(temp=start;temp!=NULL;temp=temp->link)
    {
        printf("%"PRId64"\n",temp->info);
    }
}

getSize()
{
    struct stack *temp;
    int64_t i=0;
    for(temp=start;temp!=NULL;temp=temp->link)
    {
        i++;
    }
    return i;
}

getTop()
{
    return start->info;
}
int64_t* getTopPtr()
{
    return &(start->info);
}

