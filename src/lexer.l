%option noyywrap
%option nounput
%option noinput
%top{
    #include <stdarg.h>
    #include "common.h"
    #include <cctype>
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include<stack>
    #include <map>
    #include <string>
    int current_line = 0;  // 用于跟踪当前行号
    int current_column = 0;  // 用于跟踪当前列号
    char comment_buffer[1024];  // 假设注释不会超过1024个字符
    char *comment_ptr;
    std::stack<int> scopes;  // 栈来处理作用域
    int scope_id = 0;  // 为每个新的作用域分配的唯一标识符
    std::map<std::string, unsigned long> identifierMap;
}
%{
    extern dump_type_t dump_type;

    inline void dump_tokens(const char* format, ...){
        va_list args;
        va_start(args, format);
        if (dump_type == TOKENS)
            vfprintf(yyout, format, args);
        va_end(args);
    }

    void print(const char *name){
        dump_tokens("%s\t%s\t%d\t%d\n",name, yytext, current_line, current_column);
        current_column += strlen(yytext);
    }

    void checkPrint(const char *name){
        print(name);
    }

    void preAndPost(const char *name){
        print(name);
    }
%}



comment  "//".*

letter [a-zA-Z]
digit [0-9] 

EOL (\r\n|\n|\r)
blank  [\t ]

decimal ([1-9][0-9]*|0)
oct 0[0-7]+
hex 0(x|X)[1-9a-fA-F][0-9a-fA-F]*|0

HEADFILE #include[ ]*["<][a-zA-Z/+]*(\.h)?[">]
DEFINE #define[^\n]*

FLOATING [-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?([fFlL])?
HEXFLOATING (0[xX][0-9a-fA-F]+(\.[0-9a-fA-F]+)?([pP][-+]?[0-9]+)?)|([0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?)

LB "{"
LP "("
RB "}"
RP ")"
PLUS \+
MINUS \-
MULT \*
BIT \&
BITAND "&"
DIV "/"
MOD "%"
PLUSA "+="
MINUSA "-="
MULA "*="
DIVA "/="
MODA "%="
LS "<<"
RS ">>"
LSA "<<="
RSA ">>="
NOT "!"
BITOR "|"
XOR "^"
COMPL "~"
AND "&&"
OR "||"
LT "<"
LE "<="
GT ">"
GE ">="
EQ "=="
NE "!="
ASSIGN "="
DOT "."
MS "->"
LA "["
RA "]"
POSINC {IDENTIFIER}{blank}?"++"
POSDEC {IDENTIFIER}{blank}?"--"
PREINC "++"{blank}?{IDENTIFIER}
PREDEC "--"{blank}?{IDENTIFIER}
UNARYMINUS "-"
UNARYPLUS "+"
DEREFERECE "*"
ADDRESS "&"
COMMA ","
SC ";"
ASM "asm"
AUTO "auto"
BOOL "bool"
BREAK "break"
CASE "case"
CATCH "catch"
CHAR "char"
CLASS "class"
CONST "const"
C_CAST "c_cast"
CONTINUE "continue"
DEFAULT "default"
DELETE "delete"
DO "do"
DOUBLE "double"
D_CAST "d_cast"
ELSE "else"
ENUM "enum"
EXPLICIT "explicit"
EXTERN "extern"
FALSE "false"
FLOAT "float"
FOR "for"
FRIEND "friend"
GOTO "goto"
IF "if"
INLINE "inline"
INT "int"
LOG "log"
LONGLONG "long long"
LONGDOUBLE "long double"
LONG "long"
MUTABLE "mutable"
NAMESPACE "namespace"
NEW "new"
OPERATOR "operator"
PRIVATE "private"
PROTECTED "protected"
PUBLIC "public"
REGISTER "register"
R_CAST "r_cast"
RETURN "return"
SHORT "short"
SIGNED "signed"
SIZEOF "sizeof"
STATIC "static"
S_CAST "s_cast"
STRUCT "struct"
SWITCH "switch"
TEMPLATE "template"
THIS "this"
THROW "throw"
TRUE "true"
TRY "try"
TYPEDEF "typedef"
TYPEID "typeid"
TYPENAME "typename"
UNION "union"
UNSIGNED "unsigned"
USING "using"
VIRTUAL "virtual"
VOID "void"
VOLATILE "volatile"
WCHAR_T "wchar_t"
WHILE "while"

IDENTIFIER ({letter}|_)({letter}|{digit}|_)*

STRING \"[^"]*\"
CHARACTER \'[^']\'
%x COMMENT

%%
{comment} {print("comment");}

"/*"           { print("commentsBegin"); BEGIN(COMMENT); }
<COMMENT>{
"*/"           { print("\ncommentsEnd");BEGIN(INITIAL); }
.|\n           { dump_tokens("%s", yytext);current_column += strlen(yytext); }
}


{HEADFILE} {print("HEADFILE");}
{DEFINE} {print("DEFINE");}

{LB} {
    print("LB");
    scope_id++;
    scopes.push(scope_id);
}
{LP} {print("LP");}
{RB} {
    print("RB");
    if (!scopes.empty()) {
        scopes.pop();
    }
} 
{RP} {print("RP");} 
{PLUS} {checkPrint("PLUS");}
{MINUS} {checkPrint("MINUS");}
{MULT} {checkPrint("MULT");}
{BITAND} {checkPrint("BITAND");}
{DIV} {print("DIV");}
{MOD} {print("MOD");}
{PLUSA} {print("PLUSA");}
{MINUSA} {print("MINUSA");}
{MULA} {print("MULA");}
{DIVA} {print("DIVA");}
{MODA} {print("MODA");}
{LS} {print("LS");}
{RS} {print("RS");}
{LSA} {print("LSA");}
{RSA} {print("RSA");}
{NOT} {print("NOT");}
{BITOR} {print("BITOR");}
{XOR} {print("XOR");}
{COMPL} {print("COMPL");}
{AND} {print("AND");}
{OR} {print("OR");}
{BIT} {print("BIT");}
{LT} {print("LT");}
{LE} {print("LE");}
{GT} {print("GT");}
{GE} {print("GE");}
{EQ} {print("EQ");}
{NE} {print("NE");}
{ASSIGN} {print("ASSIGN");}
{DOT} {print("DOT");}
{MS} {print("MS");}
{LA} {print("LA");}
{RA} {print("RA");}
{UNARYPLUS} {print("UNARYPLUS");}
{UNARYMINUS} {print("UNARYMINUS");}
{DEREFERECE} {print("DEREFERECE");}
{ADDRESS} {print("ADDRESS");}
{COMMA} {print("COMMA");}
{SC} {print("SC");}
{ASM} {print("ASM");}
{AUTO} {print("AUTO");}
{BOOL} {print("BOOL");}
{BREAK} {print("BREAK");}
{CASE} {print("CASE");}
{CATCH} {print("CATCH");}
{CHAR} {print("CHAR");}
{CLASS} {print("CLASS");}
{CONST} {print("CONST");}
{C_CAST} {print("C_CAST");}
{CONTINUE} {print("CONTINUE");}
{DEFAULT} {print("DEFAULT");}
{DELETE} {print("DELETE");}
{DOUBLE} {print("DOUBLE");}
{D_CAST} {print("D_CAST");}
{ELSE} {print("ELSE");}
{ENUM} {print("ENUM");}
{EXPLICIT} {print("EXPLICIT");}
{EXTERN} {print("EXTERN");}
{FALSE} {print("FALSE");}
{FLOAT} {print("FLOAT");}
{FOR} {print("FOR");}
{FRIEND} {print("FRIEND");}
{GOTO} {print("GOTO");}
{IF} {print("IF");}
{INLINE} {print("INLINE");}
{INT} {print("INT");}
{LOG} {print("LOG");}
{LONG} {print("LONG");}
{MUTABLE} {print("MUTABLE");}
{NAMESPACE} {print("NAMESPACE");}
{NEW} {print("NEW");}
{OPERATOR} {print("OPERATOR");}
{PRIVATE} {print("PRIVATE");}
{PROTECTED} {print("PROTECTED");}
{PUBLIC} {print("PUBLIC");}
{REGISTER} {print("REGISTER");}
{R_CAST} {print("R_CAST");}
{RETURN} {print("RETURN");}
{SHORT} {print("SHORT");}
{SIGNED} {print("SIGNED");}
{SIZEOF} {print("SIZEOF");}
{STATIC} {print("STATIC");}
{S_CAST} {print("S_CAST");}
{STRUCT} {print("STRUCT");}
{SWITCH} {print("SWITCH");}
{TEMPLATE} {print("TEMPLATE");}
{THIS} {print("THIS");}
{THROW} {print("THROW");}
{TRUE} {print("TRUE");}
{TRY} {print("TRY");}
{TYPEDEF} {print("TYPEDEF");}
{TYPEID} {print("TYPEID");}
{TYPENAME} {print("TYPENAME");}
{UNION} {print("UNION");}
{UNSIGNED} {print("UNSIGNED");}
{USING} {print("USING");}
{VIRTUAL} {print("VIRTUAL");}
{VOID} {print("VOID");}
{VOLATILE} {print("VOLATILE");}
{WCHAR_T} {print("WCHAR_T");}
{WHILE} {print("WHILE");}
{DO} {print("DO");}
{LONGLONG} {print("LONGLONG");}
{LONGDOUBLE} {print("LONGDOUBLE");}

{decimal} {
    int decimal;
    decimal = atoi(yytext);
    dump_tokens("DECIMAL\t%s\t%d\t%d\t%d\n",yytext,current_line,current_column,decimal);
    current_column += strlen(yytext);
}

{hex} {
    int hex;
    sscanf(yytext,"%x",&hex);
    dump_tokens("HEX\t%s\t%d\t%d\t%d\n",yytext,current_line,current_column,hex);
    current_column += strlen(yytext);
}

{oct} {
    int oct;
    sscanf(yytext,"%o",&oct);
    dump_tokens("OCT\t%s\t%d\t%d\t%d\n",yytext,current_line,current_column,oct);
    current_column += strlen(yytext);
}

{FLOATING} {
    double float_val;
    sscanf(yytext, "%lf", &float_val);
    dump_tokens("FLOATING\t%s\t%d\t%d\t%f\n", yytext, current_line, current_column, float_val);
    current_column += strlen(yytext);
}

{HEXFLOATING} {
    double float_val = strtod(yytext, NULL);
    dump_tokens("HEXFLOATING\t%s\t%d\t%d\t%f\n", yytext, current_line, current_column, float_val);
    current_column += strlen(yytext);
}

{IDENTIFIER} {
    unsigned long address;
    std::string identifier(yytext);
    if (identifierMap.find(identifier) == identifierMap.end()) {
        // 如果标识符尚未在哈希表中，则添加
        address = (unsigned long)yytext;
        identifierMap[identifier] = address;
    } else {
        // 否则，使用已存储的哈希值
        address = identifierMap[identifier];
    }
    int currentScopeId = !scopes.empty() ? scopes.top() : 0;
    dump_tokens("%s\t%s\t%d\t%d\t%lu:%d\n","IDENTIFIER", yytext, current_line, current_column, address, currentScopeId);
    current_column += strlen(yytext);
}

{POSINC} {preAndPost("POSINC");}
{POSDEC} {preAndPost("POSDEC");}
{PREINC} {preAndPost("PREINC");}
{PREDEC} {preAndPost("PREDEC");}


{STRING} {print("STRING");}
{CHARACTER} {print("CHARACTER");}
{EOL} {    yylineno++;    current_line++;    current_column = 0;
}
{blank} {
    current_column++;
}
%%
/* user code section */

