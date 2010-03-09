%pure-parser
%parse-param { HB_MACRO_PTR pMacro }
%lex-param   { HB_MACRO_PTR pMacro }
%name-prefix = "hb_macro"

%{
/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Macro compiler YACC rules and actions
 *
 * Copyright 1999 Antonio Linares <alinares@fivetech.com>
 * www - http://www.harbour-project.org
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

/* TODO list
 * 1) Change the pcode generated by ::cVar from Self:cVar to QSELF():cVar
 *    The major problem to solve is how to support QSELF() inside a codeblock.
 */

/* this #define HAVE TO be placed before all #include directives
 */
#define  HB_MACRO_SUPPORT

#include "hbmacro.h"
#include "hbcomp.h"
#include "hbdate.h"
#include "hbpp.h"

/* Compile using: bison -d -p hb_comp macro.y */

/* to pacify some warnings in BCC */
#if defined( __BORLANDC__ ) && !defined( __STDC__ )
#  define __STDC__
#endif

#undef alloca
#define alloca  hb_xgrab
#undef malloc
#define malloc  hb_xgrab
#undef realloc
#define realloc hb_xrealloc
#undef free
#define free    hb_xfree

/* NOTE: these symbols are used internally in bison.simple
 */
#undef YYFREE
#define YYFREE hb_xfree
#undef YYMALLOC
#define YYMALLOC hb_xgrab

#define NO_YYERROR

/* NOTE: these symbols are defined explicitly to pacify warnings */
#define YYENABLE_NLS          0
#define YYLTYPE_IS_TRIVIAL    0


/* yacc/lex related definitions
 */


/* Standard checking for valid expression creation
 */
#define HB_MACRO_CHECK( pExpr ) \
   if( ! ( HB_MACRO_DATA->status & HB_MACRO_CONT ) ) \
   { \
      YYABORT; \
   }

#define HB_MACRO_IFENABLED( pSet, pExpr, flag ) \
   if( HB_MACRO_DATA->supported & (flag) ) \
   { \
      pSet = (pExpr); \
   }\
   else \
   { \
      YYABORT; \
   }

#if defined( __BORLANDC__ ) || defined( __WATCOMC__ )
/* The if() inside this macro is always TRUE but it's used to hide BCC warning */
#define HB_MACRO_ABORT if( !( HB_MACRO_DATA->status & HB_MACRO_CONT ) ) { YYABORT; }
#else
#define HB_MACRO_ABORT { YYABORT; }
#endif

%}

%union                  /* special structure used by lex and yacc to share info */
{
   const char * string; /* to hold a string returned by lex */
   int       iNumber;   /* to hold a temporary integer number */
   HB_MAXINT lNumber;   /* to hold a temporary long number */
   void *    pVoid;     /* to hold any memory structure we may need */
   HB_EXPR_PTR asExpr;
   struct
   {
      const char * string;
      int      length;
   } valChar;
   struct
   {
      int      iNumber; /* to hold a number returned by lex */
   } valInteger;
   struct
   {
      HB_MAXINT lNumber; /* to hold a long number returned by lex */
      HB_UCHAR  bWidth;  /* to hold the width of the value */
   } valLong;
   struct
   {
      double   dNumber; /* to hold a double number returned by lex */
      HB_UCHAR bWidth;  /* to hold the width of the value */
      HB_UCHAR bDec;    /* to hold the number of decimal points in the value */
   } valDouble;
   struct
   {
      long     date;    /* to hold julian date */
      long     time;    /* to hold milliseconds */
   } valTimeStamp;
};

%{
/* This must be placed after the above union - the union is
 * typedef-ined to YYSTYPE
 */
extern int  yylex( YYSTYPE *, HB_MACRO_PTR );   /* main lex token function, called by yyparse() */
extern int  yyparse( HB_MACRO_PTR );            /* main yacc parsing function */
extern void yyerror( HB_MACRO_PTR, const char * );    /* parsing error management function */

%}

%token IDENTIFIER NIL NUM_DOUBLE INASSIGN NUM_LONG NUM_DATE TIMESTAMP
%token IIF LITERAL TRUEVALUE FALSEVALUE
%token AND OR NOT EQ NE1 NE2 INC DEC ALIASOP HASHOP SELF
%token LE GE FIELD MACROVAR MACROTEXT
%token PLUSEQ MINUSEQ MULTEQ DIVEQ POWER EXPEQ MODEQ
%token EPSILON

/*the lowest precedence*/
/*postincrement and postdecrement*/
%left   POST
/*assigment - from right to left*/
%right  INASSIGN
%right  PLUSEQ MINUSEQ
%right  MULTEQ DIVEQ MODEQ
%right  EXPEQ
/*logical operators*/
%right  OR
%right  AND
%right  NOT
/*relational operators*/
%right '=' EQ NE1 NE2
%right '<' '>' LE GE '$'
/*mathematical operators*/
%right  '+' '-'
%right  '*' '/' '%'
%right  POWER
%right  UNARY
/*preincrement and predecrement*/
%right  PRE
/*special operators*/
%right  ALIASOP '&' '@'
%right  ','
/*the highest precedence*/

%type <string>    IDENTIFIER MACROVAR MACROTEXT
%type <valChar>   LITERAL
%type <valDouble> NUM_DOUBLE
%type <valLong>   NUM_LONG
%type <valLong>   NUM_DATE
%type <valTimeStamp> TIMESTAMP
%type <asExpr>  Argument ExtArgument RefArgument ArgList ElemList
%type <asExpr>  BlockExpList BlockVarList BlockVars
%type <asExpr>  NumValue NumAlias
%type <asExpr>  NilValue
%type <asExpr>  LiteralValue
%type <asExpr>  CodeBlock
%type <asExpr>  Logical
%type <asExpr>  SelfValue
%type <asExpr>  Array
%type <asExpr>  ArrayAt
%type <asExpr>  Hash HashList
%type <asExpr>  Variable VarAlias
%type <asExpr>  MacroVar MacroVarAlias
%type <asExpr>  MacroExpr MacroExprAlias
%type <asExpr>  AliasId AliasVar AliasExpr
%type <asExpr>  VariableAt
%type <asExpr>  FunCall FunRef
%type <asExpr>  SendId
%type <asExpr>  ObjectData
%type <asExpr>  ObjectMethod
%type <asExpr>  IfInline
%type <asExpr>  ExpList PareExpList PareExpListAlias AsParamList RootParamList
%type <asExpr>  Expression ExtExpression SimpleExpression LeftExpression
%type <asExpr>  EmptyExpression
%type <asExpr>  ExprAssign ExprOperEq ExprPreOp ExprPostOp
%type <asExpr>  ExprMath ExprBool ExprRelation ExprUnary
%type <asExpr>  ExprPlusEq ExprMinusEq ExprMultEq ExprDivEq ExprModEq ExprExpEq
%type <asExpr>  ArrayIndex IndexList
%type <asExpr>  FieldAlias FieldVarAlias
%type <asExpr>  PostOp
%type <asExpr>  DateValue TimeStampValue

%%

Main : Expression       {
                           HB_MACRO_DATA->exprType = hb_compExprType( $1 );
                           if( HB_MACRO_DATA->Flags &  HB_MACRO_GEN_REFER )
                              hb_macroExprGenPush( hb_compExprNewRef( $1, HB_COMP_PARAM ), HB_COMP_PARAM );
                           else if( HB_MACRO_DATA->Flags &  HB_MACRO_GEN_PUSH )
                              hb_macroExprGenPush( $1, HB_COMP_PARAM );
                           else
                              hb_macroExprGenPop( $1, HB_COMP_PARAM );
                           hb_macroGenPCode1( HB_P_ENDPROC, HB_COMP_PARAM );
                        }
     | AsParamList      {
                           HB_MACRO_DATA->exprType = hb_compExprType( $1 );
                           if( HB_MACRO_DATA->Flags &  HB_MACRO_GEN_PUSH )
                              hb_macroExprGenPush( $1, HB_COMP_PARAM );
                           else
                              hb_macroError( EG_SYNTAX, HB_COMP_PARAM );
                           hb_macroGenPCode1( HB_P_ENDPROC, HB_COMP_PARAM );
                        }
     | error   {
                  HB_TRACE(HB_TR_DEBUG, ("macro -> invalid syntax: %s", HB_MACRO_DATA->string));
                  hb_macroError( EG_SYNTAX, HB_COMP_PARAM );
                  HB_MACRO_ABORT;
               }
     ;

/* Numeric values
 */
NumValue   : NUM_DOUBLE       { $$ = hb_compExprNewDouble( $1.dNumber, $1.bWidth, $1.bDec, HB_COMP_PARAM ); }
           | NUM_LONG         { $$ = hb_compExprNewLong( $1.lNumber, HB_COMP_PARAM ); }
           ;

DateValue  : NUM_DATE         { $$ = hb_compExprNewDate( $1.lNumber, HB_COMP_PARAM ); }
           ;

TimeStampValue : TIMESTAMP    { $$ = hb_compExprNewTimeStamp( $1.date, $1.time, HB_COMP_PARAM ); }
               ;

NumAlias   : NUM_LONG ALIASOP { $$ = hb_compExprNewLong( $1.lNumber, HB_COMP_PARAM ); }
           ;

/* NIL value
 */
NilValue   : NIL              { $$ = hb_compExprNewNil( HB_COMP_PARAM ); }
           ;

/* Literal string value
 */
LiteralValue : LITERAL        { $$ = hb_compExprNewString( $1.string, $1.length, HB_FALSE, HB_COMP_PARAM ); }
             ;

/* Logical value
 */
Logical     : TRUEVALUE       { $$ = hb_compExprNewLogical( HB_TRUE, HB_COMP_PARAM ); }
            | FALSEVALUE      { $$ = hb_compExprNewLogical( HB_FALSE, HB_COMP_PARAM ); }
            ;

/* SELF value and expressions
 */
SelfValue   : SELF            { $$ = hb_compExprNewSelf( HB_COMP_PARAM ); }
            ;

/* Literal array
 */
Array       : '{' ElemList '}'      { $$ = hb_compExprNewArray( $2, HB_COMP_PARAM ); }
            ;

/* Literal array access
 */
ArrayAt     : Array ArrayIndex      { $$ = $2; }
            ;

/* Literal hash
 */
Hash        : '{' HASHOP '}'        { $$ = hb_compExprNewHash( NULL, HB_COMP_PARAM ); }
            | '{' HashList '}'      { $$ = hb_compExprNewHash( $2, HB_COMP_PARAM ); }
            ;

HashList    : Expression HASHOP EmptyExpression                { $$ = hb_compExprAddListExpr( hb_compExprNewList( $1, HB_COMP_PARAM ), $3 ); }
            | HashList ',' Expression HASHOP EmptyExpression   { $$ = hb_compExprAddListExpr( hb_compExprAddListExpr( $1, $3 ), $5 ); }
            ;


/* Variables
 */
Variable    : IDENTIFIER            { $$ = hb_compExprNewVar( $1, HB_COMP_PARAM ); }
            ;

VarAlias    : IDENTIFIER ALIASOP    { $$ = hb_compExprNewAlias( $1, HB_COMP_PARAM ); }
            ;

/* Macro variables - this can signal compilation errors
 */
MacroVar    : MACROVAR        {  $$ = hb_compExprNewMacro( NULL, '&', $1, HB_COMP_PARAM );
                                 HB_MACRO_CHECK( $$ );
                              }
            | MACROTEXT       {  HB_BOOL fNewString;
                                 char * szVarName = hb_macroTextSymbol( $1, strlen( $1 ), &fNewString );
                                 if( szVarName )
                                 {
                                    if( fNewString )
                                       hb_macroIdentNew( HB_COMP_PARAM, szVarName );
                                    $$ = hb_compExprNewVar( szVarName, HB_COMP_PARAM );
                                    HB_MACRO_CHECK( $$ );
                                 }
                                 else
                                 {
                                    /* invalid variable name
                                     */
                                    HB_TRACE(HB_TR_DEBUG, ("macro -> invalid variable name: %s", $1));
                                    YYABORT;
                                 }
                              }
            ;

MacroVarAlias  : MacroVar ALIASOP   { hb_compExprMacroAsAlias( $1 ); }
               ;

/* Macro expressions
 */
MacroExpr  : '&' PareExpList        { $$ = hb_compExprNewMacro( $2, 0, NULL, HB_COMP_PARAM ); }
           ;

MacroExprAlias : MacroExpr ALIASOP
               ;

/* Aliased variables
 */
/* special case: _FIELD-> and FIELD-> can be nested
 */
FieldAlias  : FIELD ALIASOP               { $$ = hb_compExprNewAlias( "FIELD", HB_COMP_PARAM ); }
            | FIELD ALIASOP FieldAlias    { $$ = $3; }
            ;

/* ignore _FIELD-> or FIELD-> if a real alias is specified
 */
FieldVarAlias  : FieldAlias VarAlias            { $$ = $2; }
               | FieldAlias NumAlias            { $$ = $2; }
               | FieldAlias PareExpListAlias    { $$ = $2; }
               | FieldAlias MacroVarAlias       { $$ = $2; }
               | FieldAlias MacroExprAlias      { $$ = $2; }
               ;

AliasId     : IDENTIFIER      { $$ = hb_compExprNewVar( $1, HB_COMP_PARAM ); }
            | MacroVar
            ;

AliasVar   : NumAlias AliasId          { $$ = hb_compExprNewAliasVar( $1, $2, HB_COMP_PARAM ); }
           | MacroVarAlias AliasId     { $$ = hb_compExprNewAliasVar( $1, $2, HB_COMP_PARAM ); }
           | MacroExprAlias AliasId    { $$ = hb_compExprNewAliasVar( $1, $2, HB_COMP_PARAM ); }
           | PareExpListAlias AliasId  { $$ = hb_compExprNewAliasVar( $1, $2, HB_COMP_PARAM ); }
           | VarAlias AliasId          { $$ = hb_compExprNewAliasVar( $1, $2, HB_COMP_PARAM ); }
           | FieldAlias AliasId        { $$ = hb_compExprNewAliasVar( $1, $2, HB_COMP_PARAM ); }
           | FieldVarAlias AliasId     { $$ = hb_compExprNewAliasVar( $1, $2, HB_COMP_PARAM ); }
           ;

/* Aliased expressions
 */
/* NOTE: In the case:
 * alias->( Expression )
 * alias always selects a workarea at runtime
 */
AliasExpr  : NumAlias PareExpList         { $$ = hb_compExprNewAliasExpr( $1, $2, HB_COMP_PARAM ); }
           | VarAlias PareExpList         { $$ = hb_compExprNewAliasExpr( $1, $2, HB_COMP_PARAM ); }
           | MacroVarAlias PareExpList    { $$ = hb_compExprNewAliasExpr( $1, $2, HB_COMP_PARAM ); }
           | MacroExprAlias PareExpList   { $$ = hb_compExprNewAliasExpr( $1, $2, HB_COMP_PARAM ); }
           | PareExpListAlias PareExpList { $$ = hb_compExprNewAliasExpr( $1, $2, HB_COMP_PARAM ); }
           ;

/* Array expressions access
 */
VariableAt  : NumValue        ArrayIndex  { $$ = $2; }
            | NilValue        ArrayIndex  { $$ = $2; }
            | DateValue       ArrayIndex  { $$ = $2; }
            | TimeStampValue  ArrayIndex  { $$ = $2; }
            | LiteralValue    ArrayIndex  { $$ = $2; }
            | CodeBlock       ArrayIndex  { $$ = $2; }
            | Logical         ArrayIndex  { $$ = $2; }
            | Hash            ArrayIndex  { $$ = $2; }
            | SelfValue       ArrayIndex  { $$ = $2; }
            | Variable        ArrayIndex  { $$ = $2; }
            | AliasVar        ArrayIndex  { $$ = $2; }
            | AliasExpr       ArrayIndex  { $$ = $2; }
            | MacroVar        ArrayIndex  { $$ = $2; }
            | MacroExpr       ArrayIndex  { $$ = $2; }
            | ObjectData      ArrayIndex  { $$ = $2; }
            | ObjectMethod    ArrayIndex  { $$ = $2; }
            | FunCall         ArrayIndex  { $$ = $2; }
            | IfInline        ArrayIndex  { $$ = $2; }
            | PareExpList     ArrayIndex  { $$ = $2; }
            ;

/* Function call
 */
FunCall     : IDENTIFIER '(' ArgList ')'  { $$ = hb_macroExprNewFunCall( hb_compExprNewFunName( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM );
                                            HB_MACRO_CHECK( $$ );
                                          }
            | MacroVar '(' ArgList ')'    { $$ = hb_macroExprNewFunCall( $1, $3, HB_COMP_PARAM );
                                            HB_MACRO_CHECK( $$ );
                                          }
            ;

FunRef      : '@' IDENTIFIER '(' ArgList ')' {  if( hb_compExprParamListLen( $4 ) != 0 )
                                                {
                                                   hb_macroError( EG_SYNTAX, HB_COMP_PARAM );
                                                   YYABORT;
                                                }
                                                else
                                                   $$ = hb_compExprNewFunRef( $2, HB_COMP_PARAM );
                                             }
            ;

ArgList     : ExtArgument                 { $$ = hb_compExprNewArgList( $1, HB_COMP_PARAM ); }
            | ArgList ',' ExtArgument     { $$ = hb_compExprAddListExpr( $1, $3 ); }
            ;

Argument    : EmptyExpression
            | RefArgument
            ;

RefArgument : '@' IDENTIFIER              { $$ = hb_compExprNewVarRef( $2, HB_COMP_PARAM ); }
            | '@' MacroVar                { $$ = hb_compExprNewRef( $2, HB_COMP_PARAM ); }
            | '@' AliasVar                { $$ = hb_compExprNewRef( $2, HB_COMP_PARAM ); }
            | '@' ObjectData              { $$ = hb_compExprNewRef( $2, HB_COMP_PARAM ); }
            | '@' VariableAt              { $$ = $2; $$->value.asList.reference = HB_TRUE; }
            ;

ExtArgument : EPSILON  { $$ = hb_compExprNewArgRef( HB_COMP_PARAM ); }
            | Argument
            ;

/* Object's instance variable
 */
ObjectData  : LeftExpression ':' SendId   { $$ = hb_compExprNewMethodObject( $3, $1 ); }
            ;

SendId      : IDENTIFIER     { $$ = hb_compExprNewSend( $1, HB_COMP_PARAM ); }
            | MacroVar       { $$ = hb_compExprNewMacroSend( $1, HB_COMP_PARAM ); }
            | MacroExpr      { $$ = hb_compExprNewMacroSend( $1, HB_COMP_PARAM ); }
            ;

/* Object's method
 */
ObjectMethod : ObjectData '(' ArgList ')'    { $$ = hb_compExprNewMethodCall( $1, $3 ); }
             ;

SimpleExpression :
              NumValue
            | NilValue
            | DateValue
            | TimeStampValue
            | LiteralValue
            | CodeBlock
            | Logical
            | SelfValue
            | Array
            | ArrayAt
            | Hash
            | AliasVar
            | AliasExpr
            | MacroVar
            | MacroExpr
            | Variable
            | VariableAt
            | FunCall
            | IfInline
            | ObjectData
            | ObjectMethod
            | ExprAssign
            | ExprOperEq            { HB_MACRO_IFENABLED( $$, $1, HB_SM_HARBOUR ); }
            | ExprPostOp            { HB_MACRO_IFENABLED( $$, $1, HB_SM_HARBOUR ); }
            | ExprPreOp             { HB_MACRO_IFENABLED( $$, $1, HB_SM_HARBOUR ); }
            | ExprUnary
            | ExprMath
            | ExprBool
            | ExprRelation
            | FunRef
            ;

Expression  : SimpleExpression      { $$ = $1; HB_MACRO_CHECK( $$ ); }
            | PareExpList           { $$ = $1; HB_MACRO_CHECK( $$ ); }
            ;

ExtExpression : EPSILON             { $$ = hb_compExprNewArgRef( HB_COMP_PARAM ); }
              | Expression
              ;

RootParamList : EmptyExpression ',' {
                                       if( !(HB_MACRO_DATA->Flags & HB_MACRO_GEN_LIST) )
                                       {
                                          HB_TRACE(HB_TR_DEBUG, ("macro -> invalid expression: %s", HB_MACRO_DATA->string));
                                          hb_macroError( EG_SYNTAX, HB_COMP_PARAM );
                                          YYABORT;
                                       }
                                    }
                EmptyExpression     {
                                       HB_MACRO_DATA->uiListElements = 1;
                                       $$ = hb_compExprAddListExpr( ( HB_MACRO_DATA->Flags & HB_MACRO_GEN_PARE ) ? hb_compExprNewList( $1, HB_COMP_PARAM ) : hb_compExprNewArgList( $1, HB_COMP_PARAM ), $4 );
                                    }
              ;

AsParamList : RootParamList
            | AsParamList ',' EmptyExpression   { HB_MACRO_DATA->uiListElements++;
                                                  $$ = hb_compExprAddListExpr( $1, $3 ); }
            ;

EmptyExpression: /* nothing => nil */        { $$ = hb_compExprNewEmpty( HB_COMP_PARAM ); }
            | Expression
            ;

LeftExpression : NumValue
               | NilValue
               | DateValue
               | TimeStampValue
               | LiteralValue
               | CodeBlock
               | Logical
               | SelfValue
               | Array
               | ArrayAt
               | Hash
               | AliasVar
               | AliasExpr
               | MacroVar
               | MacroExpr
               | Variable
               | VariableAt
               | PareExpList
               | FunCall
               | IfInline
               | ObjectData         { HB_MACRO_IFENABLED( $$, $1, HB_SM_HARBOUR ); }
               | ObjectMethod
               ;

/* NOTE: PostOp can be used in one context only - it uses $0 rule
 *    (the rule that stands before PostOp)
 */
PostOp      : INC    { $$ = hb_compExprNewPostInc( $<asExpr>0, HB_COMP_PARAM ); }
            | DEC    { $$ = hb_compExprNewPostDec( $<asExpr>0, HB_COMP_PARAM ); }
            ;

/* NOTE: We cannot use 'Expression PostOp' because it caused
 * shift/reduce conflicts
 */
ExprPostOp  : LeftExpression PostOp %prec POST  { $$ = $2; }
            ;

ExprPreOp   : INC Expression  %prec PRE      { $$ = hb_compExprNewPreInc( $2, HB_COMP_PARAM ); }
            | DEC Expression  %prec PRE      { $$ = hb_compExprNewPreDec( $2, HB_COMP_PARAM ); }
            ;

ExprUnary   : NOT Expression                 { $$ = hb_compExprNewNot( $2, HB_COMP_PARAM ); }
            | '-' Expression  %prec UNARY    { $$ = hb_compExprNewNegate( $2, HB_COMP_PARAM ); }
            | '+' Expression  %prec UNARY    { $$ = $2; }
            ;

ExprAssign  : LeftExpression INASSIGN Expression { $$ = hb_compExprAssign( $1, $3, HB_COMP_PARAM ); }
            ;

ExprPlusEq  : LeftExpression PLUSEQ   Expression { $$ = hb_compExprSetOperand( hb_compExprNewPlusEq( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            ;

ExprMinusEq : LeftExpression MINUSEQ  Expression { $$ = hb_compExprSetOperand( hb_compExprNewMinusEq( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            ;

ExprMultEq  : LeftExpression MULTEQ   Expression { $$ = hb_compExprSetOperand( hb_compExprNewMultEq( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            ;

ExprDivEq   : LeftExpression DIVEQ    Expression { $$ = hb_compExprSetOperand( hb_compExprNewDivEq( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            ;

ExprModEq   : LeftExpression MODEQ    Expression { $$ = hb_compExprSetOperand( hb_compExprNewModEq( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            ;

ExprExpEq   : LeftExpression EXPEQ    Expression { $$ = hb_compExprSetOperand( hb_compExprNewExpEq( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            ;

ExprOperEq  : ExprPlusEq
            | ExprMinusEq
            | ExprMultEq
            | ExprDivEq
            | ExprModEq
            | ExprExpEq
            ;

ExprMath    : Expression '+' Expression     { $$ = hb_compExprSetOperand( hb_compExprNewPlus( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression '-' Expression     { $$ = hb_compExprSetOperand( hb_compExprNewMinus( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression '*' Expression     { $$ = hb_compExprSetOperand( hb_compExprNewMult( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression '/' Expression     { $$ = hb_compExprSetOperand( hb_compExprNewDiv( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression '%' Expression     { $$ = hb_compExprSetOperand( hb_compExprNewMod( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression POWER Expression   { $$ = hb_compExprSetOperand( hb_compExprNewPower( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            ;

ExprBool    : Expression AND Expression   { $$ = hb_compExprSetOperand( hb_compExprNewAnd( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression OR  Expression   { $$ = hb_compExprSetOperand( hb_compExprNewOr( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            ;

ExprRelation: Expression EQ  Expression   { $$ = hb_compExprSetOperand( hb_compExprNewEQ( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression '<' Expression   { $$ = hb_compExprSetOperand( hb_compExprNewLT( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression '>' Expression   { $$ = hb_compExprSetOperand( hb_compExprNewGT( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression LE  Expression   { $$ = hb_compExprSetOperand( hb_compExprNewLE( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression GE  Expression   { $$ = hb_compExprSetOperand( hb_compExprNewGE( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression NE1 Expression   { $$ = hb_compExprSetOperand( hb_compExprNewNE( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression NE2 Expression   { $$ = hb_compExprSetOperand( hb_compExprNewNE( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression '$' Expression   { $$ = hb_compExprSetOperand( hb_compExprNewIN( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            | Expression '=' Expression   { $$ = hb_compExprSetOperand( hb_compExprNewEqual( $1, HB_COMP_PARAM ), $3, HB_COMP_PARAM ); }
            ;

ArrayIndex  : IndexList ']'
            ;

/* NOTE: $0 represents the expression before ArrayIndex
 *    Don't use ArrayIndex in other context than as an array index!
 */
IndexList   : '[' ExtExpression                 { $$ = hb_macroExprNewArrayAt( $<asExpr>0, $2, HB_COMP_PARAM ); }
            | IndexList ',' ExtExpression       { $$ = hb_macroExprNewArrayAt( $1, $3, HB_COMP_PARAM ); }
            | IndexList ']' '[' ExtExpression   { $$ = hb_macroExprNewArrayAt( $1, $4, HB_COMP_PARAM ); }
            ;

ElemList    : ExtArgument              { $$ = hb_compExprNewList( $1, HB_COMP_PARAM ); }
            | ElemList ',' ExtArgument { $$ = hb_compExprAddListExpr( $1, $3 ); }
            ;

CodeBlock   : '{' '|'
                  { $<asExpr>$ = hb_compExprNewCodeBlock( NULL, 0, 0, HB_COMP_PARAM ); }
               BlockVars '|' BlockExpList '}'
                  { $$ = $<asExpr>3; }
            ;

/* NOTE: This uses $-2 then don't use BlockExpList in other context
 */
BlockExpList: Expression                  { $$ = hb_compExprAddCodeblockExpr( $<asExpr>-2, $1 ); }
            | BlockExpList ',' Expression { $$ = hb_compExprAddCodeblockExpr( $<asExpr>-2, $3 ); }
            ;

/* NOTE: This uses $0 then don't use BlockVars and BlockVarList in other context
 */
BlockVars   : /* empty list */            { $$ = NULL; }
            | EPSILON                     { $$ = NULL; $<asExpr>0->value.asCodeblock.flags |= HB_BLOCK_VPARAMS; }
            | BlockVarList                { $$ = $1;   }
            | BlockVarList ',' EPSILON    { $$ = $1;   $<asExpr>0->value.asCodeblock.flags |= HB_BLOCK_VPARAMS; }
            ;

BlockVarList: IDENTIFIER                  { $$ = hb_compExprCBVarAdd( $<asExpr>0, $1, ' ', HB_COMP_PARAM ); }
            | BlockVarList ',' IDENTIFIER { $$ = hb_compExprCBVarAdd( $<asExpr>0, $3, ' ', HB_COMP_PARAM ); HB_MACRO_CHECK( $$ ); }
            ;

ExpList     : '(' EmptyExpression          { $$ = hb_compExprNewList( $2, HB_COMP_PARAM ); }
            | ExpList ',' EmptyExpression  { $$ = hb_compExprAddListExpr( $1, $3 ); }
            ;

PareExpList : ExpList ')'
            ;

PareExpListAlias : PareExpList ALIASOP
                 ;

/* Lexer should return IIF for "if" symbol */
IfInline    : IIF '(' Expression ',' Argument ',' Argument ')'
               { $$ = hb_compExprNewIIF( hb_compExprAddListExpr( hb_compExprAddListExpr( hb_compExprNewList( $3, HB_COMP_PARAM ), $5 ), $7 ) ); }
            ;

%%


/*
 ** ------------------------------------------------------------------------ **
 */

void yyerror( HB_MACRO_PTR pMacro, const char * s )
{
   HB_SYMBOL_UNUSED( pMacro );
   HB_SYMBOL_UNUSED( s );
}

/* ************************************************************************* */

#define HB_MEXPR_PREALLOC 8

typedef struct HB_MEXPR_
{
   int      count;
   HB_EXPR  Expressions[ HB_MEXPR_PREALLOC ];
   struct HB_MEXPR_ *pPrev;
}
HB_MEXPR, * HB_MEXPR_PTR;

typedef struct HB_MIDENT_
{
   char * Identifier;
   struct HB_MIDENT_ *pPrev;
}
HB_MIDENT, * HB_MIDENT_PTR;

/* Allocates memory for Expression holder structure and stores it
 * on the linked list
*/
static HB_EXPR_PTR hb_macroExprAlloc( HB_COMP_DECL )
{
   HB_MEXPR_PTR pMExpr = ( HB_MEXPR_PTR ) HB_MACRO_DATA->pExprLst;

   if( !pMExpr || pMExpr->count >= HB_MEXPR_PREALLOC )
   {
      pMExpr = ( HB_MEXPR_PTR ) hb_xgrab( sizeof( HB_MEXPR ) );
      pMExpr->pPrev = ( HB_MEXPR_PTR ) HB_MACRO_DATA->pExprLst;
      pMExpr->count = 0;
      HB_MACRO_DATA->pExprLst = ( void * ) pMExpr;
   }
   return &pMExpr->Expressions[ pMExpr->count++ ];
}

char * hb_macroIdentNew( HB_COMP_DECL, char * szIdent )
{
   HB_MIDENT_PTR pMIdent = ( HB_MIDENT_PTR ) hb_xgrab( sizeof( HB_MIDENT ) );
   pMIdent->Identifier = szIdent;
   pMIdent->pPrev = ( HB_MIDENT_PTR ) HB_MACRO_DATA->pIdentLst;
   HB_MACRO_DATA->pIdentLst = ( void * ) pMIdent;

   return szIdent;
}

static HB_EXPR_PTR hb_macroExprNew( HB_COMP_DECL, HB_EXPRTYPE iType )
{
   HB_EXPR_PTR pExpr;

   HB_TRACE(HB_TR_DEBUG, ("hb_macroExprNew(%p,%i)", HB_COMP_PARAM, iType));

   pExpr = hb_macroExprAlloc( HB_COMP_PARAM );
   pExpr->ExprType = iType;
   pExpr->pNext    = NULL;
   pExpr->ValType  = HB_EV_UNKNOWN;

   return pExpr;
}

/* Delete self - all components will be deleted somewhere else
 */
static void hb_macroExprClear( HB_COMP_DECL, HB_EXPR_PTR pExpr )
{
   HB_SYMBOL_UNUSED( HB_COMP_PARAM );

   pExpr->ExprType = HB_ET_NONE;
}

/* Delete all components and delete self
 */
static void hb_macroExprFree( HB_COMP_DECL, HB_EXPR_PTR pExpr )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_macroExprFree()"));

   HB_EXPR_USE( pExpr, HB_EA_DELETE );
   pExpr->ExprType = HB_ET_NONE;
}

/* Deallocate all memory used by expression optimizer */
static void hb_macroLstFree( HB_MACRO_PTR pMacro )
{
   if( pMacro->pExprLst )
   {
      HB_MEXPR_PTR pMExpr = ( HB_MEXPR_PTR ) pMacro->pExprLst;
      do
      {
         while( pMExpr->count )
            hb_macroExprFree( pMacro, &pMExpr->Expressions[ --pMExpr->count ] );
         pMExpr = pMExpr->pPrev;
      }
      while( pMExpr );
      do
      {
         pMExpr = ( HB_MEXPR_PTR ) pMacro->pExprLst;
         pMacro->pExprLst = ( void * ) pMExpr->pPrev;
         hb_xfree( pMExpr );
      }
      while( pMacro->pExprLst );
   }

   while( pMacro->pIdentLst )
   {
      HB_MIDENT_PTR pMIdent = ( HB_MIDENT_PTR ) HB_MACRO_DATA->pIdentLst;
      HB_MACRO_DATA->pIdentLst = ( void * ) pMIdent->pPrev;
      hb_xfree( pMIdent->Identifier );
      hb_xfree( pMIdent );
   }
}

static HB_EXPR_PTR hb_macroErrorType( HB_COMP_DECL, HB_EXPR_PTR pExpr )
{
   hb_macroError( EG_ARG, HB_COMP_PARAM );
   return pExpr;
}

static HB_EXPR_PTR hb_macroErrorSyntax( HB_COMP_DECL, HB_EXPR_PTR pExpr )
{
   hb_macroError( EG_SYNTAX, HB_COMP_PARAM );
   return pExpr;
}

static void hb_macroErrorDuplVar( HB_COMP_DECL, const char * szVarName )
{
   HB_SYMBOL_UNUSED( szVarName );
   hb_macroError( EG_SYNTAX, HB_COMP_PARAM );
}


static const HB_COMP_FUNCS s_macro_funcs =
{
   hb_macroExprNew,
   hb_macroExprClear,
   hb_macroExprFree,

   hb_macroErrorType,
   hb_macroErrorSyntax,
   hb_macroErrorDuplVar,
};

int hb_macroYYParse( HB_MACRO_PTR pMacro )
{
   int iResult;

   pMacro->funcs = &s_macro_funcs;

   if( hb_macroLexNew( pMacro ) )
   {
      pMacro->status = HB_MACRO_CONT;
      pMacro->pExprLst = NULL;
      pMacro->pIdentLst = NULL;

      iResult = yyparse( pMacro );

      hb_macroLstFree( pMacro );
      hb_macroLexDelete( pMacro );
   }
   else
      iResult = HB_MACRO_FAILURE;

   return iResult;
}


#if defined( HB_MACRO_PPLEX )

/* it's an example of PP token translator which change tokens generated by
   PP into terminal symbols used by our grammar parser generated by Bison */
HB_BOOL hb_macroLexNew( HB_MACRO_PTR pMacro )
{
   pMacro->pLex = ( void * ) hb_pp_lexNew( pMacro->string, pMacro->length );
   return pMacro->pLex != NULL;
}

void hb_macroLexDelete( HB_MACRO_PTR pMacro )
{
   if( pMacro->pLex )
   {
      hb_pp_free( ( PHB_PP_STATE ) pMacro->pLex );
      pMacro->pLex = NULL;
   }
}

int hb_macrolex( YYSTYPE *yylval_ptr, HB_MACRO_PTR pMacro )
{
   PHB_PP_TOKEN pToken = hb_pp_lexGet( ( PHB_PP_STATE ) pMacro->pLex );

   if( !pToken )
      return 0;

   switch( HB_PP_TOKEN_TYPE( pToken->type ) )
   {
      case HB_PP_TOKEN_KEYWORD:
         if( pToken->len >= 4 && pToken->len <= 6 && pToken->pNext &&
             HB_PP_TOKEN_TYPE( pToken->pNext->type ) == HB_PP_TOKEN_ALIAS &&
             ( hb_strnicmp( "_FIELD", pToken->value, pToken->len ) == 0 ||
               hb_strnicmp( "FIELD", pToken->value, pToken->len ) == 0 ) )
         {
            return FIELD;
         }
         else if( pToken->len == 3 && pToken->pNext &&
                  HB_PP_TOKEN_TYPE( pToken->pNext->type ) == HB_PP_TOKEN_LEFT_PB &&
                  hb_stricmp( "IIF", pToken->value ) == 0 )
         {
            return IIF;
         }
         else if( pToken->len == 2 && pToken->pNext &&
                  HB_PP_TOKEN_TYPE( pToken->pNext->type ) == HB_PP_TOKEN_LEFT_PB &&
                  hb_stricmp( "IF", pToken->value ) == 0 )
            return IIF;
         else if( pToken->len == 3 && hb_stricmp( "NIL", pToken->value ) == 0 )
            return NIL;

         hb_pp_tokenUpper( pToken );
         yylval_ptr->string = pToken->value;
         return IDENTIFIER;

      case HB_PP_TOKEN_MACROVAR:
         hb_pp_tokenUpper( pToken );
         yylval_ptr->string = pToken->value;
         return MACROVAR;

      case HB_PP_TOKEN_MACROTEXT:
         hb_pp_tokenUpper( pToken );
         yylval_ptr->string = pToken->value;
         return MACROTEXT;

      case HB_PP_TOKEN_NUMBER:
      {
         HB_MAXINT lNumber;
         double dNumber;
         int iDec, iWidth;

         if( hb_compStrToNum( pToken->value, pToken->len, &lNumber, &dNumber, &iDec, &iWidth ) )
         {
            yylval_ptr->valDouble.dNumber = dNumber;
            yylval_ptr->valDouble.bDec    = ( HB_UCHAR ) iDec;
            yylval_ptr->valDouble.bWidth  = ( HB_UCHAR ) iWidth;
            return NUM_DOUBLE;
         }
         else
         {
            yylval_ptr->valLong.lNumber = lNumber;
            yylval_ptr->valLong.bWidth  = ( HB_UCHAR ) iWidth;
            return NUM_LONG;
         }
      }
      case HB_PP_TOKEN_DATE:
         if( pToken->len == 10 )
         {
            int year, month, day;
            hb_dateStrGet( pToken->value + 2, &year, &month, &day );
            yylval_ptr->valLong.lNumber = hb_dateEncode( year, month, day );
         }
         else
            yylval_ptr->valLong.lNumber = 0;
         return NUM_DATE;

      case HB_PP_TOKEN_TIMESTAMP:
         if( !hb_timeStampStrGetDT( pToken->value,
                                    &yylval_ptr->valTimeStamp.date,
                                    &yylval_ptr->valTimeStamp.time ) )
         {
            hb_macroError( EG_SYNTAX, pMacro );
         }
         return TIMESTAMP;

      case HB_PP_TOKEN_STRING:
         yylval_ptr->valChar.string = pToken->value;
         yylval_ptr->valChar.length = pToken->len;
         return LITERAL;

      case HB_PP_TOKEN_LOGICAL:
         return pToken->value[ 1 ] == 'T' ? TRUEVALUE : FALSEVALUE;

      case HB_PP_TOKEN_HASH:
      case HB_PP_TOKEN_DIRECTIVE:
         return NE1;

      case HB_PP_TOKEN_NE:
         return NE2;

      case HB_PP_TOKEN_ASSIGN:
         return INASSIGN;

      case HB_PP_TOKEN_EQUAL:
         return EQ;

      case HB_PP_TOKEN_INC:
         return INC;

      case HB_PP_TOKEN_DEC:
         return DEC;

      case HB_PP_TOKEN_ALIAS:
         return ALIASOP;

      case HB_PP_TOKEN_LE:
         return LE;

      case HB_PP_TOKEN_GE:
         return GE;

      case HB_PP_TOKEN_PLUSEQ:
         return PLUSEQ;

      case HB_PP_TOKEN_MINUSEQ:
         return MINUSEQ;

      case HB_PP_TOKEN_MULTEQ:
         return MULTEQ;

      case HB_PP_TOKEN_DIVEQ:
         return DIVEQ;

      case HB_PP_TOKEN_MODEQ:
         return MODEQ;

      case HB_PP_TOKEN_EXPEQ:
         return EXPEQ;

      case HB_PP_TOKEN_POWER:
         return POWER;

      case HB_PP_TOKEN_AND:
         return AND;

      case HB_PP_TOKEN_OR:
         return OR;

      case HB_PP_TOKEN_NOT:
         return NOT;

      default:
         return pToken->value[ 0 ];
   }
}

#endif /* HB_MACRO_PPLEX */
