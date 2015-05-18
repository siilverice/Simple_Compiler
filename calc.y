%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
// #include <glib.h>

#define YYSTYPE int64_t

int64_t regis[26]={0};
int64_t acc,temppop;
int64_t *top;
struct stack
{
    int64_t info;
    struct stack *link;
};
struct node
{
    int token_type;
    char *val;
    struct node *left, *right;
};
typedef struct node node;
typedef enum {VAR_TT=10, CONST_TT, PLUS_TT=20, MINUS_TT, MULTIPLY_TT, DIVIDE_TT, MOD_TT, ASSIGN_TT, CMP_TT, IF_TT=30, LOOP_TT, LINK_TT=40, EOC_TT=50} Token_type;

void traverse_tree(node *root)
{
        if(root->left != NULL)
            traverse_tree(root->left);
        
        if(root->right != NULL)
            traverse_tree(root->right);

        if(root != NULL){
            if(root->token_type<10){
                node *n = (node*)malloc(sizeof(node));
                n->token_type = EOC_TT;
                n->left = NULL;
                n->right = NULL;
                n->val = (char*)'E';
                root = n;
            }
            
            printf("[%d]", root->token_type);
        }
}
node *root_node = NULL;

struct stack *start=NULL;
// GTree* t = g_tree_new((GCompareFunc)g_ascii_strcasecmp);

// int64_t* getTopPtr();
char top_flag = 0;
char show_flag = 0;
%}

%token NUMBER
%token HEXNUM
%token SHOW
%token PLUS MINUS DIVIDE MOD TIMES
%token LEFT RIGHT
%token CLEFT CRIGHT
%token REG 
%token ERROR
%token END
%token LOOP IF TO EQ
%token PRINT10 PRINT16
%token EOC


%left PLUS MINUS EQ
%left DIVIDE MOD TIMES
%left NEG

%start Input
%%

Input:

     | Input Line {
                        node *n = (node*)malloc(sizeof(node));
                        n->token_type = LINK_TT;
                        n->left = (node*)$2;
                        n->right = (node*)$1;
                        n->val = (char*)'K';
                        root_node = n;
                        $$=(int64_t)n;
                    }

;


Line:
     END
    | Condstatement END
    | Loopstatement END
    | PRINT10 Statement END {} ;
    | PRINT16 Statement END {} ;
    | Assign END
    | EOC END { 
            // node *n = (node*)malloc(sizeof(node));
            // n->token_type = EOC_TT;
            // n->left = NULL;
            // n->right = NULL;
            // n->val = (char*)'E';
            // root_node = n;
            // printf("before-root->right\n");
            // if(root_node->right==NULL){
            //   printf("root->right\n");
            //   root_node->right=n;
                
            // } 
            traverse_tree(root_node);  }
	| Error END {printf("ERROR\n");}
	| error END {printf("ERROR\n");}
;

Statement:
    Const
    | LEFT Statement RIGHT { printf("(STMT)"); }
    | CLEFT Statement CRIGHT { printf("{STMT}"); }
	| Reg  
    | Statement PLUS Statement  { 
                                    node *n = (node*)malloc(sizeof(node));
                                    n->token_type = PLUS_TT;
                                    n->left = (node*)$1;
                                    n->right = (node*)$3;
                                    n->val = (char*)'+';
                                    $$=(int64_t)n;
                                }
    | Statement MINUS Statement { 
                                    node *n = (node*)malloc(sizeof(node));
                                    n->token_type = MINUS_TT;
                                    n->left = (node*)$1;
                                    n->right = (node*)$3;
                                    n->val = (char*)'-';
                                    $$=(int64_t)n;
                                }
    | Statement TIMES Statement { 
                                    node *n = (node*)malloc(sizeof(node));
                                    n->token_type = MULTIPLY_TT;
                                    n->left = (node*)$1;
                                    n->right = (node*)$3;
                                    n->val = (char*)'*';
                                    $$=(int64_t)n;
                                }
    | Statement DIVIDE Statement { 
                                    node *n = (node*)malloc(sizeof(node));
                                    n->token_type = DIVIDE_TT;
                                    n->left = (node*)$1;
                                    n->right = (node*)$3;
                                    n->val = (char*)'/';
                                    $$=(int64_t)n;
                                }
    | Statement MOD Statement { 
                                    node *n = (node*)malloc(sizeof(node));
                                    n->token_type = MOD_TT;
                                    n->left = (node*)$1;
                                    n->right = (node*)$3;
                                    n->val = (char*)'%';
                                    $$=(int64_t)n;
                                }
    | MINUS Statement %prec NEG { 
                                    node *n1 = (node*)malloc(sizeof(node));
                                    n1->token_type = CONST_TT;
                                    n1->left = NULL;
                                    n1->right = NULL;
                                    n1->val = (char*)0;

                                    node *n2 = (node*)malloc(sizeof(node));
                                    n2->token_type = MINUS_TT;
                                    n2->left = n1;
                                    n2->right = (node*)$2;
                                    n2->val = (char*)'-';
                                    $$=(int64_t)n2;
                                }
;

Const:
    NUMBER { 
                node *n = (node*)malloc(sizeof(node));
                n->token_type = CONST_TT;
                n->left = NULL;
                n->right = NULL;
                n->val = (char*)$1;
                printf("%d ", $1); 
                $$=(int64_t)n;
            }
    | HEXNUM { 
                node *n = (node*)malloc(sizeof(node));
                n->token_type = CONST_TT;
                n->left = NULL;
                n->right = NULL;
                n->val = (char*)$1;
                printf("%d ", $1); 
                $$=(int64_t)n;
            }
;

Assign:
    Reg EQ Statement { 
                        node *n = (node*)malloc(sizeof(node));
                        n->token_type = ASSIGN_TT;
                        n->left = (node*)$1;
                        n->right = (node*)$3;
                        n->val = (char*)'=';
                        $$=(int64_t)n;
                    }
;


Condstatement:
    IF  Expression  Assign  { 
                        node *n = (node*)malloc(sizeof(node));
                        n->token_type = IF_TT;
                        n->left = (node*)$2;
                        n->right = (node*)$3;
                        n->val = (char*)'I';
                        $$=(int64_t)n;
                    }
;

Loopstatement:
    LOOP NUMBER TO NUMBER Assign  {
                        node *n1 = (node*)malloc(sizeof(node));
                        n1->token_type = CONST_TT;
                        n1->left = NULL;
                        n1->right = NULL;
                        n1->val = (char*)$4-$2;

                        node *n = (node*)malloc(sizeof(node));
                        n->token_type = LOOP_TT;
                        n->left = n1;
                        n->right = (node*)$5;
                        n->val = (char*)'L';
                        $$=(int64_t)n;
                    }
;

Expression:
    Statement EQ EQ Statement   { 
                                    node *n = (node*)malloc(sizeof(node));
                                    n->token_type = CMP_TT;
                                    n->left = (node*)$1;
                                    n->right = (node*)$4;
                                    n->val = (char*)'C';
                                    $$=(int64_t)n;
                                }
;

Reg:
     REG NUMBER {
                    node *n = (node*)malloc(sizeof(node));
                    n->token_type = VAR_TT;
                    n->left = NULL;
                    n->right = NULL;
                    n->val = (char*)regis[$2];
                    printf("%d ", $1); 
                    $$=(int64_t)n;
                }
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

