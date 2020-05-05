%{
    #include<stdio.h>
    #include<string.h>
    extern FILE *yyin;
    extern int yylineno;
    struct Node* head=NULL;
    struct funcNode* funchead=NULL;

%} 



%union
{
    char *str;
    int ival;
    float fval;
}
%start start
%token datatype space keyword constant operator identifier jumpst ret
%type <ival> datatype constant exp
%type <str> operator identifier variable assignment


 
%%
start   : declaration start
        | assignment start
        | statements start
        | 
        ;
declaration : datatype space variable ';'   {   
                                                if (check_variable($3)==-1 && check_func($3)==-1) { update_symbol_table($1,$3);}
                                                else if(check_variable($3)!=-1) 
                                                {
                                                    printf("\nline %d : error :-  redifining variable '%s' \n",yylineno,$3);
                                                    
                                                }
                                                else
                                                {
                                                    printf("\nline %d : error :- '%s' is already used as function name \n",yylineno,$3);
                                                    
                                                }
                                            } 
            | datatype space identifier '(' datatype space identifier ')' {   
                                                if (check_variable($3)==-1 && check_func($3)==-1 && check_variable($7)==-1) { update_func_table($1,$5,$3);update_symbol_table($5,$7);}
                                                else if(check_func($3)!=-1) 
                                                {
                                                    printf("\nline %d : error :-  redifining function '%s' \n",yylineno,$3);
                                                    
                                                }
                                                else if(check_variable($7)!=-1)
                                                {
                                                    printf("\nline %d : error :- '%s' is already used as variable name \n",yylineno,$7);
                                                    
                                                }
                                            }
            | datatype space identifier '(' ')' {   
                                                if (check_variable($3)==-1 && check_func($3)==-1) { update_func_table($1,3,$3);}
                                                else if(check_func($3)!=-1) 
                                                {
                                                    printf("\nline %d : error :-  redifining function '%s' \n",yylineno,$3);
                                                    
                                                }
                                            }         
            ;

variable    : identifier                    { $$ = $1;}
            | keyword                       {yyerror("keyword cannot be an identifier");}
            ;

statements  : jumpst ';'            {yyerror("jump statements can only be used in loops and switch");}
            | ret space identifier ';' {;}
            | ret ';'            {;}
            | identifier '(' identifier ')' ';'{
                                                if (check_func($1)!=-1 && check_variable($3)!=-1)
                                                {
                                                    if (check_func($1)!=check_variable($3)){yyerror("actual and formal parameter's datatype are different");}
                                                }
                                                else if (check_func($1)==-1)
                                                {
                                                    printf("\nline %d : error :- function '%s' is not defined \n",yylineno,$1);
                                                    
                                                }
                                                else
                                                {
                                                    printf("\nline %d : error :- variable '%s' is not defined \n",yylineno,$3);
                                                       

                                                } 

                                            }

            ;


assignment  : identifier '=' exp ';'{   
                                        if (check_variable($1)==-1)
                                        {
                                            printf("\nline %d : error :- variable '%s' is not defined \n",yylineno,$1);
                                            
                                        } 
                                        if (check_variable($1)!=$3) { yyerror("vriables/constants of diferent datatype cannot be assigned");} 
                                    }
            ;
exp         : identifier{
                            if (check_variable($1)==-1)
                            {
                                printf("\nline %d : error :- variable '%s' is not defined \n",yylineno,$1);
                                
                            } 
                            else
                            {
                                $$=check_variable($1);
                            }
                        }
            | identifier operator identifier{
                                                if (check_variable($1)==-1)
                                                {
                                                    printf("\nline %d : error :- variable '%s' is not defined \n",yylineno,$1);
                                                    
                                                }
                                                else if (check_variable($3)==-1)
                                                {
                                                    printf("\nline %d : error :- variable '%s' is not defined \n",yylineno,$3);
                                                    
                                                }
                                                else
                                                {
                                                    if (check_variable($1)==check_variable($3)) { $$=check_variable($1); }
                                                    else { yyerror("arithmetic operation cannont be performed on different datatypes ");}
                                                }
                                            }
            | constant                          { $$=$1;}
            | constant operator constant        { 
                                                    if ($1==$3) {$$=$1;}
                                                    else {yyerror("arithmetic operation cannont be performed on different datatypes ");}
                                                }
            ;

%%

struct Node 
{ 
    int var_type; 
    char* var_name;
    struct Node* next; 
};

struct funcNode 
{ 
    int f_parameter_type;
    int ret_type; 
    char* f_name;
    struct funcNode* next; 
}; 

int check_variable(char* name)
{
    struct Node* temp=head;
    while(temp!=NULL)
    {
        if(strcmp(name,temp->var_name)==0) {return temp->var_type;}
        temp=temp->next;

    }
    return -1;
}

int check_func(char* name)
{
    struct funcNode* temp=funchead;
    while(temp!=NULL)
    {
        if(strcmp(name,temp->f_name)==0) {return temp->f_parameter_type;}
        temp=temp->next;

    }
    return -1;

}

void update_symbol_table(int dtype,char* name)
{
    int i;
    struct Node* temp1;
    struct Node* temp=(struct Node*)malloc(sizeof(struct Node));
    temp->var_type=dtype;
    temp->var_name=strdup(name);
    temp->next=NULL;

    if (head==NULL)
    {
        head=temp;
        return;
    }

    temp1=head;
    while(temp1->next!=NULL)
    {
        temp1=temp1->next;
    }
    temp1->next=temp; 

}

void update_func_table(int rtype,int ptype,char* name)
{
    int i;
    struct funcNode* temp1;
    struct funcNode* temp=(struct funcNode*)malloc(sizeof(struct funcNode));
    temp->f_parameter_type=ptype;
    temp->ret_type=rtype;
    temp->f_name=strdup(name);
    temp->next=NULL;

    if (funchead==NULL)
    {
        funchead=temp;
        return;
    }

    temp1=funchead;
    while(temp1->next!=NULL)
    {
        temp1=temp1->next;
    }
    temp1->next=temp; 

}

void print_nodes()
{
    printf("----------------------------------variable table----------------------------------\n");
    printf("data type\t\t\tvariable name\n");
    printf("----------------------------------------------------------------------------------\n");
    struct Node* temp=head;
    if (head==NULL)
    {
        return;
    }
    do 
    {
        printf("    %d\t\t\t\t    %s\n",temp->var_type,temp->var_name);
        temp=temp->next;

    }while(temp!=NULL);
}

void print_func_nodes()
{
    printf("----------------------------------function table----------------------------------\n");
    printf("return type\t\t\tfunction name\t\t\tparameter type\n");
    printf("----------------------------------------------------------------------------------\n");

    struct funcNode* temp=funchead;
    if (funchead==NULL)
    {
        return;
    }
    do 
    {
        printf("    %d\t\t\t\t   %s\t\t\t\t%d\n",temp->ret_type,temp->f_name,temp->f_parameter_type);
        temp=temp->next;

    }while(temp!=NULL);
}


void yyerror(char *s)
{
    printf("\nline %d : error :- %s \n",yylineno,s);
    
}

void main()
{
    char filename[100];
    printf("enter file name : ");
    scanf("%s",&filename);
    yyin = fopen(filename,"r"); 
    yyparse();
    print_nodes();
    print_func_nodes();
    printf("\nDATATYPES\n0\tchar\n1\tint\n2\tfloat\n3\tvoid\n");
}