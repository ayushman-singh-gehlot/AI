%{
#include<stdio.h>
#include<stdlib.h>
#include "y.tab.h"  
int yylineno=1;
void yyerror (char *s);
int yylex();
%}
KEYWORD (auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while)
OP [-+*/]
NUMBER [0-9]+
ID [_a-zA-Z][_a-zA-Z0-9]*
SPACE [ ]+

%%

char 					{yylval.ival=0;return datatype;}
int 					{yylval.ival=1;return datatype;}
float 					{yylval.ival=2;return datatype;}
void 					{yylval.ival=3;return datatype;}
break					{return jumpst;}
continue				{return jumpst;}
return					{return ret;}  
{SPACE} 				{return space;}
{KEYWORD}				{return keyword;}
{ID}					{yylval.str=strdup(yytext); return identifier;}
{OP}                    {yylval.str=strdup(yytext); return operator;}
\'[a-zA-Z]\' 			{yylval.ival=0;return constant;}
-?{NUMBER} 				{yylval.ival=1;return constant;}
-?{NUMBER}\.{NUMBER}	{yylval.ival=2;return constant;}

[;] 					{return(';');}
[(] 					{return('(');}
[)] 					{return(')');}
[=] 					{return('=');}
[\n] 					{yylineno++;}
"//".*					{;}       
#(include).*			{;}       
. 						{;}
%%

int yywrap() {} 