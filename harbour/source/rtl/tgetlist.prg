/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * HBGetList Class
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

/*
 * The following parts are Copyright of the individual authors.
 * www - http://www.harbour-project.org
 *
 * Copyright 2001 Luiz Rafael Culik
 *    Support for CA-Cl*pper 5.3 Getsystem
 *
 * See doc/license.txt for licensing terms.
 *
 */

#include "hbclass.ch"

#include "button.ch"
#include "common.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "tbrowse.ch"

#define SCORE_ROW       0
#define SCORE_COL       60

#define _GET_INSERT_ON  7
#define _GET_INSERT_OFF 8
#define _GET_INVD_DATE  9

#define K_UNDO          K_CTRL_U

#define MSGFLAG         1
#define MSGROW          2
#define MSGLEFT         3
#define MSGRIGHT        4
#define MSGCOLOR        5

CREATE CLASS HBGetList

   EXPORTED:

   VAR HasFocus        AS LOGICAL   INIT .F.

#ifdef HB_COMPAT_C53
   METHOD ReadModal( nPos, oMenu, nMsgRow, nMsgLeft, nMsgRight, cMsgColor )
#else
   METHOD ReadModal()
#endif
   METHOD Settle( nPos, lInit )
   METHOD Reader( oMenu, aMsg )
   METHOD GetApplyKey( nKey, oGet, oMenu, aMsg )
   METHOD GetPreValidate( oGet, aMsg )
   METHOD GetPostValidate( oGet, aMsg )
   METHOD GetDoSetKey( bKeyBlock, oGet )
   METHOD PostActiveGet()
   METHOD GetReadVar()
   METHOD SetFormat( bFormat )
   METHOD KillRead( lKill )
   METHOD GetActive( oGet )
   METHOD DateMsg()
   METHOD ShowScoreBoard()
   METHOD ReadUpdated( lUpdated )
   METHOD ReadVar( cNewVarName )
   METHOD SetFocus()
   METHOD Updated()                                  // returns ::lUpdated
   METHOD Get()                                      // returns ::oGet

#ifdef HB_COMPAT_C53
   METHOD GUIReader( oGet, oMenu, aMsg )
   METHOD GUIApplyKey( oGet, oGUI, nKey, oMenu, aMsg )
   METHOD GUIPreValidate( oGet, oGUI, aMsg )
   METHOD GUIPostValidate( oGet, oGUI, aMsg )
   METHOD TBApplyKey( oGet, oTB, nKey, oMenu, aMsg )
   METHOD TBReader( oGet, oMenu, aMsg )
   METHOD Accelerator( nKey, aMsg )
   METHOD hitTest( nMRow, nMCol, aMsg )
#endif
   METHOD ReadStats( nElement, xNewValue )
   METHOD ShowGetMsg( oGet, aMsg )
   METHOD EraseGetMsg( aMsg )

   METHOD New( GetList )

   PROTECTED:

   VAR oGet
   VAR aGetList

   VAR lUpdated        AS LOGICAL   INIT .F.
   VAR bFormat
   VAR lKillRead       AS LOGICAL   INIT .F.
   VAR lBumpTop        AS LOGICAL   INIT .F.
   VAR lBumpBot        AS LOGICAL   INIT .F.
   VAR nLastExitState               INIT 0
   VAR nLastPos        AS NUMERIC   INIT 0
   VAR oActiveGet
   VAR xReadVar
   VAR cVarName
   VAR cReadProcName   AS CHARACTER INIT ""
   VAR nReadProcLine                INIT 0
   VAR nNextGet                     INIT 0
   VAR nHitCode        AS NUMERIC   INIT 0
   VAR nPos            AS NUMERIC   INIT 1
   VAR cMsgSaveS
   VAR nMenuID
   VAR nSaveCursor

ENDCLASS

/* -------------------------------------------- */

#ifdef HB_COMPAT_C53
METHOD ReadModal( nPos, oMenu, nMsgRow, nMsgLeft, nMsgRight, cMsgColor ) CLASS HBGetList
#else
METHOD ReadModal() CLASS HBGetList
#endif

#ifdef HB_COMPAT_C53
   LOCAL lMsgFlag
   LOCAL aMsg
#endif

#ifdef HB_COMPAT_C53
   ::nSaveCursor   := SetCursor( SC_NONE )
#endif
   ::cReadProcName := ProcName( 2 )
   ::nReadProcLine := ProcLine( 2 )

#ifdef HB_COMPAT_C53
   ::nPos := ::Settle( iif( ISNUMBER( nPos ), nPos, 0 ), .T. )

   IF ( lMsgFlag := ISNUMBER( nMsgRow ) .AND. ;
                    ISNUMBER( nMsgLeft ) .AND. ;
                    ISNUMBER( nMsgRight ) )

      IF !ISCHARACTER( cMsgColor )
         cMsgColor := GetClrPair( SetColor(), 1 )
      ENDIF

      Scroll( nMsgRow, nMsgLeft, nMsgRow, nMsgRight )

      ::cMsgSaveS := SaveScreen( nMsgRow, nMsgLeft, nMsgRow, nMsgRight )
   ENDIF

   ::nNextGet := 0
   ::nHitCode := 0
   ::nMenuID := 0

   aMsg := { lMsgFlag, nMsgRow, nMsgLeft, nMsgRight, cMsgColor, , , , , }
#else
   ::nPos := ::Settle( 0 )
#endif

   DO WHILE ::nPos != 0

      ::oGet := ::aGetList[ ::nPos ]
      ::PostActiveGet()

#ifdef HB_COMPAT_C53
      IF ISBLOCK( ::oGet:reader )
         Eval( ::oGet:reader, ::oGet, Self, oMenu, aMsg )
      ELSE
         ::Reader( oMenu, aMsg )
      ENDIF
#else
      IF ISBLOCK( ::oGet:reader )
         Eval( ::oGet:reader, ::oGet )
      ELSE
         ::Reader()
      ENDIF
#endif

      ::nPos := ::Settle( ::nPos )

   ENDDO

#ifdef HB_COMPAT_C53
   IF lMsgFlag
      RestScreen( nMsgRow, nMsgLeft, nMsgRow, nMsgRight, ::cMsgSaveS )
   ENDIF

   SetCursor( ::nSaveCursor )
#endif

   RETURN Self

METHOD Updated() CLASS HBGetList
   RETURN ::lUpdated

METHOD Get() CLASS HBGetList
   RETURN ::oGet

METHOD SetFocus() CLASS HBGetList

   __GetListSetActive( Self )
   __GetListLast( Self )
   ::aGetList[ ::nPos ]:setFocus()

   RETURN Self

METHOD Reader( oMenu, aMsg ) CLASS HBGetList

   LOCAL oGet := ::oGet
   LOCAL nRow
   LOCAL nCol
#ifdef HB_COMPAT_C53
   LOCAL nOldCursor
   LOCAL nKey
#endif

#ifdef HB_COMPAT_C53
   IF ::nLastExitState == GE_SHORTCUT .OR.;
      ::nLastExitState == GE_MOUSEHIT .OR.;
      ::GetPreValidate( oGet, aMsg )
#else
   IF ::GetPreValidate( oGet, aMsg )
#endif

      ::ShowGetMsg( oGet, aMsg )

      ::nHitCode := 0
      ::nLastExitState := 0
      oGet:setFocus()

      DO WHILE oGet:exitState == GE_NOEXIT .AND. !::lKillRead
         IF oGet:typeOut
            oGet:exitState := GE_ENTER
         ENDIF

//       IF oGet:buffer == NIL
//          oGet:exitState := GE_ENTER
//       ENDIF

         DO WHILE oGet:exitState == GE_NOEXIT .AND. !::lKillRead
#ifdef HB_COMPAT_C53
            SetCursor( iif( ::nSaveCursor == SC_NONE, SC_NORMAL, ::nSaveCursor ) )
            nKey := Inkey( 0 )
            SetCursor( SC_NONE )
            ::GetApplyKey( nKey, oGet, oMenu, aMsg )
#else
            ::GetApplyKey( Inkey( 0 ), oGet, oMenu, aMsg )
#endif
            nRow := Row()
            nCol := Col()
            ::ShowGetMsg( oGet, aMsg )
            SetPos( nRow, nCol )
         ENDDO

#ifdef HB_COMPAT_C53
         IF !::nLastExitState == GE_SHORTCUT .AND. ;
            !::nLastExitState == GE_MOUSEHIT .AND. ;
            !::GetPostValidate( oGet, aMsg )
#else
         IF !::GetPostValidate( oGet, aMsg )
#endif
            oGet:exitState := GE_NOEXIT
         ENDIF
      ENDDO

#ifdef HB_COMPAT_C53
      nRow := Row()
      nCol := Col()
      nOldCursor := SetCursor()
#endif
      oGet:killFocus()
#ifdef HB_COMPAT_C53
      SetCursor( nOldCursor )
      SetPos( nRow, nCol )
#endif

      ::EraseGetMsg( aMsg )
   ENDIF

   RETURN Self

METHOD GetApplyKey( nKey, oGet, oMenu, aMsg ) CLASS HBGetList

   LOCAL cKey
   LOCAL bKeyBlock
   LOCAL lSetKey

#ifdef HB_COMPAT_C53
   LOCAL nMRow
   LOCAL nMCol
   LOCAL nButton
   LOCAL nHotItem
#endif

   DEFAULT oGet TO ::oGet

   IF ( bKeyBlock := SetKey( nKey ) ) != NIL
      IF ( lSetKey := ::GetDoSetKey( bKeyBlock, oGet ) )
         RETURN Self
      ENDIF
   ENDIF

#ifdef HB_COMPAT_C53
   IF ::aGetList != NIL .AND. ( nHotItem := ::Accelerator( nKey, aMsg ) ) != 0

      oGet:exitState := GE_SHORTCUT
      ::nNextGet := nHotItem
      ::nLastExitState := GE_SHORTCUT
   ELSEIF !ISOBJECT( oMenu )
   ELSEIF ( nHotItem := oMenu:getAccel( nKey ) ) != 0
      ::nMenuID := MenuModal( oMenu, nHotItem, aMsg[ MSGROW ], aMsg[ MSGLEFT ], aMsg[ MSGRIGHT ], aMsg[ MSGCOLOR ] )
      nKey := 0
   ELSEIF IsShortCut( oMenu, nKey )
      nKey := 0
   ENDIF
#else
   HB_SYMBOL_UNUSED( oMenu )
   HB_SYMBOL_UNUSED( aMsg )
#endif

   DO CASE
   CASE nKey == K_UP
      oGet:exitState := GE_UP
   
   CASE nKey == K_SH_TAB
      oGet:exitState := GE_UP
   
   CASE nKey == K_DOWN
      oGet:exitState := GE_DOWN
   
   CASE nKey == K_TAB
      oGet:exitState := GE_DOWN
   
   CASE nKey == K_ENTER
      oGet:exitState := GE_ENTER

   CASE nKey == K_ESC
      IF Set( _SET_ESCAPE )
         oGet:undo()
         oGet:exitState := GE_ESCAPE
      ENDIF

   CASE nKey == K_PGUP
      oGet:exitState := GE_WRITE

   CASE nKey == K_PGDN
      oGet:exitState := GE_WRITE

   CASE nKey == K_CTRL_HOME
      oGet:exitState := GE_TOP

#ifdef CTRL_END_SPECIAL
   CASE nKey == K_CTRL_END
      oGet:exitState := GE_BOTTOM
#else
   CASE nKey == K_CTRL_W
      oGet:exitState := GE_WRITE
#endif

#ifdef HB_COMPAT_C53
   CASE nKey == K_LBUTTONDOWN .OR. nKey == K_LDBLCLK

      nMRow := MRow()
      nMCol := MCol()

      IF !ISOBJECT( oMenu )
         nButton := 0
      ELSEIF !( oMenu:ClassName() == "TOPBARMENU" )
         nButton := 0
      ELSEIF ( nButton := oMenu:hitTest( nMRow, nMCol ) ) != 0
         ::nMenuID := MenuModal( oMenu, nHotItem, aMsg[ MSGROW ], aMsg[ MSGLEFT ], aMsg[ MSGRIGHT ], aMsg[ MSGCOLOR ] )
         nButton := 1
      ENDIF

      IF nButton != 0
      ELSEIF ( nButton := oGet:hitTest( nMRow, nMCol ) ) == HTCLIENT

         DO WHILE oGet:col + oGet:pos - 1 > nMCol
            oGet:left()

            // Handle editing buffer if first character is non-editable:
            IF oGet:typeOut
               // reset typeout:
               oGet:home()
               EXIT
            ENDIF

         ENDDO

         DO WHILE oGet:col + oGet:pos - 1 < nMCol
            oGet:right()

            // Handle editing buffer if last character is non-editable:
            IF oGet:typeOut
               // reset typeout:
               oGet:end()
               EXIT
            ENDIF

         ENDDO

      ELSEIF nButton != HTNOWHERE
      ELSEIF ::aGetList != NIL .AND. ::hitTest( nMRow, nMCol, aMsg ) != 0
         oGet:exitState := GE_MOUSEHIT
         ::nLastExitState := GE_MOUSEHIT
      ELSE
         oGet:exitState := GE_NOEXIT
      ENDIF
#endif

   CASE nKey == K_UNDO
      oGet:undo()

   CASE nKey == K_HOME
      oGet:home()

   CASE nKey == K_END
      oGet:end()

   CASE nKey == K_RIGHT
      oGet:right()

   CASE nKey == K_LEFT
      oGet:left()

   CASE nKey == K_CTRL_RIGHT
      oGet:wordRight()

   CASE nKey == K_CTRL_LEFT
      oGet:wordLeft()

   CASE nKey == K_BS
      oGet:backSpace()

   CASE nKey == K_DEL
      oGet:delete()

   CASE nKey == K_CTRL_T
      oGet:delWordRight()

   CASE nKey == K_CTRL_Y
      oGet:delEnd()

   CASE nKey == K_CTRL_BS
      oGet:delWordLeft()

   CASE nKey == K_INS
      Set( _SET_INSERT, ! Set( _SET_INSERT ) )
      ::ShowScoreboard()

   OTHERWISE

      IF nKey >= 32 .AND. nKey <= 255
         cKey := Chr( nKey )

         IF oGet:type == "N" .AND. ( cKey == "." .OR. cKey == "," )
            oGet:toDecPos()
         ELSE
            IF Set( _SET_INSERT )
               oGet:insert( cKey )
            ELSE
               oGet:overStrike( cKey )
            ENDIF

            IF oGet:typeOut
               IF Set( _SET_BELL )
                  QQOut( Chr( 7 ) )
               ENDIF
               IF ! Set( _SET_CONFIRM )
                  oGet:exitState := GE_ENTER
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDCASE

   RETURN Self

METHOD GetPreValidate( oGet, aMsg ) CLASS HBGetList

   LOCAL lUpdated
   LOCAL lWhen := .T.

   DEFAULT oGet TO ::oGet

   IF oGet:preBlock != NIL

      lUpdated  := ::lUpdated

      lWhen := Eval( oGet:preBlock, oGet, aMsg )

      IF ! ISOBJECT( oGet:control ) .AND. ! lWhen
         oGet:display()
      ENDIF

      ::ShowScoreBoard()

      ::lUpdated := lUpdated

      __GetListLast( Self )
   ENDIF

   IF ::lKillRead
      lWhen := .F.
      oGet:exitState := GE_ESCAPE
   ELSEIF ! lWhen
      oGet:exitState := GE_WHEN
   ELSE
      oGet:exitState := GE_NOEXIT
   ENDIF

   RETURN lWhen

METHOD GetPostValidate( oGet, aMsg ) CLASS HBGetList

   LOCAL lUpdated
   LOCAL lValid := .T.
#ifdef HB_COMPAT_C53
   LOCAL nOldCursor
#endif

   DEFAULT oGet TO ::oGet

   IF oGet:exitState == GE_ESCAPE
      RETURN .T.
   ENDIF

   IF oGet:badDate
      oGet:home()
      ::DateMsg()
      ::ShowScoreboard()
      RETURN .F.
   ENDIF

   IF oGet:changed
      oGet:assign()
      ::lUpdated := .T.
   ENDIF

#ifdef HB_COMPAT_C53
   nOldCursor := SetCursor()
#endif
   oGet:reset()
#ifdef HB_COMPAT_C53
   SetCursor( nOldCursor )
#endif

   IF oGet:postBlock != NIL

      lUpdated := ::lUpdated

      IF ISCHARACTER( oGet:buffer )
         SetPos( oGet:row, oGet:col + Len( oGet:buffer ) )
      ENDIF
      lValid := Eval( oGet:postBlock, oGet, aMsg )
      SetPos( oGet:row, oGet:col )

      ::ShowScoreBoard()
      oGet:updateBuffer()
      
#ifdef HB_COMPAT_C53
      ::lUpdated := iif( oGet:changed, .T., lUpdated )
#else
      ::lUpdated := lUpdated
#endif

      __GetListLast( Self )

      IF ::lKillRead
         oGet:exitState := GE_ESCAPE
         lValid := .T.
      ENDIF
   ENDIF

   RETURN lValid

METHOD GetDoSetKey( bKeyBlock, oGet ) CLASS HBGetList

   LOCAL lUpdated
   LOCAL lSetKey

   DEFAULT oGet TO ::oGet

   IF oGet:changed
      oGet:assign()
      ::lUpdated := .T.
   ENDIF

   lUpdated := ::lUpdated

   lSetKey := Eval( bKeyBlock, ::cReadProcName, ::nReadProcLine, ::ReadVar() )

   IF !ISLOGICAL( lSetKey )
      lSetKey := .T.
   ENDIF

   ::ShowScoreboard()
   oGet:updateBuffer()

   ::lUpdated := lUpdated

   __GetListLast( Self )

   IF ::lKillRead
      oGet:exitState := GE_ESCAPE
   ENDIF

   RETURN lSetKey

METHOD Settle( nPos, lInit ) CLASS HBGetList

   LOCAL nExitState

   DEFAULT nPos  TO ::nPos
   DEFAULT lInit TO .F.

   IF nPos == 0
      nExitState := GE_DOWN
   ELSEIF nPos > 0 .AND. lInit /* NOTE: Never .T. in C5.2 mode. */
      nExitState := GE_NOEXIT
   ELSE
      nExitState := ::aGetList[ nPos ]:exitState
   ENDIF

   IF nExitState == GE_ESCAPE .OR. nExitState == GE_WRITE
      RETURN 0
   ENDIF

   IF nExitState != GE_WHEN
      ::nLastPos := nPos
      ::lBumpTop := .F.
      ::lBumpBot := .F.
   ELSE
      IF ::nLastExitState != 0
         nExitState := ::nLastExitState
      ELSEIF ::nNextGet < ::nLastPos 
         nExitState := GE_UP
      ELSE
         nExitState := GE_DOWN
      ENDIF

   ENDIF

   DO CASE
   CASE nExitState == GE_UP
      nPos--

   CASE nExitState == GE_DOWN
      nPos++

   CASE nExitState == GE_TOP
      nPos := 1
      ::lBumpTop := .T.
      nExitState := GE_DOWN

   CASE nExitState == GE_BOTTOM
      nPos := Len( ::aGetList )
      ::lBumpBot := .T.
      nExitState := GE_UP

   CASE nExitState == GE_ENTER
      nPos++

   CASE nExitState == GE_SHORTCUT 
      RETURN ::nNextGet

   CASE nExitState == GE_MOUSEHIT
      RETURN ::nNextGet

   ENDCASE

   IF nPos == 0
      IF ! Set( _SET_EXIT ) .AND. ! ::lBumpBot
         ::lBumpTop := .T.
         nPos       := ::nLastPos
         nExitState := GE_DOWN
      ENDIF

   ELSEIF nPos == Len( ::aGetList ) + 1
      IF ! Set( _SET_EXIT ) .AND. nExitState != GE_ENTER .AND. ! ::lBumpTop
         ::lBumpBot := .T.
         nPos       := ::nLastPos
         nExitState := GE_UP
      ELSE
         nPos := 0
      ENDIF
   ENDIF

   ::nLastExitState := nExitState

   IF nPos != 0
      ::aGetList[ nPos ]:exitState := nExitState
   ENDIF

   RETURN nPos

METHOD PostActiveGet() CLASS HBGetList

   ::GetActive( ::oGet )
   ::ReadVar( ::GetReadVar() )
   ::ShowScoreBoard()

   RETURN Self

METHOD GetReadVar() CLASS HBGetList

   LOCAL oGet := ::oGet
   LOCAL cName := Upper( oGet:Name )
   LOCAL n

   IF oGet:Subscript != NIL
      FOR n := 1 TO Len( oGet:Subscript )
         cName += "[" + LTrim( Str( oGet:Subscript[ n ] ) ) + "]"
      NEXT
   ENDIF

   RETURN cName

METHOD SetFormat( bFormat ) CLASS HBGetList

   LOCAL bSavFormat := ::bFormat

   IF ISBLOCK( bFormat )
      ::bFormat := bFormat
   ENDIF

   RETURN bSavFormat

METHOD KillRead( lKill ) CLASS HBGetList

   LOCAL lSavKill := ::lKillRead

   IF PCount() > 0
      ::lKillRead := lKill
   ENDIF

   RETURN lSavKill

METHOD GetActive( oGet ) CLASS HBGetList

   LOCAL oOldGet := ::oActiveGet

   IF PCount() > 0
      ::oActiveGet := oGet
   ENDIF

   RETURN oOldGet

METHOD ShowScoreboard() CLASS HBGetList

   LOCAL nRow
   LOCAL nCol
   LOCAL nOldCursor

   IF Set( _SET_SCOREBOARD )

      nRow := Row()
      nCol := Col()

      nOldCursor := SetCursor( SC_NONE )

      DispOutAt( SCORE_ROW, SCORE_COL, iif( Set( _SET_INSERT ), __NatMsg( _GET_INSERT_ON ), __NatMsg( _GET_INSERT_OFF ) ) )
      SetPos( nRow, nCol )

      SetCursor( nOldCursor )

   ENDIF

   RETURN Self

METHOD DateMsg() CLASS HBGetList

   LOCAL nRow
   LOCAL nCol

   IF Set( _SET_SCOREBOARD )

      nRow := Row()
      nCol := Col()

      DispOutAt( SCORE_ROW, SCORE_COL, __NatMsg( _GET_INVD_DATE ) )
      SetPos( nRow, nCol )

      DO WHILE NextKey() == 0
      ENDDO

      DispOutAt( SCORE_ROW, SCORE_COL, Space( Len( __NatMsg( _GET_INVD_DATE ) ) ) )
      SetPos( nRow, nCol )

   ENDIF

   RETURN Self

METHOD ReadVar( cNewVarName ) CLASS HBGetList

   LOCAL cOldName := ::cVarName

   IF ISCHARACTER( cNewVarName )
      ::cVarName := cNewVarName
   ENDIF

   RETURN cOldName

METHOD ReadUpdated( lUpdated ) CLASS HBGetList

   LOCAL lSavUpdated := ::lUpdated

   IF PCount() > 0
      ::lUpdated := lUpdated
   ENDIF

   RETURN lSavUpdated

#ifdef HB_COMPAT_C53

METHOD GUIReader( oGet, oMenu, aMsg ) CLASS HBGetList

   LOCAL oGUI

   IF ISOBJECT( oGet:control ) .AND. ;
      ::nLastExitState == GE_SHORTCUT .OR. ;
      ::nLastExitState == GE_MOUSEHIT .OR. ;
      ::GetPreValidate( oGet, aMsg )

      ::ShowGetMsg( oGet, aMsg )

      ::nLastExitState := 0

      // Activate the GET for reading
      oGUI := oGet:control
      oGUI:Select( oGet:varGet() )
      oGUI:setFocus()

      IF oGet:exitState == GE_NOEXIT  // Added.
         IF ::nHitCode > 0
            oGUI:Select( ::nHitCode )
         ELSEIF ::nHitCode == HTCAPTION
            oGUI:Select()
         ELSEIF ::nHitCode == HTCLIENT
            oGUI:Select( K_LBUTTONDOWN )
         ELSEIF ::nHitCode == HTDROPBUTTON
            oGUI:Open()
         ELSEIF ::nHitCode >= HTSCROLLFIRST .AND. ;
                ::nHitCode <= HTSCROLLLAST
            oGUI:Scroll( ::nHitCode )
         ENDIF
      ENDIF

      ::nHitCode := 0

      DO WHILE oGet:exitState == GE_NOEXIT .AND. !::lKillRead

         // Check for initial typeout (no editable positions)
         IF oGUI:typeOut
            oGet:exitState := GE_ENTER
         ENDIF

         // Apply keystrokes until exit
         DO WHILE oGet:exitState == GE_NOEXIT .AND. !::lKillRead
            ::GUIApplyKey( oGet, oGUI, Inkey( 0 ), oMenu, aMsg )

            ::ShowGetMsg( oGet, aMsg )
         ENDDO

         IF ::nLastExitState != GE_SHORTCUT .AND. ;
            ::nLastExitState != GE_MOUSEHIT .AND. ;
            !::GetPostValidate( oGet, aMsg )
            oGet:exitState := GE_NOEXIT
         ENDIF
      ENDDO

      // De-activate the GET
      IF oGUI:ClassName() $ "LISTBOX|RADIOGROUP" .AND. ISNUMBER( oGet:varGet() )
         oGet:varPut( oGUI:value )
      ELSE
         oGet:varPut( oGUI:buffer )
      ENDIF
      oGUI:killFocus()

      ::EraseGetMsg( aMsg )

      IF oGUI:ClassName() == "LISTBOX" .AND. ;
         oGUI:dropDown .AND. ;
         oGUI:isOpen 

         oGUI:Close()
      ENDIF

   ENDIF

   RETURN Self

METHOD GUIApplyKey( oGet, oGUI, nKey, oMenu, aMsg ) CLASS HBGetList

   LOCAL bKeyBlock
   LOCAL oTheClass
   LOCAL nHotItem
   LOCAL lClose
   LOCAL nMRow
   LOCAL nMCol
   LOCAL nButton
   LOCAL lSetKey

   // Check for SET KEY first
   IF ( bKeyBlock := SetKey( nKey ) ) != NIL
      IF ( lSetKey := ::GetDoSetKey( bKeyBlock, oGet ) )
         RETURN Self
      ENDIF
   ENDIF

   IF ( nHotItem := ::Accelerator( nKey, aMsg ) ) != 0
      oGet:exitState := GE_SHORTCUT
      ::nNextGet := nHotItem
   ELSEIF !ISOBJECT( oMenu )
   ELSEIF ( nHotItem := oMenu:getAccel( nKey ) ) != 0
      ::nMenuID := MenuModal( oMenu, nHotItem, aMsg[ MSGROW ], aMsg[ MSGLEFT ], aMsg[ MSGRIGHT ], aMsg[ MSGCOLOR ] )
      nKey := 0
   ELSEIF IsShortCut( oMenu, nKey )
      nKey := 0
   ENDIF

   IF nKey == 0
   ELSEIF ( oTheClass := oGUI:ClassName() ) == "RADIOGROUP"
      IF nKey == K_UP
         oGUI:PrevItem()
         nKey := 0

      ELSEIF nKey == K_DOWN
         oGUI:NextItem()
         nKey := 0

      ELSEIF ( nHotItem := oGUI:getAccel( nKey ) ) != 0
         oGUI:Select( nHotItem )

      ENDIF

      IF ISNUMBER( oGet:varGet() )
         oGet:varPut( oGUI:Value )
      ENDIF

   ELSEIF oTheClass == "CHECKBOX"
      IF nKey == K_SPACE
         oGUI:Select()
      ENDIF

   ELSEIF oTheClass == "PUSHBUTTON"
      IF nKey == K_SPACE
         oGUI:Select( K_SPACE )

      ELSEIF nKey == K_ENTER
         oGUI:Select()
         nKey := 0

      ENDIF

   ELSEIF oTheClass == "LISTBOX"
      IF nKey == K_UP
         oGUI:PrevItem()
         nKey := 0

      ELSEIF nKey == K_DOWN
         oGUI:NextItem()
         nKey := 0

      ELSEIF nKey == K_SPACE
         IF ! oGUI:DropDown
         ELSEIF ! oGUI:IsOpen
            oGUI:Open()
            nKey := 0
         ENDIF

      ELSEIF ( nButton := oGUI:FindText( chr(nKey), oGUI:Value + 1, .F., .F. ) ) != 0
         oGUI:Select( nButton )

      ENDIF

      IF ISNUMBER( oGet:varGet() )
         oGet:varPut( oGUI:Value )
      ENDIF

   ENDIF

   DO CASE
   CASE nKey == K_UP
      oGet:exitState := GE_UP

   CASE nKey == K_SH_TAB
      oGet:exitState := GE_UP

   CASE nKey == K_DOWN
      oGet:exitState := GE_DOWN

   CASE nKey == K_TAB
      oGet:exitState := GE_DOWN

   CASE nKey == K_ENTER
      oGet:exitState := GE_ENTER

   CASE nKey == K_ESC
      IF Set( _SET_ESCAPE )
         oGet:exitState := GE_ESCAPE
      ENDIF

   CASE nKey == K_PGUP
      oGet:exitState := GE_WRITE

   CASE nKey == K_PGDN
      oGet:exitState := GE_WRITE

   CASE nKey == K_CTRL_HOME
      oGet:exitState := GE_TOP


#ifdef CTRL_END_SPECIAL

   // Both ^W and ^End go to the last GET
   CASE nKey == K_CTRL_END
      oGet:exitState := GE_BOTTOM

#else

   // Both ^W and ^End terminate the READ (the default)
   CASE nKey == K_CTRL_W
      oGet:exitState := GE_WRITE

#endif

   CASE nKey == K_LBUTTONDOWN .OR. nKey == K_LDBLCLK

      nMRow := MRow()
      nMCol := MCol()

      IF !ISOBJECT( oMenu )
         nButton := 0
      ELSEIF !( oMenu:ClassName() == "TOPBARMENU" )
         nButton := 0
      ELSEIF ( nButton := oMenu:hitTest( nMRow, nMCol ) ) != 0
         ::nMenuID := MenuModal( oMenu, nHotItem, aMsg[ MSGROW ], aMsg[ MSGLEFT ], aMsg[ MSGRIGHT ], aMsg[ MSGCOLOR ] )
         nButton := 1
      ENDIF

      lClose := .T.

      IF nButton != 0
      ELSEIF ( nButton := oGUI:hitTest( nMRow, nMCol ) ) == HTNOWHERE
         IF ::HitTest( nMRow, nMCol, aMsg ) != 0
            oGet:exitState := GE_MOUSEHIT
            ::nLastExitState := GE_MOUSEHIT
         ELSE
            oGet:exitState := GE_NOEXIT
         ENDIF

      ELSEIF nButton >= HTCLIENT
         oGUI:Select( nButton )

      ELSEIF nButton == HTDROPBUTTON
         IF !oGUI:IsOpen
            oGUI:Open()
            lClose := .F.
         ENDIF

      ELSEIF nButton >= HTSCROLLFIRST .AND. nButton <= HTSCROLLLAST
         oGUI:Scroll( nButton )
         lClose := .F.

      ENDIF

      IF ! lClose
      ELSEIF ! oTheClass == "LISTBOX"
      ELSEIF ! oGUI:DropDown
      ELSEIF oGUI:IsOpen
         oGUI:Close()
         oGUI:Display()
      ENDIF

   ENDCASE

   RETURN Self

METHOD GUIPreValidate( oGet, oGUI, aMsg ) CLASS HBGetList

   LOCAL lUpdated
   LOCAL lWhen := .T.

   DEFAULT oGet TO ::oGet

   IF oGet:preBlock != NIL

      lUpdated := ::lUpdated

      lWhen := Eval( oGet:preBlock, oGet, aMsg )

      IF !( oGUI:ClassName() == "TBROWSE" )
         oGet:display()
      ENDIF

      ::ShowScoreBoard()
      ::lUpdated := lUpdated

      __GetListLast( Self )
   ENDIF

   IF ::lKillRead
      lWhen := .F.
      oGet:exitState := GE_ESCAPE
   ELSEIF !lWhen
      oGet:exitState := GE_WHEN
   ELSE
      oGet:exitState := GE_NOEXIT
   ENDIF

   RETURN lWhen

METHOD GUIPostValidate( oGet, oGUI, aMsg ) CLASS HBGetList

   LOCAL lUpdated
   LOCAL lValid := .T.
   LOCAL xOldValue
   LOCAL xNewValue

   DEFAULT oGet TO ::oGet

   IF oGet:exitState == GE_ESCAPE
      RETURN .T.                   // NOTE
   ENDIF

   IF !( oGUI:ClassName() == "TBROWSE" )
      xOldValue := oGet:varGet()
      IF oGUI:ClassName() $ "LISTBOX|RADIOGROUP" .AND. ISNUMBER( oGet:varGet() )
         xNewValue := oGUI:Value
      ELSE
         xNewValue := oGUI:Buffer
      ENDIF
   ENDIF

   IF !( xOldValue == xNewValue )
      oGet:varPut( xNewValue )
      ::lUpdated := .T.
   ENDIF

   // Check VALID condition if specified
   IF oGet:postBlock != NIL

      lUpdated := ::lUpdated

      lValid := Eval( oGet:postBlock, oGet, aMsg )

      // Reset S'87 compatibility cursor position
      SetPos( oGet:row, oGet:col )

      ::ShowScoreBoard()
      IF ! ( oGUI:ClassName == "TBROWSE" )
         oGUI:Select( oGet:varGet() )
      ENDIF

      ::lUpdated := lUpdated

      __GetListLast( Self )

      IF ::lKillRead
         oGet:exitState := GE_ESCAPE      // Provokes ReadModal() exit
         lValid := .T.
      ENDIF

   ENDIF

   RETURN lValid 

METHOD TBApplyKey( oGet, oTB, nKey, oMenu, aMsg ) CLASS HBGetList

   LOCAL bKeyBlock
   LOCAL nMRow
   LOCAL nMCol
   LOCAL nButton
   LOCAL nHotItem
   LOCAL lSetKey

   // Check for SET KEY first
   IF ( bKeyBlock := SetKey( nKey ) ) != NIL
      IF ( lSetKey := ::GetDoSetKey( bKeyBlock, oGet ) )
         RETURN Self
      ENDIF
   ENDIF

   IF ( nHotItem := ::Accelerator( nKey, aMsg ) ) != 0
      oGet:exitState := GE_SHORTCUT
      ::nNextGet := nHotItem
   ELSEIF !ISOBJECT( oMenu )
   ELSEIF ( nHotItem := oMenu:getAccel( nKey ) ) != 0
      ::nMenuID := MenuModal( oMenu, nHotItem, aMsg[ MSGROW ], aMsg[ MSGLEFT ], aMsg[ MSGRIGHT ], aMsg[ MSGCOLOR ] )
      nKey := 0
   ELSEIF IsShortCut( oMenu, nKey )
      nKey := 0
   ENDIF

   DO CASE
   CASE nKey == K_TAB 
      oGet:exitState := GE_DOWN

   CASE nKey == K_SH_TAB
      oGet:exitState := GE_UP

   CASE nKey == K_ENTER
#ifndef HB_C52_STRICT
      IF !oTb:Stable()
         oTb:ForceStable()
      ENDIF
#endif
      oGet:exitState := GE_ENTER

   CASE nKey == K_ESC 
      IF Set( _SET_ESCAPE )
         oGet:exitState := GE_ESCAPE
      ENDIF

#ifdef CTRL_END_SPECIAL

   // Both ^W and ^End go to the last GET
   CASE nKey == K_CTRL_END
      oGet:exitState := GE_BOTTOM

#else

   // Both ^W and ^End terminate the READ (the default)
   CASE nKey == K_CTRL_W
      oGet:exitState := GE_WRITE

#endif

   CASE nKey == K_LBUTTONDOWN .OR. nKey == K_LDBLCLK

      nMRow := MRow()
      nMCol := MCol()

      IF !ISOBJECT( oMenu )
         nButton := 0
      ELSEIF !( oMenu:ClassName() == "TOPBARMENU" )
         nButton := 0
      ELSEIF ( nButton := oMenu:hitTest( nMRow, nMCol ) ) != 0
         ::nMenuID := MenuModal( oMenu, nHotItem, aMsg[ MSGROW ], aMsg[ MSGLEFT ], aMsg[ MSGRIGHT ], aMsg[ MSGCOLOR ] )
         nButton := 1
      ENDIF

      IF nButton != 0
      ELSEIF ( nButton := oTB:hitTest( nMRow, nMCol ) ) == HTNOWHERE
         IF ::hitTest( nMRow, nMCol, aMsg ) != 0
            oGet:exitState := GE_MOUSEHIT
            ::nLastExitState := GE_MOUSEHIT
         ELSE
            oGet:exitState := GE_NOEXIT
         ENDIF
      ENDIF

   ENDCASE

   RETURN Self

METHOD TBReader( oGet, oMenu, aMsg ) CLASS HBGetList

   LOCAL oTB
   LOCAL nKey
   LOCAL lAutoLite
   LOCAL nSaveCursor
   LOCAL nProcessed
// LOCAL oGUI := oGet:control

   // Read the GET if the WHEN condition is satisfied
   IF ISOBJECT( oGet:control ) .AND. ;
      ::nLastExitState == GE_SHORTCUT .OR. ;
      ::nLastExitState == GE_MOUSEHIT .OR. ;
      ::GetPreValidate( oGet, aMsg )

      ::ShowGetMsg( oGet, aMsg )
      ::nLastExitState := 0

      nSaveCursor := SetCursor( SC_NONE )

      // Activate the GET for reading
      oTB := oGet:control

      lAutoLite := oTB:Autolite
      oTB:Autolite := .T.
      oTB:Hilite()

      IF oGet:exitState == GE_NOEXIT
         IF ::nHitcode == HTCELL
            // Replaces call to TBMouse( oTB, mROW(), mCOL() ):
            oTB:RowPos := oTb:mRowPos
            oTB:ColPos := oTb:mColPos
            oTB:Invalidate()
         ENDIF
      ENDIF

      ::nHitcode := 0

      DO WHILE oGet:exitState == GE_NOEXIT .AND. !::lKillRead

         // Apply keystrokes until exit
         DO WHILE oGet:exitState == GE_NOEXIT .AND. !::lKillRead
            nKey := 0

            DO WHILE !oTB:Stabilize() .AND. nKey == 0
               nKey := Inkey()
            ENDDO

            IF nKey == 0
               nKey := Inkey(0)
            ENDIF

            nProcessed := oTB:ApplyKey( nKey )
            IF nProcessed == TBR_EXIT
               oGet:exitState := GE_ESCAPE
               EXIT

            ELSEIF nProcessed == TBR_EXCEPTION
               ::TBApplyKey( oGet, oTB, nKey, oMenu, aMsg )

               ::ShowGetMsg( oGet, aMsg )

            ENDIF

         ENDDO

         // Disallow exit if the VALID condition is not satisfied
         IF ::nLastExitState == GE_SHORTCUT
         ELSEIF ::nLastExitState == GE_MOUSEHIT
         ELSEIF !::GetPostValidate( oGet, aMsg )
            oGet:exitState := GE_NOEXIT
         ENDIF

      ENDDO

      // De-activate the GET
      oTB:Autolite := lAutoLite
      oTB:DeHilite()

      ::EraseGetMsg( aMsg )

      SetCursor( nSaveCursor )
   ENDIF

   RETURN Self

METHOD Accelerator( nKey, aMsg ) CLASS HBGetList

   LOCAL nGet
   LOCAL oGet
   LOCAL nHotPos
   LOCAL cKey
   LOCAL cCaption
   LOCAL nStart
   LOCAL nEnd
   LOCAL nIteration
   LOCAL lGUI

   IF nKey >= K_ALT_Q .AND. nKey <= K_ALT_P
      cKey := SubStr( "qwertyuiop", nKey - K_ALT_Q + 1, 1 )

   ELSEIF nKey >= K_ALT_A .AND. nKey <= K_ALT_L
      cKey := SubStr( "asdfghjkl", nKey - K_ALT_A + 1, 1 )

   ELSEIF nKey >= K_ALT_Z .AND. nKey <= K_ALT_M
      cKey := SubStr( "zxcvbnm", nKey - K_ALT_Z + 1, 1 )

   ELSEIF nKey >= K_ALT_1 .AND. nKey <= K_ALT_0
      cKey := SubStr( "1234567890", nKey - K_ALT_1 + 1, 1 )

   ELSE
      RETURN 0

   ENDIF

   nStart := ::nPos + 1
   nEnd   := Len( ::aGetList )

   FOR nIteration := 1 TO 2
      FOR nGet := nStart TO nEnd

         oGet  := ::aGetList[ nGet ]

         IF ISOBJECT( oGet:control ) .AND. ;
            !( oGet:Control:ClassName() == "TBROWSE" )

            cCaption := oGet:control:caption
         ELSE
            cCaption := oGet:caption
         ENDIF

         IF ( nHotPos := At( "&", cCaption ) ) == 0
         ELSEIF nHotPos == Len( cCaption )
         ELSEIF Lower( SubStr( cCaption, nHotPos + 1, 1 ) ) == cKey

            // Test the current GUI-GET or Get PostValidation:
            lGUI := ISOBJECT( ::aGetList[ ::nPos ]:control )

            IF lGUI .AND. !::GUIPostValidate( ::aGetList[ ::nPos ], ::aGetList[ ::nPos ]:control, aMsg )
               RETURN 0

            ELSEIF !lGUI .AND. !::GetPostValidate( ::aGetList[ ::nPos ], aMsg )
               RETURN 0

            ENDIF
      
            // Test the next GUI-GET or Get PreValidation:
            lGUI := ISOBJECT( oGet:control )

            IF lGUI .AND. !::GUIPreValidate( oGet, oGet:control, aMsg )
               // RETURN 0  // Commented out.
               RETURN nGet  // Changed.

            ELSEIF !lGUI .AND. !::GetPreValidate( oGet, aMsg )
               // RETURN 0  // Commented out.
               RETURN nGet  // Changed.

            ENDIF

            RETURN nGet
         ENDIF
      NEXT

      nStart := 1
      nEnd   := ::nPos - 1
   NEXT

   RETURN 0

METHOD HitTest( nMRow, nMCol, aMsg ) CLASS HBGetList

   LOCAL nCount
   LOCAL nTotal := Len( ::aGetList )
   LOCAL lGUI

   ::nNextGet := 0

   FOR nCount := 1 TO nTotal
      IF ( ::nHitCode := ::aGetList[ nCount ]:hitTest( nMRow, nMCol ) ) != HTNOWHERE
         ::nNextGet := nCount
         EXIT
      ENDIF
   NEXT

   // DO WHILE ::nNextGet != 0  // Commented out.

   IF ::nNextGet != 0  // Changed.

      // Test the current GUI-GET or Get PostValidation:
      lGUI := ISOBJECT( ::aGetList[ ::nPos ]:control )

      IF lGUI .AND. !::GUIPostValidate( ::aGetList[ ::nPos ], ::aGetList[ ::nPos ]:control, aMsg )

         ::nNextGet := 0
         // EXIT  // Commented out.
         RETURN 0  // Changed.

      ELSEIF !lGUI .AND. !::GetPostValidate( ::aGetList[ ::nPos ], aMsg )

         ::nNextGet := 0
         // EXIT  // Commented out.
         RETURN 0  // Changed.

      ENDIF
      
      // Test the next GUI-GET or Get PreValidation:
      lGUI := ISOBJECT( ::aGetList[ ::nNextGet ]:control )

      IF lGUI .AND. !::GUIPreValidate( ::aGetList[ ::nNextGet ], ::aGetList[ ::nNextGet ]:control, aMsg )

         ::nNextGet := 0
         // EXIT  // Commented out.
         RETURN ::nNextGet  // Changed.

      ELSEIF !lGUI .AND. !::GetPreValidate( ::aGetList[ ::nNextGet ], aMsg )

         ::nNextGet := 0
         // EXIT  // Commented out.
         RETURN ::nNextGet  // Changed.

      ENDIF

      // EXIT  // Commented out.
      RETURN ::nNextGet  // Changed.
   // ENDDO  // Commented out.

   ENDIF

   // RETURN ::nNextGet != 0  // Commented out.
   RETURN 0

#endif

#define SLUPDATED       1
#define SBFORMAT        2
#define SLKILLREAD      3
#define SLBUMPTOP       4
#define SLBUMPBOT       5
#define SNLASTEXIT      6
#define SNLASTPOS       7
#define SOACTIVEGET     8
#define SXREADVAR       9
#define SCREADPROCNAME  10
#define SNREADPROCLINE  11
#define SNNEXTGET       12
#define SNHITCODE       13
#define SNPOS           14
#define SCSCRSVMSG      15
#define SNMENUID        16
#define SNSVCURSOR      17

METHOD ReadStats( nElement, xNewValue ) CLASS HBGetList
   LOCAL xRetVal

   DO CASE
   CASE nElement == SLUPDATED      ; xRetVal := ::lUpdated
   CASE nElement == SBFORMAT       ; xRetVal := ::bFormat
   CASE nElement == SLKILLREAD     ; xRetVal := ::lKillRead
   CASE nElement == SLBUMPTOP      ; xRetVal := ::lBumpTop
   CASE nElement == SLBUMPBOT      ; xRetVal := ::lBumpBot
   CASE nElement == SNLASTEXIT     ; xRetVal := ::nLastExitState
   CASE nElement == SNLASTPOS      ; xRetVal := ::nLastPos
   CASE nElement == SOACTIVEGET    ; xRetVal := ::oActiveGet
   CASE nElement == SXREADVAR      ; xRetVal := ::cVarName
   CASE nElement == SCREADPROCNAME ; xRetVal := ::cReadProcName
   CASE nElement == SNREADPROCLINE ; xRetVal := ::nReadProcLine
   CASE nElement == SNNEXTGET      ; xRetVal := ::nNextGet     
   CASE nElement == SNHITCODE      ; xRetVal := ::nHitCode     
   CASE nElement == SNPOS          ; xRetVal := ::nPos
   CASE nElement == SCSCRSVMSG     ; xRetVal := ::cMsgSaveS  
   CASE nElement == SNMENUID       ; xRetVal := ::nMenuID    
   CASE nElement == SNSVCURSOR     ; xRetVal := ::nSaveCursor
   OTHERWISE                       ; xRetVal := NIL
   ENDCASE

   IF PCount() > 1

      DO CASE
      CASE nElement == SLUPDATED      ; ::lUpdated       := xNewValue
      CASE nElement == SBFORMAT       ; ::bFormat        := xNewValue
      CASE nElement == SLKILLREAD     ; ::lKillRead      := xNewValue
      CASE nElement == SLBUMPTOP      ; ::lBumpTop       := xNewValue
      CASE nElement == SLBUMPBOT      ; ::lBumpBot       := xNewValue
      CASE nElement == SNLASTEXIT     ; ::nLastExitState := xNewValue
      CASE nElement == SNLASTPOS      ; ::nLastPos       := xNewValue
      CASE nElement == SOACTIVEGET    ; ::oActiveGet     := xNewValue
      CASE nElement == SXREADVAR      ; ::xReadVar       := xNewValue
      CASE nElement == SCREADPROCNAME ; ::cReadProcName  := xNewValue
      CASE nElement == SNREADPROCLINE ; ::nReadProcLine  := xNewValue
      CASE nElement == SNNEXTGET      ; ::nNextGet       := xNewValue
      CASE nElement == SNHITCODE      ; ::nHitCode       := xNewValue
      CASE nElement == SNPOS          ; ::nPos           := xNewValue
      CASE nElement == SCSCRSVMSG     ; ::cMsgSaveS      := xNewValue
      CASE nElement == SNMENUID       ; ::nMenuID        := xNewValue
      CASE nElement == SNSVCURSOR     ; ::nSaveCursor    := xNewValue
      ENDCASE
   ENDIF

   RETURN xRetVal

METHOD ShowGetMsg( oGet, aMsg ) CLASS HBGetList

#ifdef HB_COMPAT_C53
   LOCAL cMsg
   LOCAL lMOldState

   IF !Empty( aMsg ) .AND. aMsg[ MSGFLAG ]

      DEFAULT oGet TO ::oGet

      cMsg := iif( ISOBJECT( oGet:control ), oGet:control:message, oGet:message )

      IF !Empty( cMsg )
         lMOldState := MSetCursor( .F. )
         DispOutAt( aMsg[ MSGROW ], aMsg[ MSGLEFT ], PadC( cMsg, aMsg[ MSGRIGHT ] - aMsg[ MSGLEFT ] + 1 ), aMsg[ MSGCOLOR ] )
         MSetCursor( lMOldState )
      ENDIF
   ENDIF
#else
   HB_SYMBOL_UNUSED( oGet )
   HB_SYMBOL_UNUSED( aMsg )
#endif

   RETURN Self

METHOD EraseGetMsg( aMsg ) CLASS HBGetList

#ifdef HB_COMPAT_C53
   LOCAL nRow := Row()
   LOCAL nCol := Col()
   LOCAL lMOldState

   IF !Empty( aMsg ) .AND. aMsg[ MSGFLAG ]
      lMOldState := MSetCursor( .F. )
      RestScreen( aMsg[ MSGROW ], aMsg[ MSGLEFT ], aMsg[ MSGROW ], aMsg[ MSGRIGHT ], ::cMsgSaveS )
      MSetCursor( lMOldState )
   ENDIF

   SetPos( nRow, nCol )
#else
   HB_SYMBOL_UNUSED( aMsg )
#endif

   RETURN Self

/* -------------------------------------------- */

METHOD New( GetList ) CLASS HBGetList

   ::aGetList := GetList

   IF ISARRAY( GetList ) .AND. Len( GetList ) >= 1
      ::oGet := GetList[ 1 ]
   ENDIF

   RETURN Self
