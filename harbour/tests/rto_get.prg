/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Regression tests for class Get
 *
 * Copyright 1999-2007 Viktor Szakats <viktor.szakats@syenar.hu>
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

/* NOTE: This source can be compiled with both Harbour and CA-Cl*pper. */

#include "common.ch"
#include "error.ch"
#include "fileio.ch"

#ifndef __HARBOUR__
   #define hb_OSNewLine() ( Chr( 13 ) + Chr( 10 ) )
#endif

#translate TEST_LINE( <x> ) => TEST_CALL( o, #<x>, {|| <x> } )

STATIC s_cTest := ""
STATIC s_xVar := NIL
STATIC s_fhnd
STATIC s_lCallBackStack
STATIC s_lRTEDetails
STATIC s_lObjectDump

FUNCTION Main( cArg01, cArg02, cArg03, cArg04 )
   LOCAL uNIL := NIL
   LOCAL nInt01 := 98
   LOCAL cStr01 := "AbC DF 974"
   LOCAL cStr02E := ""
   LOCAL dDate01

   LOCAL bOldBlock
   LOCAL o

   LOCAL cCommandLine

   DEFAULT cArg01 TO ""
   DEFAULT cArg02 TO ""
   DEFAULT cArg03 TO ""
   DEFAULT cArg04 TO ""

   SET DATE ANSI

   // ;

   cCommandLine := cArg01 + " " + cArg02 + " " + cArg03 + " " + cArg04

   s_lCallBackStack := "CALLBACKSTACK" $ Upper( cCommandLine )
   s_lRTEDetails := "RTEDETAILS" $ Upper( cCommandLine )
   s_lObjectDump := "ODUMP" $ Upper( cCommandLine )

   // ;

   #ifdef __HARBOUR__
      s_fhnd := FCreate( "tget_hb.txt", FC_NORMAL )
   #else
      s_fhnd := FCreate( "tget_cl5.txt", FC_NORMAL )
   #endif

   IF s_fhnd == F_ERROR
      RETURN 1
   ENDIF

   FWrite( s_fhnd, Set( _SET_DATEFORMAT ) + hb_OSNewLine() )

   // ; Delimiter handling.

   SetColor( "B/N, RB/N" )

   Set( _SET_DELIMITERS, .T. )

   Set( _SET_DELIMCHARS, "<>" )
   o := GetNew( 14, 16, { | x | iif( x == NIL, cStr01, cStr01 := x ) }, "cStr01",, "W+/N,BG/N" )
   TEST_LINE( o:display() )
   Set( _SET_DELIMCHARS, "()" )
   TEST_LINE( o:display() )
   Set( _SET_DELIMITERS, .F. )
   TEST_LINE( o:display() )
   Set( _SET_DELIMITERS, .T. )
   TEST_LINE( o:display() )
   TEST_LINE( o:display() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:display() )
   TEST_LINE( o:KillFocus() )
   TEST_LINE( o:display() )
   TEST_LINE( SetColor( "G+/N, RB/N" ) )
   TEST_LINE( o:display() )
   Set( _SET_DELIMITERS, .F. )
   Set( _SET_DELIMCHARS, "<>" )
   TEST_LINE( o:display() )
   TEST_LINE( o:Col := 30 )
   TEST_LINE( o:display() )

   Set( _SET_DELIMCHARS, "::" )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" )
   TEST_LINE( o:display() )
   TEST_LINE( o:Col := 20 )

   Set( _SET_DELIMITERS, .F. )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" )
   TEST_LINE( o:display() )

   SetColor( "" )

   // ; colorDisp / VarPut / display (::nDispLen recalc)

   SetPos( 14, 16 ) ; o := _GET_( uNIL, "uNIL" )
   TEST_LINE( o:colorDisp( "GR/N" ) )
   TEST_LINE( o:VarPut( "<hello>" ) )
   TEST_LINE( o:display() )

   SetPos( 14, 16 ) ; o := _GET_( uNIL, "uNIL" )
   TEST_LINE( o:colorSpec := "GR/N" )
   TEST_LINE( o:VarPut( "<hello>" ) )
   TEST_LINE( o:display() )

   // ; Minus

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999.99",, )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Minus := .T. )
   TEST_LINE( o:Minus := .F. )

   // ; Picture

   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01", "9999999999",, )
   TEST_LINE( o:Picture := "99" )
   TEST_LINE( o:Picture := "!!" )
   TEST_LINE( o:Picture := NIL )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Picture := "99" )
   TEST_LINE( o:Picture := "!!" )
   TEST_LINE( o:Picture := NIL )

   // ; Assign

   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01", "9999999999",, )
   o:SetFocus()
   TEST_LINE( o:OverStrike( "z" ) )
   TEST_LINE( o:Assign() )

   // ; Buffer

   s_xVar := "abcdefg"
   SetPos( 14, 16 ) ; o := _GET_( s_xVar, "s_xVar",,, )
   TEST_LINE( o:buffer := "1234567" )
   TEST_LINE( o:buffer := "abcdefg" )

   s_xVar := "abcdefg"
   SetPos( 14, 16 ) ; o := _GET_( s_xVar, "s_xVar",,, )
   o:SetFocus()
   TEST_LINE( o:buffer := "1234567" )
   TEST_LINE( o:buffer := "abcdefg" )

   // ; Clear

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999.99",, )
   TEST_LINE( o:Clear := .T. )
   TEST_LINE( o:Clear := .F. )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Clear := .T. )
   TEST_LINE( o:Clear := .F. )

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999.99",, )
   TEST_LINE( o:Clear := .T. )
   TEST_LINE( o:Clear := .F. )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Clear := .F. )
   TEST_LINE( o:Clear := .T. )

   // ; Minus

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999.99",, )
   TEST_LINE( o:Minus := .T. )
   TEST_LINE( o:Minus := .F. )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Minus := .T. )
   TEST_LINE( o:Minus := .F. )

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999.99",, )
   TEST_LINE( o:Minus := .F. )
   TEST_LINE( o:Minus := .T. )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Minus := .F. )
   TEST_LINE( o:Minus := .T. )

   // ; Changed

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999.99",, )
   TEST_LINE( o:Changed := .T. )
   TEST_LINE( o:Changed := .F. )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Changed := .T. )
   TEST_LINE( o:Changed := .F. )

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999.99",, )
   TEST_LINE( o:Changed := .F. )
   TEST_LINE( o:Changed := .T. )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Changed := .F. )
   TEST_LINE( o:Changed := .T. )

   // ; ColorSpec

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01",,, )
   o:ColorSpec := "BG/RB,BG/RB" ; TEST_LINE( o:ColorSpec := "" )
   o:ColorSpec := "BG/RB,BG/RB" ; TEST_LINE( o:ColorSpec := ",N/G" )
   o:ColorSpec := "BG/RB,BG/RB" ; TEST_LINE( o:ColorSpec := "N/G" )
   o:ColorSpec := "BG/RB,BG/RB" ; TEST_LINE( o:ColorSpec := "," )
   o:ColorSpec := "BG/RB,BG/RB" ; TEST_LINE( o:ColorSpec := "N/G,N/N" )
   o:ColorSpec := "BG/RB,BG/RB" ; TEST_LINE( o:ColorSpec := "N/G,N /N" )
   o:ColorSpec := "BG/RB,BG/RB" ; TEST_LINE( o:ColorSpec := "N/G,N/ N" )
   o:ColorSpec := "BG/RB,BG/RB" ; TEST_LINE( o:ColorSpec := "N/G, N/N" )
   o:ColorSpec := "BG/RB,BG/RB" ; TEST_LINE( o:ColorSpec := "N/G, N/N " )
   o:ColorSpec := "BG/RB,BG/RB" ; TEST_LINE( o:ColorSpec := "N/G,hkjhkj" )
   o:ColorSpec := "BG/RB,BG/RB" ; TEST_LINE( o:ColorSpec := "n/g,n/bg" )

   // ; Pos

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999.99",, )
   o:SetFocus()
   TEST_LINE( o:Pos := 5 )
   TEST_LINE( o:ToDecPos() )

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999.",, )
   o:SetFocus()
   TEST_LINE( o:Pos := 5 )
   TEST_LINE( o:ToDecPos() )

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999",, )
   o:SetFocus()
   TEST_LINE( o:Pos := 5 )
   TEST_LINE( o:ToDecPos() )
   TEST_LINE( o:Pos := 0 )

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999",, )
   o:SetFocus()
   TEST_LINE( o:Pos := 10 )

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01", "9999",, )
   o:SetFocus()
   TEST_LINE( o:Pos := 0 )

   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01", "9999--9999",, )
   o:SetFocus()
   TEST_LINE( o:Pos := 5 )
   TEST_LINE( o:Pos := 6 )

   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01", "9999------",, )
   o:SetFocus()
   TEST_LINE( o:Pos := 5 )
   TEST_LINE( o:Pos := 6 )

   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01", "----------",, )
   o:SetFocus()
   TEST_LINE( o:Pos := 5 )
   TEST_LINE( o:Pos := 6 )

   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01", "9999999999",, )
   o:SetFocus()
   TEST_LINE( o:Pos := 11 )

   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01", "9999999999",, )
   o:SetFocus()
// TEST_LINE( o:Pos := -2 )

   SetPos( 14, 16 ) ; o := _GET_( cStr02E, "cStr02E",,, )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Pos := 1 )

   // ; Error conditions

   TGetAssign( NIL )
// TGetAssign( -1 ) // ; CA-Cl*pper has too many differences due to the low level implementation here
   TGetAssign( 0 )
   TGetAssign( 1 )
   TGetAssign( 3 )
   TGetAssign( 100 )
   TGetAssign( "" )
   TGetAssign( "az" )
   TGetAssign( hb_SToD( "20070425" ) )
   TGetAssign( .F. )
   TGetAssign( .T. )
   TGetAssign( {|| NIL } )
   TGetAssign( {} )
   TGetAssign( { "" } )

   // ; Type change N -> C

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" )
   TEST_LINE( OBJ_CREATE() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:KillFocus() )
   TEST_LINE( o:block := {| h | LogMe( h ), iif( h == NIL, cStr01, cStr01 := h ) } )
   TEST_LINE( o:SetFocus() )

   // ; Reform

   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" )
   TEST_LINE( OBJ_CREATE() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:picture := "!!!!!!!!" )
   TEST_LINE( o:Reform() )
   TEST_LINE( o:KillFocus() )
   TEST_LINE( o:picture := "!!!!AAAA" )
   TEST_LINE( o:Reform() )

   // ; Minus

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" )
   TEST_LINE( OBJ_CREATE() )
   bOldBlock := o:block
   TEST_LINE( o:block := {| h | LogMe( h ), iif( h == NIL, Eval( bOldBlock ), Eval( bOldBlock, h ) ) } )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:insert("-") )
   TEST_LINE( o:KillFocus() )
   TEST_LINE( o:SetFocus() )
   o:minus := .T.
   TEST_LINE( o:SetFocus() )

   // ;

   SET CENTURY ON

   SetPos( 14, 16 ) ; dDate01 := hb_SToD( "20070425" )
   o := _GET_( dDate01, "dDate01" )
   TEST_LINE( OBJ_CREATE() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:OverStrike("12345678") )
   TEST_LINE( o:KillFocus() )

   SetPos( 14, 16 ) ; dDate01 := hb_SToD( "20070425" )
   o := _GET_( dDate01, "dDate01", "@E" )
   TEST_LINE( OBJ_CREATE() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:OverStrike("12345678") )
   TEST_LINE( o:KillFocus() )

   SET CENTURY OFF

   SetPos( 14, 16 ) ; dDate01 := hb_SToD( "20070425" )
   o := _GET_( dDate01, "dDate01" )
   TEST_LINE( OBJ_CREATE() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:OverStrike("12345678") )
   TEST_LINE( o:KillFocus() )

   SetPos( 14, 16 ) ; dDate01 := hb_SToD( "20070425" )
   o := _GET_( dDate01, "dDate01", "@E" )
   TEST_LINE( OBJ_CREATE() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:OverStrike("12345678") )
   TEST_LINE( o:KillFocus() )

   SetPos( 14, 16 ) ; cStr01 := "hello world"
   o := _GET_( cStr01, "cStr01", "!!LY!!!!!!" )
   TEST_LINE( OBJ_CREATE() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:OverStrike("12345678") )
   TEST_LINE( o:KillFocus() )

   SetPos( 14, 16 ) ; cStr01 := "hello world"
   o := _GET_( cStr01, "cStr01", "!!!.!!!!!!" )
   TEST_LINE( OBJ_CREATE() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:OverStrike("12345678") )
   TEST_LINE( o:KillFocus() )

   SetPos( 14, 16 ) ; cStr01 := "hello world"
   o := _GET_( cStr01, "cStr01", "@R !!LY!!!!!!" )
   TEST_LINE( OBJ_CREATE() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:OverStrike("12345678") )
   TEST_LINE( o:KillFocus() )

   SetPos( 14, 16 ) ; cStr01 := "hello world"
   o := _GET_( cStr01, "cStr01", "@R !!!.!!!!!!" )
   TEST_LINE( OBJ_CREATE() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:OverStrike("12345678") )
   TEST_LINE( o:KillFocus() )

   // ; Exercises

   TGetTest( 98, NIL )
   TGetTest( 98, "99999" )
   TGetTest( 98, "99999." )
   TGetTest( 98, "99999.99" )
   TGetTest( -98, NIL )
   TGetTest( -98, "99999" )
   TGetTest( -98, "99999." )
   TGetTest( -98, "99999.99" )
   TGetTest( "hello world", NIL )
   TGetTest( "hello world", "@!" )
   TGetTest( "hello world", "!!!" )
   TGetTest( "hello world", "@S5" )
   TGetTest( .T., NIL )
   TGetTest( .T., "Y" )
   SET CENTURY ON
   TGetTest( hb_SToD( "20070425" ), NIL )
   SET CENTURY OFF
   TGetTest( hb_SToD( "20070425" ), NIL )
   TGetTest( NIL, NIL )
   TGetTest( NIL, "!!!!" )
   TGetTest( {|| "" }, NIL )

   FClose( s_fhnd )

   RETURN 0

PROCEDURE TGetAssign( xVar )
   LOCAL o
   LOCAL nInt01 := 76
   LOCAL cStr01 := "AbC DeF 974"
   LOCAL dDat01 := hb_SToD( "20070425" )
   LOCAL lLog01 := .F.
   LOCAL bBlo01 := {|| NIL }

   s_xVar := xVar

   s_cTest := "Non-Focus Assign To N: " + XToStr( xVar )

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:BadDate   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Block     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Buffer    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Cargo     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Changed   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Clear     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Col       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:ColorSpec := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:DecPos    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:ExitState := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:HasFocus  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Minus     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Name      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Original  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Picture   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Pos       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:PostBlock := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:PreBlock  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Reader    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Rejected  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Row       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:SubScript := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:Type      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:TypeOut   := xVar )

   s_cTest := "Non-Focus Assign To C: " + XToStr( xVar )

   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:BadDate   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Block     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Buffer    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Cargo     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Changed   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Clear     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Col       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:ColorSpec := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:DecPos    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:ExitState := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:HasFocus  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Minus     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Name      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Original  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Picture   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Pos       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:PostBlock := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:PreBlock  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Reader    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Rejected  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Row       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:SubScript := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:Type      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:TypeOut   := xVar )

   s_cTest := "Non-Focus Assign To D: " + XToStr( xVar )

   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:BadDate   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Block     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Buffer    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Cargo     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Changed   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Clear     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Col       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:ColorSpec := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:DecPos    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:ExitState := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:HasFocus  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Minus     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Name      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Original  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Picture   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Pos       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:PostBlock := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:PreBlock  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Reader    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Rejected  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Row       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:SubScript := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:Type      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:TypeOut   := xVar )

   s_cTest := "Non-Focus Assign To L: " + XToStr( xVar )

   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:BadDate   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Block     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Buffer    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Cargo     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Changed   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Clear     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Col       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:ColorSpec := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:DecPos    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:ExitState := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:HasFocus  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Minus     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Name      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Original  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Picture   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Pos       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:PostBlock := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:PreBlock  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Reader    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Rejected  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Row       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:SubScript := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:Type      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:TypeOut   := xVar )

   s_cTest := "Non-Focus Assign To B: " + XToStr( xVar )

   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:BadDate   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Block     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Buffer    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Cargo     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Changed   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Clear     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Col       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:ColorSpec := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:DecPos    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:ExitState := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:HasFocus  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Minus     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Name      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Original  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Picture   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Pos       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:PostBlock := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:PreBlock  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Reader    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Rejected  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Row       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:SubScript := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:Type      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:TypeOut   := xVar )

   s_cTest := "InFocus Assign to N: " + XToStr( xVar )

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:BadDate   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Block     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Buffer    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Cargo     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Changed   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Clear     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Col       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:ColorSpec := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:DecPos    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:ExitState := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:HasFocus  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Minus     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Name      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Original  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Picture   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Pos       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:PostBlock := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:PreBlock  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Reader    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Rejected  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Row       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:SubScript := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:Type      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ):SetFocus ; TEST_LINE( o:TypeOut   := xVar )
                                                  
   s_cTest := "InFocus Assign to C: " + XToStr( xVar )

   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:BadDate   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Block     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Buffer    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Cargo     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Changed   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Clear     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Col       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:ColorSpec := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:DecPos    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:ExitState := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:HasFocus  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Minus     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Name      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Original  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Picture   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Pos       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:PostBlock := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:PreBlock  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Reader    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Rejected  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Row       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:SubScript := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:Type      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ):SetFocus ; TEST_LINE( o:TypeOut   := xVar )
                                                  
   s_cTest := "InFocus Assign to D: " + XToStr( xVar )

   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:BadDate   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Block     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Buffer    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Cargo     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Changed   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Clear     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Col       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:ColorSpec := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:DecPos    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:ExitState := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:HasFocus  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Minus     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Name      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Original  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Picture   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Pos       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:PostBlock := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:PreBlock  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Reader    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Rejected  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Row       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:SubScript := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:Type      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ):SetFocus ; TEST_LINE( o:TypeOut   := xVar )
                                                  
   s_cTest := "InFocus Assign to L: " + XToStr( xVar )

   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:BadDate   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Block     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Buffer    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Cargo     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Changed   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Clear     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Col       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:ColorSpec := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:DecPos    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:ExitState := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:HasFocus  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Minus     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Name      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Original  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Picture   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Pos       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:PostBlock := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:PreBlock  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Reader    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Rejected  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Row       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:SubScript := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:Type      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ):SetFocus ; TEST_LINE( o:TypeOut   := xVar )
                                                  
   s_cTest := "InFocus Assign to B: " + XToStr( xVar )

   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:BadDate   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Block     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Buffer    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Cargo     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Changed   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Clear     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Col       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:ColorSpec := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:DecPos    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:ExitState := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:HasFocus  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Minus     := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Name      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Original  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Picture   := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Pos       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:PostBlock := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:PreBlock  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Reader    := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Rejected  := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Row       := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:SubScript := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:Type      := xVar )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ):SetFocus ; TEST_LINE( o:TypeOut   := xVar )

   s_cTest := "InFocus/SetFocus " + XToStr( xVar )

   SetPos( 14, 16 ) ; o := _GET_( nInt01, "nInt01" ) ; TEST_LINE( o:SetFocus )
   SetPos( 14, 16 ) ; o := _GET_( cStr01, "cStr01" ) ; TEST_LINE( o:SetFocus )
   SetPos( 14, 16 ) ; o := _GET_( dDat01, "dDat01" ) ; TEST_LINE( o:SetFocus )
   SetPos( 14, 16 ) ; o := _GET_( lLog01, "lLog01" ) ; TEST_LINE( o:SetFocus )
   SetPos( 14, 16 ) ; o := _GET_( bBlo01, "bBlo01" ) ; TEST_LINE( o:SetFocus )

   RETURN

PROCEDURE TGetTest( xVar, cPic )
   LOCAL bOldBlock
   LOCAL o

   s_xVar := xVar

   // ; Display

   s_cTest := "Display Var: " + ValType( xVar ) + " Pic: " + iif( cPic == NIL, "(none)", cPic )

   SetPos( 14, 16 ) ; o := _GET_( s_xVar, "s_xVar" )
   TEST_LINE( OBJ_CREATE() )
   TEST_LINE( o:Display() )

   // ; In focus

   s_cTest := "InFocus Var: " + ValType( xVar ) + " Pic: " + iif( cPic == NIL, "(none)", cPic )

   SetPos( 14, 16 ) ; o := _GET_( s_xVar, "s_xVar" )
   TEST_LINE( OBJ_CREATE() )
   bOldBlock := o:block
   TEST_LINE( o:block := {| h | LogMe( h ), iif( h == NIL, Eval( bOldBlock ), Eval( bOldBlock, h ) ) } )
   TEST_LINE( o:SetFocus() )
   IF cPic != NIL
      TEST_LINE( o:picture := "99999" )
      TEST_LINE( o:picture := cPic )
      TEST_LINE( o:picture := NIL )
   ENDIF
   TEST_LINE( o:UpdateBuffer() )
   TEST_LINE( o:UpdateBuffer() )
   TEST_LINE( o:Reform() )
   TEST_LINE( o:Display() )
   TEST_LINE( o:KillFocus() )

   // ; Not in focus

   s_cTest := "NotFocus Var: " + ValType( xVar ) + " Pic: " + iif( cPic == NIL, "(none)", cPic )

   SetPos( 14, 16 ) ; o := _GET_( s_xVar, "s_xVar" )
   TEST_LINE( OBJ_CREATE() )
   bOldBlock := o:block
   TEST_LINE( o:block := {| h | LogMe( h ), iif( h == NIL, Eval( bOldBlock ), Eval( bOldBlock, h ) ) } )
   IF cPic != NIL
      TEST_LINE( o:picture := "99999" )
      TEST_LINE( o:picture := cPic )
      TEST_LINE( o:picture := NIL )
   ENDIF
   TEST_LINE( o:UpdateBuffer() )
   TEST_LINE( o:UpdateBuffer() )
   TEST_LINE( o:Reform() )
   TEST_LINE( o:Display() )
   TEST_LINE( o:KillFocus() )

   // ; In Focus editing

   s_cTest := "InFocus #2 Var: " + ValType( xVar ) + " Pic: " + iif( cPic == NIL, "(none)", cPic )

   SetPos( 14, 16 ) ; o := _GET_( s_xVar, "s_xVar" )
   bOldBlock := o:block
   TEST_LINE( o:block := {| h | LogMe( h ), iif( h == NIL, Eval( bOldBlock ), Eval( bOldBlock, h ) ) } )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Insert( "6" ) )
   TEST_LINE( o:Undo(.T.) )
   TEST_LINE( o:Insert( "5" ) )
   TEST_LINE( o:Assign() )
   TEST_LINE( o:Reset() )
   TEST_LINE( o:KillFocus() )
   TEST_LINE( o:VarPut( "newvalue " ) )
   TEST_LINE( o:Insert( "7" ) )
   TEST_LINE( o:Undo(.T.) )
   TEST_LINE( o:Assign() )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Insert( "3" ) )
   TEST_LINE( o:Undo(.T.) )
   TEST_LINE( o:KillFocus() )
   TEST_LINE( o:VarPut( 0 ) )
   TEST_LINE( o:SetFocus() )
   TEST_LINE( o:Insert( "3" ) )
   TEST_LINE( o:Undo(.T.) )
   TEST_LINE( o:KillFocus() )

   // ;

   s_cTest := ""

   RETURN

PROCEDURE TEST_CALL( o, cBlock, bBlock )
   LOCAL xResult
   LOCAL bOldError
   LOCAL oError

   SetPos( 0, 0 ) // ; To check where the cursor was moved after evaluating the block.

   bOldError := ErrorBlock( {|oError| Break( oError ) } )

   BEGIN SEQUENCE
      xResult := Eval( bBlock )
   RECOVER USING oError
      xResult := ErrorMessage( oError )
   END SEQUENCE

   ErrorBlock( bOldError )

   LogGETVars( o, cBlock, xResult )

   RETURN

PROCEDURE LogMe( data, desc )
   LOCAL nLevel
   LOCAL cStack

   cStack := ""
   FOR nLevel := 2 TO 5
      IF Empty( ProcName( nLevel ) )
         EXIT
      ENDIF
      cStack += ProcName( nLevel ) + " (" + LTrim( Str( ProcLine( nLevel ) ) ) + ") "
   NEXT

   IF desc == NIL
        desc := ""
   ENDIF
   desc := s_cTest + " " + desc

   IF !s_lCallBackStack
      cStack := ""
   ENDIF

   IF PCount() > 2
      FWrite( s_fhnd, cStack + "BLOCK_SET  " + iif( data == NIL, "NIL", data ) + "  " + desc + hb_OSNewLine() )
   ELSE
      FWrite( s_fhnd, cStack + "BLOCK_GET  " + desc + hb_OSNewLine() )
   ENDIF

   RETURN

PROCEDURE LogGETVars( o, desc, xResult )
   LOCAL nLevel
   LOCAL cStack

   LOCAL tmp

   cStack := ""
   FOR nLevel := 2 TO 2
      IF Empty( ProcName( nLevel ) )
         EXIT
      ENDIF
      cStack += ProcName( nLevel ) + " (" + LTrim( Str( ProcLine( nLevel ) ) ) + ") "
   NEXT

   IF desc == NIL
        desc := ""
   ENDIF
   desc := s_cTest + " " + XToStr( desc )

   FWrite( s_fhnd, cStack + "  " + desc + hb_OSNewLine() )
   FWrite( s_fhnd, "---------------------" + hb_OSNewLine() )
   FWrite( s_fhnd, "   s_xVar        " + XToStr( s_xVar      ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   xResult       " + XToStr( xResult     ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Row()         " + XToStr( Row()       ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Col()         " + XToStr( Col()       ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   UnTransform() " + XToStr( o:UnTransform() ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   BadDate       " + XToStr( o:BadDate   ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Block         " + XToStr( o:Block     ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Buffer        " + XToStr( o:Buffer    ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Cargo         " + XToStr( o:Cargo     ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Changed       " + XToStr( o:Changed   ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Clear         " + XToStr( o:Clear     ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Col           " + XToStr( o:Col       ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   ColorSpec     " + XToStr( o:ColorSpec ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   DecPos        " + XToStr( o:DecPos    ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   ExitState     " + XToStr( o:ExitState ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   HasFocus      " + XToStr( o:HasFocus  ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Minus         " + XToStr( o:Minus     ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Name          " + XToStr( o:Name      ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Original      " + XToStr( o:Original  ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Picture       " + XToStr( o:Picture   ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Pos           " + XToStr( o:Pos       ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   PostBlock     " + XToStr( o:PostBlock ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   PreBlock      " + XToStr( o:PreBlock  ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Reader        " + XToStr( o:Reader    ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Rejected      " + XToStr( o:Rejected  ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Row           " + XToStr( o:Row       ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   SubScript     " + XToStr( o:SubScript ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   Type          " + XToStr( o:Type      ) + hb_OSNewLine() )
   FWrite( s_fhnd, "   TypeOut       " + XToStr( o:TypeOut   ) + hb_OSNewLine() )
   IF s_lObjectDump
#ifdef __HARBOUR__
#ifdef HB_COMPAT_C53
      FOR tmp := 1 TO iif( o:hasFocus, 19, 16 )
#else
      FOR tmp := 1 TO iif( o:hasFocus, 13, 10 )
#endif
#else
      FOR tmp := 1 TO Len( o )
#endif
         FWrite( s_fhnd, "   [ " + Str( tmp, 3 ) + " ]       " + XToStrX( o[ tmp ] ) + hb_OSNewLine() )
      NEXT
   ENDIF
   FWrite( s_fhnd, "---------------------" + hb_OSNewLine() )

   RETURN

STATIC FUNCTION ObjToList( o )
   LOCAL cString := ""
   LOCAL tmp

   FOR tmp := 1 TO Len( o )
       cString += XToStr( o[ tmp ] )
       IF tmp < Len( o )
          cString += ", "
       ENDIF
   NEXT

   RETURN cString

FUNCTION XToStr( xValue )
   LOCAL cType := ValType( xValue )

   DO CASE
   CASE cType == "C"

      xValue := StrTran( xValue, Chr(0), '"+Chr(0)+"' )
      xValue := StrTran( xValue, Chr(9), '"+Chr(9)+"' )
      xValue := StrTran( xValue, Chr(10), '"+Chr(10)+"' )
      xValue := StrTran( xValue, Chr(13), '"+Chr(13)+"' )
      xValue := StrTran( xValue, Chr(26), '"+Chr(26)+"' )

      RETURN '"' + xValue + '"'

   CASE cType == "N" ; RETURN LTrim( Str( xValue ) )
   CASE cType == "D" ; RETURN 'HB_SToD("' + DToS( xValue ) + '")'
   CASE cType == "L" ; RETURN iif( xValue, ".T.", ".F." )
   CASE cType == "O" ; RETURN xValue:className() + " Object"
   CASE cType == "U" ; RETURN "NIL"
   CASE cType == "B" ; RETURN '{||...}'
   CASE cType == "A" ; RETURN '{.[' + LTrim( Str( Len( xValue ) ) ) + '].}'
   CASE cType == "M" ; RETURN 'M:"' + xValue + '"'
   ENDCASE

   RETURN ""

FUNCTION XToStrE( xValue )
   LOCAL cType := ValType( xValue )

   DO CASE
   CASE cType == "C"

      xValue := StrTran( xValue, Chr(0), '"+Chr(0)+"' )
      xValue := StrTran( xValue, Chr(9), '"+Chr(9)+"' )
      xValue := StrTran( xValue, Chr(10), '"+Chr(10)+"' )
      xValue := StrTran( xValue, Chr(13), '"+Chr(13)+"' )
      xValue := StrTran( xValue, Chr(26), '"+Chr(26)+"' )

      RETURN xValue

   CASE cType == "N" ; RETURN LTrim( Str( xValue ) )
   CASE cType == "D" ; RETURN DToS( xValue )
   CASE cType == "L" ; RETURN iif( xValue, ".T.", ".F." )
   CASE cType == "O" ; RETURN xValue:className() + " Object"
   CASE cType == "U" ; RETURN "NIL"
   CASE cType == "B" ; RETURN '{||...}'
   CASE cType == "A" ; RETURN '{.[' + LTrim( Str( Len( xValue ) ) ) + '].}'
   CASE cType == "M" ; RETURN 'M:' + xValue
   ENDCASE

   RETURN ""

FUNCTION XToStrX( xValue )
   LOCAL cType := ValType( xValue )

   LOCAL tmp
   LOCAL cRetVal

   DO CASE
   CASE cType == "C"

      xValue := StrTran( xValue, Chr(0), '"+Chr(0)+"' )
      xValue := StrTran( xValue, Chr(9), '"+Chr(9)+"' )
      xValue := StrTran( xValue, Chr(10), '"+Chr(10)+"' )
      xValue := StrTran( xValue, Chr(13), '"+Chr(13)+"' )
      xValue := StrTran( xValue, Chr(26), '"+Chr(26)+"' )

      RETURN xValue

   CASE cType == "N" ; RETURN LTrim( Str( xValue ) )
   CASE cType == "D" ; RETURN DToS( xValue )
   CASE cType == "L" ; RETURN iif( xValue, ".T.", ".F." )
   CASE cType == "O" ; RETURN xValue:className() + " Object"
   CASE cType == "U" ; RETURN "NIL"
   CASE cType == "B" ; RETURN '{||...} -> ' + XToStrX( Eval( xValue ) )
   CASE cType == "A"

      cRetVal := '{ '

      FOR tmp := 1 TO Len( xValue )
         cRetVal += XToStrX( xValue[ tmp ] )
         IF tmp < Len( xValue )
            cRetVal += ", "
         ENDIF
      NEXT
   
      RETURN cRetVal + ' }'

   CASE cType == "M" ; RETURN 'M:' + xValue
   ENDCASE

   RETURN ""

STATIC FUNCTION ErrorMessage( oError )
   LOCAL cMessage
   LOCAL tmp

   IF s_lRTEDetails

      cMessage := ""

      IF ValType( oError:severity ) == "N"
         DO CASE
         CASE oError:severity == ES_WHOCARES     ; cMessage += "M "
         CASE oError:severity == ES_WARNING      ; cMessage += "W "
         CASE oError:severity == ES_ERROR        ; cMessage += "E "
         CASE oError:severity == ES_CATASTROPHIC ; cMessage += "C "
         ENDCASE
      ENDIF
      IF ValType( oError:subsystem ) == "C"
         cMessage += oError:subsystem + " "
      ENDIF
      IF ValType( oError:subCode ) == "N"
         cMessage += LTrim( Str( oError:subCode ) ) + " "
      ENDIF
      IF ValType( oError:description ) == "C"
         cMessage += oError:description + " "
      ENDIF
      IF !Empty( oError:operation )
         cMessage += oError:operation + " "
      ENDIF
      IF !Empty( oError:filename )
         cMessage += oError:filename + " "
      ENDIF
      
      IF ValType( oError:Args ) == "A"
         cMessage += "A:" + LTrim( Str( Len( oError:Args ) ) ) + ":"
         FOR tmp := 1 TO Len( oError:Args )
            cMessage += ValType( oError:Args[ tmp ] ) + ":" + XToStrE( oError:Args[ tmp ] )
            IF tmp < Len( oError:Args )
               cMessage += ";"
            ENDIF
         NEXT
         cMessage += " "
      ENDIF
      
      IF oError:canDefault .OR. ;
         oError:canRetry .OR. ;
         oError:canSubstitute
      
         cMessage += "F:"
         IF oError:canDefault
            cMessage += "D"
         ENDIF
         IF oError:canRetry
            cMessage += "R"
         ENDIF
         IF oError:canSubstitute
            cMessage += "S"
         ENDIF
      ENDIF
   ELSE
      cMessage := "(ERROR)"
   ENDIF

   RETURN cMessage

#ifdef __XPP__
FUNCTION hb_SToD( cDate )
   RETURN SToD( cDate )
#endif

#ifndef HAVE_HBCLIP
#ifndef __HARBOUR__
#ifndef __XPP__

FUNCTION hb_SToD( cDate )
   LOCAL cOldDateFormat
   LOCAL dDate

   IF ValType( cDate ) == "C" .AND. !Empty( cDate )
      cOldDateFormat := Set( _SET_DATEFORMAT, "yyyy/mm/dd" )

      dDate := CToD( SubStr( cDate, 1, 4 ) + "/" +;
                     SubStr( cDate, 5, 2 ) + "/" +;
                     SubStr( cDate, 7, 2 ) )

      Set( _SET_DATEFORMAT, cOldDateFormat )
   ELSE
      dDate := CToD( "" )
   ENDIF

   RETURN dDate

#endif
#endif
#endif

PROCEDURE OBJ_CREATE()

   // ; Dummy

   RETURN
