/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * 
 *
 * Copyright 2006 Przemyslaw Czerpak <druzus / at / priv.onet.pl>
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

#ifndef HB_PP_H_
#define HB_PP_H_

#include "hbapi.h"
#include "hbapifs.h"
#include "hbver.h"

HB_EXTERN_BEGIN

/* #pragma {__text,__stream,__cstream}|functionOut|functionEnd|functionStart */
#define HB_PP_STREAM_OFF      0 /* standard preprocessing */
#define HB_PP_STREAM_COMMENT  1 /* multiline comment */
#define HB_PP_STREAM_DUMP_C   2 /* pragma BEGINDUMP */
#define HB_PP_STREAM_CLIPPER  3 /* clipper compatible TEXT/ENDTEXT */
#define HB_PP_STREAM_PRG      4 /* TEXT/ENDTEXT lines joined with LF */
#define HB_PP_STREAM_C        5 /* TEXT/ENDTEXT lines joined and ESC seq processed */
#define HB_PP_STREAM_INLINE_C 6 /* hb_inLIne() {...} data, should not be preprocessed */

/* hb_inLine() states */
#define HB_PP_INLINE_OFF      0
#define HB_PP_INLINE_START    1
#define HB_PP_INLINE_PARAM    2
#define HB_PP_INLINE_BODY     3
#define HB_PP_INLINE_COMMENT  4
#define HB_PP_INLINE_QUOTE1   5
#define HB_PP_INLINE_QUOTE2   6

/* function to open included files */
#define HB_PP_OPEN_FUNC_( func ) FILE * func( char *, BOOL, char * )
typedef HB_PP_OPEN_FUNC_( HB_PP_OPEN_FUNC );
typedef HB_PP_OPEN_FUNC * PHB_PP_OPEN_FUNC;

/* function to close included files */
#define HB_PP_CLOSE_FUNC_( func ) void func( FILE * )
typedef HB_PP_CLOSE_FUNC_( HB_PP_CLOSE_FUNC );
typedef HB_PP_CLOSE_FUNC * PHB_PP_CLOSE_FUNC;

/* function to generate errors */
#define HB_PP_ERROR_FUNC_( func ) void func( char **, char, int, const char *, const char * )
typedef HB_PP_ERROR_FUNC_( HB_PP_ERROR_FUNC );
typedef HB_PP_ERROR_FUNC * PHB_PP_ERROR_FUNC;

/* function to redirect stdout messages */
#define HB_PP_DISP_FUNC_( func ) void func( const char * )
typedef HB_PP_DISP_FUNC_( HB_PP_DISP_FUNC );
typedef HB_PP_DISP_FUNC * PHB_PP_DISP_FUNC;

/* function for catching #pragma dump data */
#define HB_PP_DUMP_FUNC_( func ) void func( char *, ULONG, int )
typedef HB_PP_DUMP_FUNC_( HB_PP_DUMP_FUNC );
typedef HB_PP_DUMP_FUNC * PHB_PP_DUMP_FUNC;

/* function for catching #pragma dump data */
#define HB_PP_INLINE_FUNC_( func ) void func( char *, char *, ULONG, int )
typedef HB_PP_INLINE_FUNC_( HB_PP_INLINE_FUNC );
typedef HB_PP_INLINE_FUNC * PHB_PP_INLINE_FUNC;

/* function for catching #pragma dump data */
#define HB_PP_SWITCH_FUNC_( func ) BOOL func( const char *, int )
typedef HB_PP_SWITCH_FUNC_( HB_PP_SWITCH_FUNC );
typedef HB_PP_SWITCH_FUNC * PHB_PP_SWITCH_FUNC;


#ifdef _HB_PP_INTERNAL

/* default maximum number of translations */
#define HB_PP_MAX_CYCLES      4096
/* maximum number of single token translations, in Clipper it's 18 + number
   of used rules, we will use also constant but increased by total number
   of rules of given type: define, [x]translate, [x]command */
#define HB_PP_MAX_REPATS      128

/* Clipper allows only 16 nested includes */
#define HB_PP_MAX_INCLUDED_FILES    64


/* comparision modes */
#define HB_PP_CMP_ADDR        0 /* compare token addresses */
#define HB_PP_CMP_STD         1 /* standard comparison, ignore the case of the characters */
#define HB_PP_CMP_DBASE       2 /* dbase keyword comparison (accepts at least four character shortcuts) ignore the case of the characters */
#define HB_PP_CMP_CASE        3 /* case sensitive comparison */

#define HB_PP_CMP_MODE(t)     ( (t) & 0xff )
#define HB_PP_STD_RULE        0x8000


/* conditional compilation */
#define HB_PP_COND_ELSE       1     /* preprocessing and output stopped until corresponding #else */
#define HB_PP_COND_DISABLE    2     /* preprocessing and output stopped until corresponding #endif(s) */

/* operation precedence for #if calculation */
#define HB_PP_PREC_NUL  0
#define HB_PP_PREC_NOT  1
#define HB_PP_PREC_LOG  2
#define HB_PP_PREC_REL  3
#define HB_PP_PREC_BIT  4
#define HB_PP_PREC_PLUS 5
#define HB_PP_PREC_MULT 6
#define HB_PP_PREC_NEG  7


/* preprocessor tokens */
#define HB_PP_TOKEN_NUL          0

#define HB_PP_MMARKER_REGULAR    1
#define HB_PP_MMARKER_LIST       2
#define HB_PP_MMARKER_RESTRICT   3
#define HB_PP_MMARKER_WILD       4
#define HB_PP_MMARKER_EXTEXP     5
#define HB_PP_MMARKER_NAME       6
#define HB_PP_MMARKER_OPTIONAL   7

#define HB_PP_RMARKER_REGULAR    11
#define HB_PP_RMARKER_STRDUMP    12
#define HB_PP_RMARKER_STRSTD     13
#define HB_PP_RMARKER_STRSMART   14
#define HB_PP_RMARKER_BLOCK      15
#define HB_PP_RMARKER_LOGICAL    16
#define HB_PP_RMARKER_NUL        17
#define HB_PP_RMARKER_OPTIONAL   18

/* keywords, pseudo keywords and PP only tokens */
#define HB_PP_TOKEN_KEYWORD      21
#define HB_PP_TOKEN_MACRO        22
#define HB_PP_TOKEN_TEXT         23
#define HB_PP_TOKEN_OTHER        24   /* non keyword, text, or operator character */
#define HB_PP_TOKEN_BACKSLASH    25   /* "\\" */
#define HB_PP_TOKEN_PIPE         26   /* "|" */
#define HB_PP_TOKEN_DOT          27   /* "." */
#define HB_PP_TOKEN_COMMA        28   /* "," */
#define HB_PP_TOKEN_EOC          29   /* ";" */
#define HB_PP_TOKEN_EOL          30   /* "\n" */
#define HB_PP_TOKEN_HASH         31   /* "\n" */
#define HB_PP_TOKEN_DIRECTIVE    32   /* direct # directive first token */

/* constant values */
#define HB_PP_TOKEN_STRING       41
#define HB_PP_TOKEN_NUMBER       42
#define HB_PP_TOKEN_DATE         43
#define HB_PP_TOKEN_LOGICAL      44

/* operators */
#define HB_PP_TOKEN_LEFT_PB      50
#define HB_PP_TOKEN_RIGHT_PB     51
#define HB_PP_TOKEN_LEFT_SB      52
#define HB_PP_TOKEN_RIGHT_SB     53
#define HB_PP_TOKEN_LEFT_CB      54
#define HB_PP_TOKEN_RIGHT_CB     55
#define HB_PP_TOKEN_REFERENCE    56
#define HB_PP_TOKEN_AMPERSAND    57
#define HB_PP_TOKEN_SEND         58
#define HB_PP_TOKEN_ALIAS        59

#define HB_PP_TOKEN_ASSIGN       60
#define HB_PP_TOKEN_PLUSEQ       61
#define HB_PP_TOKEN_MINUSEQ      62
#define HB_PP_TOKEN_MULTEQ       63
#define HB_PP_TOKEN_DIVEQ        64
#define HB_PP_TOKEN_MODEQ        65
#define HB_PP_TOKEN_EXPEQ        66

#define HB_PP_TOKEN_INC          67
#define HB_PP_TOKEN_DEC          68
#define HB_PP_TOKEN_NOT          69
#define HB_PP_TOKEN_OR           70
#define HB_PP_TOKEN_AND          71
#define HB_PP_TOKEN_EQUAL        72
#define HB_PP_TOKEN_EQ           73
#define HB_PP_TOKEN_LT           74
#define HB_PP_TOKEN_GT           75
#define HB_PP_TOKEN_LE           76
#define HB_PP_TOKEN_GE           77
#define HB_PP_TOKEN_NE           78
#define HB_PP_TOKEN_IN           79
#define HB_PP_TOKEN_PLUS         80
#define HB_PP_TOKEN_MINUS        81
#define HB_PP_TOKEN_MULT         82
#define HB_PP_TOKEN_DIV          83
#define HB_PP_TOKEN_MOD          84
#define HB_PP_TOKEN_POWER        85


/* bitfields */
//#define HB_PP_TOKEN_UNARY        0x0100
//#define HB_PP_TOKEN_BINARY       0x0200
//#define HB_PP_TOKEN_JOINABLE     0x0400
#define HB_PP_TOKEN_MATCHMARKER  0x2000
#define HB_PP_TOKEN_STATIC       0x4000
#define HB_PP_TOKEN_PREDEFINED   0x8000

#define HB_PP_TOKEN_SETTYPE(t,n) do{ (t)->type = ( (t)->type & 0xff00 ) | (n); } while(0)

#define HB_PP_TOKEN_TYPE(t)      ( (t) & 0xff )
#define HB_PP_TOKEN_ALLOC(t)     ( ( (t) & HB_PP_TOKEN_STATIC ) == 0 )
#define HB_PP_TOKEN_ISPREDEF(t)  ( ( (t)->type & HB_PP_TOKEN_PREDEFINED ) != 0 )

/* These macros are very important for the PP behavior. They define what
   and how will be translated. Their default definitions are not strictly
   Clipper compatible to allow programmer using indirect # directive
         EOL - end of line    => '\n' or NULL
         EOC - end of command => EOL or ';'
         EOS - end of subst   => EOL or ';' + '#'
         EOP - end of pattern => EOL for direct and EOC for indirect
 */

/* End Of Line */
#define HB_PP_TOKEN_ISEOL(t)     ( (t) == NULL || \
                                   HB_PP_TOKEN_TYPE((t)->type) == HB_PP_TOKEN_EOL )
/* End Of Command */
#define HB_PP_TOKEN_ISEOC(t)     ( HB_PP_TOKEN_ISEOL(t) || \
                                   HB_PP_TOKEN_TYPE((t)->type) == HB_PP_TOKEN_EOC )

#ifdef HB_C52_STRICT
#  define HB_PP_TOKEN_ISEOS(t)   HB_PP_TOKEN_ISEOL(t)
#  define HB_PP_TOKEN_ISEOP(t,l) HB_PP_TOKEN_ISEOL(t)
#else
/* End Of Subst - define how mant tokens in line should be translated,
                  Clipper translate whole line */
#  define HB_PP_TOKEN_ISEOS(t)   ( HB_PP_TOKEN_ISEOL(t) || \
                                   ( HB_PP_TOKEN_TYPE((t)->type) == HB_PP_TOKEN_EOC && \
                                     (t)->pNext && \
                                     ( HB_PP_TOKEN_TYPE((t)->pNext->type) == HB_PP_TOKEN_HASH || \
                                       HB_PP_TOKEN_TYPE((t)->pNext->type) == HB_PP_TOKEN_DIRECTIVE ) ) )
/* End Of Pattern - the second paramter define if it's direct or indirect
                    pattern */
#  define HB_PP_TOKEN_ISEOP(t,l) ( (l) ? HB_PP_TOKEN_ISEOL(t) : HB_PP_TOKEN_ISEOC(t) )
#endif

#define HB_PP_TOKEN_ISDIRECTIVE(t)  ( HB_PP_TOKEN_TYPE((t)->type) == HB_PP_TOKEN_DIRECTIVE || \
                                      HB_PP_TOKEN_TYPE((t)->type) == HB_PP_TOKEN_HASH )

#define HB_PP_TOKEN_CANJOIN(t)   ( ! HB_PP_TOKEN_CLOSE_BR(t) && \
                                   HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_KEYWORD && \
                                   HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_MACRO && \
                                   HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_TEXT && \
                                   HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_STRING && \
                                   HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_NUMBER && \
                                   HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_DATE && \
                                   HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_LOGICAL )

#define HB_PP_TOKEN_OPEN_BR(t)   ( HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_LEFT_PB || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_LEFT_SB || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_LEFT_CB )

#define HB_PP_TOKEN_CLOSE_BR(t)  ( HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_RIGHT_PB || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_RIGHT_SB || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_RIGHT_CB )

#define HB_PP_TOKEN_NEEDLEFT(t)  ( HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_ASSIGN || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_PLUSEQ || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_MINUSEQ || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_MULTEQ || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_DIVEQ || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_MODEQ || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_EXPEQ || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_EQUAL || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_EQ )

#define HB_PP_TOKEN_ISNEUTRAL(t) ( HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_DEC || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_INC )

/* I do not want to replicate exactly Clipper PP behavior and check if
   expression is valid.
   it's wrong and causes that potentially valid expressions are not
   properly parsed, f.e:
      ? 1 + + 2
   does not work when
      qout( 1 + + 2 )
   perfectly does.
   It this difference will be reason of some problems then please inform me
   with a code example so I'll be able if it should be implemented or not.
   Now I simply disabled HB_PP_TOKEN_NEEDRIGHT() macro.
 */
#ifndef HB_C52_STRICT
#define HB_PP_TOKEN_NEEDRIGHT(t) ( FALSE )
#else
#define HB_PP_TOKEN_NEEDRIGHT(t) ( HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_PLUS || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_MINUS || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_MULT || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_DIV || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_MOD || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_POWER )
#endif

#ifdef HB_C52_STRICT
#  define HB_PP_TOKEN_ISUNARY(t) ( HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_MINUS || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_DEC || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_INC || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_AMPERSAND )
#else
#  define HB_PP_TOKEN_ISUNARY(t) ( HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_MINUS || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_DEC || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_INC || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_AMPERSAND || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_PLUS || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_NOT || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_REFERENCE )
#endif

#define HB_PP_TOKEN_ISMATCH(t)   ( (t) && ( (t)->type & HB_PP_TOKEN_MATCHMARKER ) != 0 )

#if 0
#define HB_PP_TOKEN_ISRESULT(t)  ( HB_PP_TOKEN_TYPE(t) == HB_PP_RMARKER_REGULAR || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_RMARKER_STRDUMP || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_RMARKER_STRSTD || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_RMARKER_STRSMART || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_RMARKER_BLOCK || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_RMARKER_LOGICAL || \
                                   HB_PP_TOKEN_TYPE(t) == HB_PP_RMARKER_NUL )
#endif

#define HB_PP_TOKEN_ISEXPVAL(t)     ( HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_KEYWORD || \
                                      HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_MACRO || \
                                      HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_STRING || \
                                      HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_NUMBER || \
                                      HB_PP_TOKEN_TYPE(t) == HB_PP_TOKEN_DATE )
#define HB_PP_TOKEN_ISEXPTOKEN(t)   ( HB_PP_TOKEN_ISEXPVAL( (t)->type ) || \
                                      ( (t)->pNext && HB_PP_TOKEN_ISUNARY( (t)->type ) && \
                                        HB_PP_TOKEN_ISEXPVAL( (t)->pNext->type ) ) )

#ifdef HB_C52_STRICT
/* Clipper supports quoting by [] for 1-st token in the line so we 
   are checking for HB_PP_TOKEN_NUL in this macro */
#define HB_PP_TOKEN_CANQUOTE(t)     ( HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_NUL && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_KEYWORD && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_MACRO && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_RIGHT_PB && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_RIGHT_SB && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_RIGHT_CB )
#else
/* Disable string quoting by [] for next token if current one is
   constant value - it's not Clipper compatible but we need it for
   accessing string characters by array index operator or introduce
   similar extensions in the future */
#define HB_PP_TOKEN_CANQUOTE(t)     ( HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_NUL && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_KEYWORD && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_MACRO && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_RIGHT_PB && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_RIGHT_SB && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_RIGHT_CB && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_STRING && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_NUMBER && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_DATE && \
                                      HB_PP_TOKEN_TYPE(t) != HB_PP_TOKEN_LOGICAL )
#endif
/* For platforms which does not use ASCII based character tables this macros
   have to be changed to use valid C functions, f.e.:
      isalpha(), isdigit(), ... */
#ifdef HB_C52_STRICT
#  define HB_PP_ISILLEGAL(c)     ( (c) < 32 || (c) >= 126 )
#else
#  define HB_PP_ISILLEGAL(c)     ( (c) < 32 || (c) == 127 )
#endif
#define HB_PP_ISTEXTCHAR(c)      ( (unsigned char) (c) >= 128 )
#define HB_PP_ISBLANK(c)         ( (c) == ' ' || (c) == '\t' )
#define HB_PP_ISDIGIT(c)         ( (c) >= '0' && (c) <= '9' )
#define HB_PP_ISHEX(c)           ( HB_PP_ISDIGIT(c) || \
                                   ( (c) >= 'A' && (c) <= 'F' ) || \
                                   ( (c) >= 'a' && (c) <= 'f' ) )
#define HB_PP_ISTRUE(c)          ( (c) == 'T' || (c) == 't' || \
                                   (c) == 'Y' || (c) == 'y' )
#define HB_PP_ISFALSE(c)         ( (c) == 'F' || (c) == 'f' || \
                                   (c) == 'N' || (c) == 'n' )
#define HB_PP_ISFIRSTIDCHAR(c)   ( ( (c) >= 'A' && (c) <= 'Z' ) || \
                                   ( (c) >= 'a' && (c) <= 'z' ) || (c) == '_' )
#define HB_PP_ISNEXTIDCHAR(c)    ( HB_PP_ISFIRSTIDCHAR(c) || HB_PP_ISDIGIT(c) )

typedef struct _HB_PP_TOKEN
{
   struct _HB_PP_TOKEN * pNext;     /* next token pointer */
   struct _HB_PP_TOKEN * pMTokens;  /* restrict or optional marker token(s) */

   char * value;                    /* token value */
   USHORT len;                      /* token value length */
   USHORT spaces;                   /* leading spaces for stringify */
   USHORT type;                     /* token type, see HB_PP_TOKEN_* */
   USHORT index;                    /* index to match marker or 0 */
}
HB_PP_TOKEN, * PHB_PP_TOKEN;

typedef struct _HB_PP_RESULT
{
   struct _HB_PP_RESULT * pNext;
   PHB_PP_TOKEN   pFirstToken;
   PHB_PP_TOKEN   pNextExpr;
}
HB_PP_RESULT, * PHB_PP_RESULT;

typedef struct _HB_PP_MARKERPTR
{
   struct _HB_PP_MARKERPTR * pNext;
   PHB_PP_TOKEN   pToken;
   PHB_PP_TOKEN   pMTokens;
   USHORT         type;
}
HB_PP_MARKERPTR, * PHB_PP_MARKERPTR;

typedef struct _HB_PP_MARKERLST
{
   struct _HB_PP_MARKERLST * pNext;
   PHB_PP_MARKERPTR  pMatchMarkers;
   USHORT            canrepeat;
   USHORT            index;
}
HB_PP_MARKERLST, * PHB_PP_MARKERLST;

typedef struct
{
   USHORT   canrepeat;
   /* filled when pattern matches for substitution, cleared after */
   USHORT   matches;
   PHB_PP_RESULT  pResult;
}
HB_PP_MARKER, * PHB_PP_MARKER;

typedef struct _HB_PP_RULE
{
   struct _HB_PP_RULE * pPrev;      /* previous rule */
   PHB_PP_TOKEN   pMatch;           /* match patern or NULL */
   PHB_PP_TOKEN   pResult;          /* result patern or NULL */
   USHORT         mode;             /* comparison mode HB_PP_CMP_* */
   USHORT         markers;          /* number of markers in marker table */
   /* filled when pattern matches for substitution, cleared after */
   PHB_PP_MARKER  pMarkers;         /* marker table */
   PHB_PP_TOKEN   pNextExpr;        /* next expression after match pattern */
}
HB_PP_RULE, * PHB_PP_RULE;

typedef struct _HB_PP_DEFRULE
{
   PHB_PP_TOKEN   pMatch;
   PHB_PP_TOKEN   pResult;
   USHORT         mode;
   USHORT         markers;
   ULONG          repeatbits;
}
HB_PP_DEFRULE, * PHB_PP_DEFRULE;

typedef struct
{
   char *   name;       /* input name */
   ULONG    len;        /* input name length */
   char *   value;      /* output name */
   USHORT   type;       /* HB_PP_TOKEN_* */
}
HB_PP_OPERATOR, * PHB_PP_OPERATOR;

typedef struct
{
   char *   pBufPtr;
   ULONG    ulLen;
   ULONG    ulAllocated;
}
HB_MEM_BUFFER, * PHB_MEM_BUFFER;

typedef struct _HB_PP_FILE
{
   char *   szFileName;          /* input file name */
   FILE *   file_in;             /* input file handle */
   PHB_PP_TOKEN pTokenList;      /* current line decoded to tokens */
   int      iCurrentLine;        /* current line in file */
   int      iLastLine;           /* last non empty generated line */
   int      iLastDisp;           /* last shown line number */
   int      iTokens;             /* number of decoded tokens */
   BOOL     fGenLineInfo;        /* #line information should be generated */
   BOOL     fEof;                /* the end of file reached */

   char *   pLineBuf;            /* buffer for parsing external lines */
   ULONG    ulLineBufLen;        /* size of external line buffer */

   struct _HB_PP_FILE * pPrev;   /* previous file, the one which included this file */
}
HB_PP_FILE, * PHB_PP_FILE;

typedef struct
{
   /* common for all included files */
   PHB_PP_OPERATOR pOperators;   /* user defined operators */
   PHB_PP_RULE    pDefinitions;  /* #define table */
   PHB_PP_RULE    pTranslations; /* #[x]translate table */
   PHB_PP_RULE    pCommands;     /* #[x]command table */
   int            iOperators;    /* number of user defined operators */
   int            iDefinitions;  /* number of rules in pDefinitions */
   int            iTranslations; /* number of rules in pTranslations */
   int            iCommands;     /* number of rules in pCommands */

   PHB_PP_TOKEN   pTokenOut;     /* preprocessed tokens */
   PHB_PP_TOKEN * pNextTokenPtr; /* pointer to the last NULL pointer in token list */

   PHB_MEM_BUFFER pDumpBuffer;   /* buffer for dump output */
   PHB_MEM_BUFFER pOutputBuffer; /* buffer for preprocessed line */

   int      iCycle;              /* translation counter */
   int      iMaxCycles;          /* maximum number of translations */
   int      iHideStrings;        /* hidden string mode */
   BOOL     fTracePragmas;       /* display information about set pragmas */
   BOOL     fWritePreprocesed;   /* write preprocessed data to file (.ppo) */

   HB_PATHNAMES * pIncludePath;  /* search path(s) for included files */

   char *   szOutFileName;       /* output file name */
   FILE *   file_out;            /* output file handle */

   BOOL     fError;              /* error during preprocessing */
   BOOL     fQuiet;              /* do not show standard information */
   int      iCondCompile;        /* current conditional compilation flag, when not 0 disable preprocessing and output */
   int      iCondCount;          /* number of nested #if[n]def directive */
   int      iCondStackSize;      /* size of conditional compilation stack */
   int *    pCondStack;          /* conditional compilation stack */
   FILE *   file_in;             /* file handle */

   /* used to divide line per tokens and tokens manipulations */
   PHB_MEM_BUFFER pBuffer;       /* buffer for input and output line */
   int      iSpaces;             /* leading spaces for next token */
   int      iSpacesNL;           /* leading spaces ';' token (fCanNextLine) if it will not be line concatenator */
   int      iLastType;           /* last token type */
   BOOL     fCanNextLine;        /* ';' token found and we do not know yet if it's command separator or line concatenator */
   BOOL     fDirective;          /* # directives is parsed */
   BOOL     fNewStatement;       /* set to TRUE at line begining or after each ';' token */
   PHB_PP_TOKEN   pFuncOut;      /* function used for each line in HB_PP_STREAM_* dumping */
   PHB_PP_TOKEN   pFuncEnd;      /* end function for HB_PP_STREAM_* dumping */
   PHB_MEM_BUFFER pStreamBuffer; /* buffer for stream output */
   int      iStreamDump;         /* stream output, see HB_PP_STREAM_* */
   int      iDumpLine;           /* line where current dump output begins */
   int      iInLineCount;        /* number of hb_inLine() functions */
   int      iInLineState;        /* hb_inLine() state */
   int      iInLineBraces;       /* braces counter for hb_inLine() */

   PHB_PP_FILE pFile;            /* currently preprocessed file structure */
   int      iFiles;              /* number of open files */

   PHB_PP_OPEN_FUNC  pOpenFunc;  /* function to open files */
   PHB_PP_CLOSE_FUNC pCloseFunc; /* function to close files */
   PHB_PP_ERROR_FUNC pErrorFunc; /* function to generate errors */
   PHB_PP_DISP_FUNC  pDispFunc;  /* function to redirect stdout messages */
   PHB_PP_DUMP_FUNC  pDumpFunc;  /* function for catching #pragma dump data */
   PHB_PP_INLINE_FUNC pInLineFunc; /* function for hb_inLine(...) {...} blocks */
   PHB_PP_SWITCH_FUNC pSwitchFunc; /* function for compiler switches with #pragma ... */
}
HB_PP_STATE, * PHB_PP_STATE;

extern void hb_pp_initRules( PHB_PP_RULE * pRulesPtr, int * piRules,
                             const HB_PP_DEFRULE pDefRules[], int iDefRules );

extern void hb_pp_initStaticRules( PHB_PP_STATE pState );

#else

typedef void * PHB_PP_STATE;

#endif /* _HB_PP_INTERNAL */

/* public functions */
extern PHB_PP_STATE hb_pp_new( void );
extern void   hb_pp_init( PHB_PP_STATE pState, char * szFileName, BOOL fQuiet,
                          PHB_PP_OPEN_FUNC  pOpenFunc,  PHB_PP_CLOSE_FUNC pCloseFunc,
                          PHB_PP_ERROR_FUNC pErrorFunc, PHB_PP_DISP_FUNC  pDispFunc,
                          PHB_PP_DUMP_FUNC  pDumpFunc,  PHB_PP_INLINE_FUNC pInLineFunc,
                          PHB_PP_SWITCH_FUNC pSwitchFunc );
extern void   hb_pp_free( PHB_PP_STATE pState );
extern void   hb_pp_reset( PHB_PP_STATE pState );
extern void   hb_pp_setStdBase( PHB_PP_STATE pState );
extern void   hb_pp_setStream( PHB_PP_STATE pState, int iMode );
extern void   hb_pp_addSearchPath( PHB_PP_STATE pState, const char * szPath, BOOL fReplace );
extern void   hb_pp_inFile( PHB_PP_STATE pState, char * szFileName, FILE * file_in );
extern void   hb_pp_outFile( PHB_PP_STATE pState, char * szOutFileName, FILE * file_out );
extern char * hb_pp_fileName( PHB_PP_STATE pState );
extern int    hb_pp_line( PHB_PP_STATE pState );
extern char * hb_pp_outFileName( PHB_PP_STATE pState );
extern char * hb_pp_nextLine( PHB_PP_STATE pState, ULONG * pulLen );
extern char * hb_pp_parseLine( PHB_PP_STATE pState, char * pLine, ULONG * pulLen );
extern void   hb_pp_addDefine( PHB_PP_STATE pState, char * szDefName, char * szDefValue );
extern void   hb_pp_delDefine( PHB_PP_STATE pState, char * szDefName );

HB_EXTERN_END

#endif /* HB_PP_H_ */
