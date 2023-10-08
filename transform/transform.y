%{
//************************************定义段*************************************************

// 为生成的C程序提供一些头文件和定义
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>

// 为了能够返回一个后缀表达式，yacc产生的值即$$的变量类型应该是字符串指针
#ifndef YYSTYPE
#define YYSTYPE char*
#endif

extern YYSTYPE yylval; 
char numStr[100];
char idStr[100];

int yylex();//从输入流中读取字符，并识别和返回词法单元
extern int yyparse();//语法分析器的入口函数
FILE* yyin;//指定输入文件,本实验从标准输入读取输入数据
void yyerror(const char* s);//处理语法分析过程中的错误信息
%}

// 声明词法符号
%token ADD
%token MINUS
%token MUL
%token DIV
%token UMINUS
%token LEFT_PAREN
%token RIGHT_PAREN
%token NUMBER
%token ID

// 声明优先级：后定义的优先级高
%left ADD MINUS
%left MUL DIV
%right UMINUS         
// 负数是右结合，且优先级最高

//************************************规则段*************************************************
%%
// lines 用于处理多行输入，每行都是一个表达式
// lines --> lines expr | lines | epsilon
// 在进行中缀转后缀时，不影响多行表达式的print语义动作

lines   :       lines expr ';' { printf("%s\n", $2); }   // 输出字符串
        |       lines ';'
        |
        ;

// expr 定义了表达式的结构，包括加、减、乘、除等操作
// expr --> epsilon | NUMBER | expr '+' expr | expr '-' expr | expr '*' expr | expr '/' expr | expr '+' expr | 

// 中缀转后缀的方式如下,左侧表示中缀，右侧表示后缀,E'表示E的后缀
// E ==> E （E是常量或变量）
// E1 OP E2 ==> E1' E2' OP
// (E1) ==> E1'
// -E1 ==> -E1'

//根据中缀转后缀的归纳定义，重新编写语义动作
//此处用到了strup和strcat两个C语言函数
//strdup用于创建字符串的副本，将传入的字符串复制一份，并返回一个指向新复制字符串的指针
//strcat用于拼接字符串

expr    :       expr ADD expr   { $$ = strdup($1); strcat($$,$3); strcat($$,"+ "); }
        |       expr MINUS expr { $$ = strdup($1); strcat($$,$3); strcat($$,"- "); }
        |       expr MUL expr   { $$ = strdup($1); strcat($$,$3); strcat($$,"* "); }
        |       expr DIV expr   { $$ = strdup($1); strcat($$,$3); strcat($$,"/ "); }
        |       LEFT_PAREN expr RIGHT_PAREN { $$ = strdup($2); }
        |       NUMBER          { $$ = strdup($1); strcat($$," "); }
        |       MINUS expr %prec UMINUS   { $$ = strdup("- "); strcat($$,$2); } 
        |       ID        { $$ = strdup($1); strcat($$," "); }
        ;  

%%
//************************************辅助函数***********************************************

// yylex函数
int yylex()
{
    int t;
    while(1){
        t = getchar();
        if(t==' '||t=='\t'||t=='\n'){
            // 忽略空白符
        }
        // 识别多位十进制整数转化为可输出的字符串
        else if(isdigit(t)){
            int len = 0;//数字长度
	    yylval = 0;//记录当前读取的数字
            while(isdigit(t)){
		// 将读取到的数字存储在数组中
                numStr[len++] = t;
                t = getchar();// 向前看运算符
            }
            numStr[len] = '\0';//数字结束
            ungetc(t,stdin);//回退字符
            yylval = numStr;
            return NUMBER;
        }

	// 识别标识符并转化为可输出的字符串
        else if ((isalpha(t))||(t == '_')){
            int len = 0;
	    yylval = 0;
            while((isalpha(t))||(t == '_')||isdigit(t)){
                idStr[len++] = t;
                t = getchar();
            }  
            idStr[len] = '\0';
            ungetc(t,stdin);
            yylval = idStr;
            return ID;

        }
	// 识别运算符
        else if(t=='+'){
            return ADD;
        }
        else if(t=='-'){
            return MINUS;
        }
        else if(t=='*'){
            return MUL;
        }
        else if(t=='/'){
            return DIV;
        }
        else if(t=='('){
            return LEFT_PAREN;
        }
        else if(t==')'){
            return RIGHT_PAREN;
        }
        else{
            return t;
        }
    }
}

void yyerror(const char* s){
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}

int main(void)
{
    yyin = stdin;
    do{
        yyparse();
    } while(!feof(yyin));
    return 0;
}

