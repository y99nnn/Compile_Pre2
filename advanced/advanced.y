%{
#include <stdlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#define NSYMS 100

struct symtab { // 符号表中的每个表项
    char *name; // 标识符的名称
    double value; // 对应的数值
} symtab[NSYMS];
// 符号表数组的大小由常量 NSYMS 定义

char idStr[100];

struct symtab *symlook(char *s);

int yylex();

extern int yyparse(); 

FILE *yyin; 

void yyerror(const char *s); 
%}

%union {
    double val; // 数字的属性值为双精度浮点数
    struct symtab *sym; // 标识符的属性值是指向符号表表项的指针
}

// token 声明词法符号
%token ADD
%token MINUS
%token MUL
%token DIV
%token UMINUS
%token LEFT_PAR
%token RIGHT_PAR
// 尖括号 (<>) 告诉编译器生成器，<sym> 是一个特殊的符号，用于指示属性值类型。
%token <sym> ID // ID 的属性值类型为 <sym>
%token <val> NUMBER // NUMBER 的属性值类型为 <val>
%token ASSIGN

// 优先级和结合性
%right ASSIGN
%left ADD MINUS
%left MUL DIV
%right UMINUS

%type <val> expr

%%

lines : lines expr ';' { printf("%f\n", $2); }
      | lines ';'
      |
      ;

expr : expr ADD expr { $$ = $1 + $3; }
     | expr MINUS expr { $$ = $1 - $3; }
     | ID ASSIGN expr { $1->value = $3; $$ = $1->value; }//
     | expr MUL expr { $$ = $1 * $3; }
     | expr DIV expr { $$ = $1 / $3; }
     | LEFT_PAR expr RIGHT_PAR { $$ = $2; }
     | MINUS expr %prec UMINUS { $$ = -$2; }
     | NUMBER { $$ = $1; }
     | ID { $$ = $1->value; }//
     ;

%%

// 在符号表中查找指定的表项
// 参数 *s 是要查找的标识符的名称
// 返回类型为指向符号表中表项的指针
struct symtab *symlook(char *s) {
    char *p;
    struct symtab *sp;

    // sp=symtab : sp 初始化为指向符号表 symtab 的第一个表项的地址
    // &symtab[NSYMS] 是指符号表 symtab 中的第 NSYMS 个表项的地址
    // 遍历符号表中每一个表项
    for (sp = symtab; sp < &symtab[NSYMS]; sp++) {
        // sp->name 是指向字符串的指针, sp->name 条件是指这个字段不为空即指向有效的字符串
        // strcmp 函数比较当前表项 sp 中的 name 字段和字符串 s 是否相等
        if (sp->name && !strcmp(sp->name, s))
            return sp; // 如果找到了表中存在这一项，返回指向该表项的指针
        if (!sp->name) { // 如果 sp->name 字段为空即找不到指定的表项，就新建一个表项
            // strdup(s) 会在堆内存中分配足够的内存来存储字符串，并复制字符串 s 的内容到这块内存中
            sp->name = strdup(s);
            return sp;
        }
    }
    yyerror("The symtab is full");
    exit(1);
}

int yylex() {
    int t;
    while (1) {
        t = getchar();
        if (t == ' ' || t == '\t' || t == '\n') {
            // 忽略空白符
        } else if (isdigit(t)) {
            yylval.val = 0; // 属性值
            while (isdigit(t)) {
                // 更新词法单元的值
                yylval.val = yylval.val * 10 + t - '0';
                t = getchar();
            }
            ungetc(t, stdin); // 回退
            return NUMBER;
        } else if (isalpha(t) || t == '_') { // 标识符以字母下划线开头
            int len = 0;
            while (isalpha(t) || t == '_' || isdigit(t)) { // 数字、字母、下划线
                idStr[len] = t;
                t = getchar();
                len++;
            }
            idStr[len] = '\0';

            // 查找标识符 idStr 并将其关联的符号表项存储到 yylval 的 sym 属性中
            yylval.sym = symlook(idStr);
            ungetc(t, stdin);

            return ID;
        } else if (t == '+') {
            return ADD;
        } else if (t == '-') {
            return MINUS;
        } else if (t == '*') {
            return MUL;
        } else if (t == '/') {
            return DIV;
        } else if (t == '(') {
            return LEFT_PAR;
        } else if (t == ')') {
            return RIGHT_PAR;
        } else if (t == '=') {
            return ASSIGN;
        } else {
            return t;
        }
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}

int main(void) {
    yyin = stdin;
    do {
        yyparse();
    } while (!feof(yyin));
    return 0;
}

