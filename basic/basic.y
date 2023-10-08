%{
//************************************定义段*************************************************

// 为生成的C程序提供一些头文件和定义
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
// <ctype.h>中包含字符处理的函数宏和字符分类函数
// 详情参考 https://cplusplus.com/reference/cctype/?kw=%3Cctype.h%3E


#ifndef YYSTYPE
#define YYSTYPE double
#endif
// yacc产生的值即$$的变量类型应该是双精度浮点数


int yylex(); 
// yylex函数充当词法分析器，在语法分析过程中被yacc生成的语法分析器（或称为parser）调用
// yylex函数主要任务是读取输入流，识别并返回词法单元或token


extern int yyparse(); 
// 声明外部函数 yyparse，该函数用于启动语法分析器的解析过程。

FILE* yyin;
// 文件指针 yyin，用于指定输入文件。

void yyerror(const char* s);
// 错误处理函数 yyerror，用于处理语法分析过程中的错误信息。

%}

// 声明词法符号
%token ADD
%token MINUS
%token MUL
%token DIV
%token UMINUS
%token LEFT_PAR
%token RIGHT_PAR
%token NUMBER
// 也可以合并声明：%token PLUS MINUS TIMES DIVIDE
// 但根据题目要求应该单独类别

// 声明优先级：后定义的优先级高
%left ADD MINUS
%left MUL DIV
%right UMINUS         
// 负数是右结合，优先级最高

//************************************规则段*************************************************
%%

// lines 用于处理多行输入，每行都是一个表达式
// lines --> lines expr | lines | epsilon
lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |
        ;

// expr 定义了表达式的结构，包括加、减、乘、除等操作
// expr --> epsilon | NUMBER | expr '+' expr | expr '-' expr | expr '*' expr | expr '/' expr | expr '+' expr | 
// $$代表产生式左部的属性值，$i代表产生式右部第i个文法符号的属性值

expr    :       expr ADD expr   { $$ = $1 + $3; }
        |       expr MINUS expr   { $$ = $1 - $3; }
        |       expr MUL expr   { $$ = $1 * $3; }
        |       expr DIV expr   { $$ = $1 / $3; }
        |       LEFT_PAR expr RIGHT_PAR { $$ = $2; }
        |       MINUS expr %prec UMINUS   {$$ = - $2;} 
        |       NUMBER  {$$ = $1;}
        ;
//%prec提升优先级

// 根据题目二要求，NUMBER的复杂度应该能够满足识别多位十进制整数，因此后续编写函数进行更复杂的定义


%%
//************************************辅助函数***********************************************
// 出现在辅助部分中的所有内容都被直接复制到 .c 文件中
// 在这部分就如同 C++ 程序一样，需要对我们在定义段中声明的函数写出具体的函数定义，以及一个 main 函数

// yylex函数

int yylex()
{
    int t;
    while(1){
        t = getchar();
	// 题目二：识别并忽略空格、制表符、回车等空白符
        if(t==' '||t=='\t'||t=='\n'){
           // 忽略空白符
        }
	// 题目二：识别多位十进制整数
        else if(isdigit(t)){
            yylval = 0;//记录当前读取的数字

                // 读取一个数字后，如果不是终结字符就进位（*10）继续读取下一位
           	// 如果是终结符就停止
            while(isdigit(t)){// 如果后面还有能够匹配的数字
                yylval = yylval * 10 + t - '0'; // 更新当前读取的数字
                t = getchar();// 向前看运算符，自动地向前读取到形成被选词素的全部字符之后的那个字符
            }
            // 如果不再满足当前读取的词素相匹配的特定模式，就需要回退输入
            // ungetc函数将读出的多余字符放回标准输入流 stdin去，等待下一次使用
            ungetc(t,stdin);
            return NUMBER;
        }
	// 题目一：识别运算符
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
            return LEFT_PAR;
        }
        else if(t==')'){
            return RIGHT_PAR;
        }
        else{// 输入的字符既不是数字也不是运算符时，就返回他自身
            return t;
        }
    }
}

// 错误处理函数 yyerror
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}
int main(void)
{
    yyin=stdin;//输入标准流
    do{
        yyparse();
    }while(!feof(yyin));
    // feof() 是检测流上的文件结束符的函数，如果文件结束，则返回非0值，否则返回0
    //!feof(yyin)则表示文件未结束就继续循环
    return 0;
}

