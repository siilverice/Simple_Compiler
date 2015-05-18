%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
// #include <glib.h>

#define YYSTYPE int64_t
#define OUTFP stderr
#define ADDR_SIZE 4

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
    int val;
    struct node *left, *right;
};
typedef struct node node;
typedef enum {VAR_TT=10, CONST_TT, PLUS_TT=20, MINUS_TT, MULTIPLY_TT, DIVIDE_TT, MOD_TT, ASSIGN_TT, CMP_TT, 
    IF_TT=30, LOOP_TT, LINK_TT=40, EOC_TT=50, PRINT10_TT=60, PRINT16_TT} Token_type;

void init_cgen(FILE *fp)
{
        fprintf(fp, "%s\n", "\t.global\tmain");
        fprintf(fp, "%s\n", "\t.text");
        fprintf(fp, "%s\n", "main:");
        fprintf(fp, "%s\n", "\tpush\t%rbp");
        fprintf(fp, "%s\n", "\tmov %rsp, %rbp");
        fprintf(fp, "%s\n", "\tsub $104, %rsp");
}
void end_cgen(FILE *fp)
{
        fprintf(fp, "%s\n", "\tadd $104, %rsp");
        fprintf(fp, "%s\n", "\tmov $0, %rax");
        fprintf(fp, "%s\n", "\tleave");
        fprintf(fp, "%s\n", "\tret");

        fprintf(fp, "%s\n", "format10:");
        fprintf(fp, "%s\n", "\t.asciz\t\"[%d]\\n\"");
        fprintf(fp, "%s\n", "format16:");
        fprintf(fp, "%s\n", "\t.asciz\t\"[%x]\\n\"");
}

void cgen(node *node, Token_type ttype)
{
    if(ttype == VAR_TT)
    {
        fprintf(OUTFP, "\tmov\t%d(%%rbp), %%rax\n", ADDR_SIZE*node->val);
        fprintf(OUTFP, "\tpush\t%%rax\n");
    }
    else if(ttype == CONST_TT)
    {
        fprintf(OUTFP, "\tpush\t$%d\n", node->val);
    }
    else if(ttype == PLUS_TT)
    {
        fprintf(OUTFP, "\tpop\t%%rax\n");
        fprintf(OUTFP, "\tpop\t%%rbx\n");
        fprintf(OUTFP, "\tadd\t%%rbx, %%rax\n");
        fprintf(OUTFP, "\tpush\t%rax\n");
    }
    else if(ttype == MINUS_TT)
    {
        fprintf(OUTFP, "\tpopl\t%%rax\n");
        fprintf(OUTFP, "\tpopl\t%%rbx\n");
        fprintf(OUTFP, "\tsub\t%%rbx, %%rax\n");
        fprintf(OUTFP, "\tpushl\t%rax\n");
    }
    else if(ttype == PRINT10_TT)
    {
        fprintf(OUTFP, "#todo\n");
    }
    else if(ttype == EOC_TT)
    {
        end_cgen(OUTFP);
    }


}

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
                n->val = 'E';
                root = n;
            }

            printf("[%d]", root->token_type);
            cgen(root, root->token_type);
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
%token PRINTDECIMAL PRINTHEXA
%token EOC


%left PLUS MINUS EQ
%left DIVIDE MOD TIMES
%left NEG
%left PRINTDECIMAL PRINTHEXA

%start Input
%%

Input:

     | Input Line {
                        node *n = (node*)malloc(sizeof(node));
                        n->token_type = LINK_TT;
                        n->left = (node*)$2;
                        n->right = (node*)$1;
                        n->val = 'K';
                        root_node = n;
                        $$=(int64_t)n;
                    }

;


Line:
     END
    | Condstatement END
    | Loopstatement END
    /*| PRINT10 Statement END {
        printf("1: \n");
                                node *n = (node*)malloc(sizeof(node));
        printf("2: \n");
                                n->token_type = PRINT10_TT;
        printf("3: \n");
                                n->left = (node*)$2;
        printf("4: \n");
                                n->right = NULL;
        printf("5: \n");
                                n->val = 'D';
        printf("6: \n");
                                $$=(int64_t)n;
        printf("7: \n");

                            } ;
                    
    | PRINT16 Statement END {
        printf("1: \n");
                                node *n = (node*)malloc(sizeof(node));
        printf("2: \n");
                                n->token_type = PRINT16_TT;
        printf("3: \n");
                                n->left = (node*)$2;
        printf("4: \n");
                                n->right = NULL;
        printf("5: \n");
                                n->val = 'H';
        printf("6: \n");
                                $$=(int64_t)n;
        printf("7: \n");
                            };
        */
    | PrintD END 
   // | PrintH END 
    | Assign END
    | EOC END { 
            // node *n = (node*)malloc(sizeof(node));
            // n->token_type = EOC_TT;
            // n->left = NULL;
            // n->right = NULL;
            // n->val = 'E';
            // root_node = n;
            // printf("before-root->right\n");
            // if(root_node->right==NULL){
            //   printf("root->right\n");
            //   root_node->right=n;
                
            // } 
            traverse_tree(root_node);  
            }
	| Error END {printf("ERROR\n");}
	| error END {printf("ERROR\n");}
;

PrintD:
    PRINTDECIMAL Statement {
        printf("1: \n");
                                node *n = (node*)malloc(sizeof(node));
        printf("2: \n");
                                n->token_type = PRINT10_TT;
        printf("3: \n");
                                n->left = (node*)$2;
        printf("4: \n");
                                n->right = NULL;
        printf("5: \n");
                                n->val = 'D';
        printf("6: \n");
                                $$=(int64_t)n;
        printf("7: \n");

                    } ;
/*PrintH:
    PRINTHEXA HEXNUM {
        printf("1: \n");
                                node *n = (node*)malloc(sizeof(node));
        printf("2: \n");
                                n->token_type = PRINT16_TT;
        printf("3: \n");
                                n->left = (node*)$2;
        printf("4: \n");
                                n->right = NULL;
        printf("5: \n");
                                n->val = 'H';
        printf("6: \n");
                                $$=(int64_t)n;
        printf("7: \n");

                    } ;
*/


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
                                    n->val = '+';
                                    $$=(int64_t)n;
                                }
    | Statement MINUS Statement { 
                                    node *n = (node*)malloc(sizeof(node));
                                    n->token_type = MINUS_TT;
                                    n->left = (node*)$1;
                                    n->right = (node*)$3;
                                    n->val = '-';
                                    $$=(int64_t)n;
                                }
    | Statement TIMES Statement { 
                                    node *n = (node*)malloc(sizeof(node));
                                    n->token_type = MULTIPLY_TT;
                                    n->left = (node*)$1;
                                    n->right = (node*)$3;
                                    n->val = '*';
                                    $$=(int64_t)n;
                                }
    | Statement DIVIDE Statement { 
                                    node *n = (node*)malloc(sizeof(node));
                                    n->token_type = DIVIDE_TT;
                                    n->left = (node*)$1;
                                    n->right = (node*)$3;
                                    n->val = '/';
                                    $$=(int64_t)n;
                                }
    | Statement MOD Statement { 
                                    node *n = (node*)malloc(sizeof(node));
                                    n->token_type = MOD_TT;
                                    n->left = (node*)$1;
                                    n->right = (node*)$3;
                                    n->val = '%';
                                    $$=(int64_t)n;
                                }
    | MINUS Statement %prec NEG { 
                                    node *n1 = (node*)malloc(sizeof(node));
                                    n1->token_type = CONST_TT;
                                    n1->left = NULL;
                                    n1->right = NULL;
                                    n1->val = 0;

                                    node *n2 = (node*)malloc(sizeof(node));
                                    n2->token_type = MINUS_TT;
                                    n2->left = n1;
                                    n2->right = (node*)$2;
                                    n2->val = '-';
                                    $$=(int64_t)n2;
                                }
;

Const:
    NUMBER { 
                node *n = (node*)malloc(sizeof(node));
                n->token_type = CONST_TT;
                n->left = NULL;
                n->right = NULL;
                n->val = $1;
                printf("%d ", $1); 
                $$=(int64_t)n;
            }
    | HEXNUM { 
                node *n = (node*)malloc(sizeof(node));
                n->token_type = CONST_TT;
                n->left = NULL;
                n->right = NULL;
                n->val = $1;
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
                        n->val = '=';
                        regis[n->left->val] = n->right->val;
                        $$=(int64_t)n;
                    }
;


Condstatement:
    IF  Expression  Assign  { 
                        node *n = (node*)malloc(sizeof(node));
                        n->token_type = IF_TT;
                        n->left = (node*)$2;
                        n->right = (node*)$3;
                        n->val = 'I';
                        $$=(int64_t)n;
                    }
;

Loopstatement:
    LOOP NUMBER TO NUMBER Assign  {
                        node *n1 = (node*)malloc(sizeof(node));
                        n1->token_type = CONST_TT;
                        n1->left = NULL;
                        n1->right = NULL;
                        n1->val = $4-$2;

                        node *n = (node*)malloc(sizeof(node));
                        n->token_type = LOOP_TT;
                        n->left = n1;
                        n->right = (node*)$5;
                        n->val = 'L';
                        $$=(int64_t)n;
                    }
;

Expression:
    Statement EQ EQ Statement   { 
                                    node *n = (node*)malloc(sizeof(node));
                                    n->token_type = CMP_TT;
                                    n->left = (node*)$1;
                                    n->right = (node*)$4;
                                    n->val = 'C';
                                    $$=(int64_t)n;
                                }
;

Reg:
     REG NUMBER {
                    node *n = (node*)malloc(sizeof(node));
                    n->token_type = VAR_TT;
                    n->left = NULL;
                    n->right = NULL;
                    //n->val = regis[$2];
                    n->val = $2;
                    printf("reg%d ", $2); 
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
    init_cgen(OUTFP);
    if (yyparse())
        fprintf(stderr, "Successful parsing.\n");
    else
        fprintf(stderr, "error found.\n");
    return 0;
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

