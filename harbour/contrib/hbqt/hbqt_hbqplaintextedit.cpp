/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Harbour-Qt wrapper generator.
 *
 * Copyright 2010 Pritpal Bedi <pritpal@vouchcac.com>
 * Copyright 2009 Gancov Kostya <kossne@mail.ru>
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
/*----------------------------------------------------------------------*/
/*
 *  The code below is puled from TextEdit.cpp of QWriter by Gancov Kotsya
 *
 *  and adopted for Harbour's hbIDE interface. The code has been intensively
 *  formatted and changed to suit hbIDE and Harbour's wrappers for Qt.
 *  The special hilight for this adoption is <braces matching>, current line
 *  coloring and bookmarks.
 *
 *  So a big thank you.
 *
 *  Pritpal Bedi
*/
/*----------------------------------------------------------------------*/

#include "hbqt.h"

#include "hbapiitm.h"
#include "hbthread.h"
#include "hbvm.h"

#if QT_VERSION >= 0x040500

#include "hbqt_hbqplaintextedit.h"

#define selectionState_off                        0
#define selectionState_on                         1

#define selectionMode_none                        0
#define selectionMode_stream                      1
#define selectionMode_column                      2
#define selectionMode_line                        3

#define selectionDisplay_none                     0
#define selectionDisplay_qt                       1
#define selectionDisplay_ide                      2

/*----------------------------------------------------------------------*/

HBQPlainTextEdit::HBQPlainTextEdit( QWidget * parent ) : QPlainTextEdit( parent )
{
   m_currentLineColor.setNamedColor( "#e8e8ff" );
   m_lineAreaBkColor.setNamedColor( "#e4e4e4" );
   m_horzRulerBkColor.setNamedColor( "whitesmoke" );
   m_matchBracesAll         = false;

   spaces                   = 3;
   spacesTab                = "";
   styleHightlighter        = "prg";
   numberBlock              = true;
   lineNumberArea           = new LineNumberArea( this );
   isTipActive              = false;
   columnBegins             = -1;
   columnEnds               = -1;
   rowBegins                = -1;
   rowEnds                  = -1;
   selectionState           = selectionState_off;
   selectionMode            = selectionMode_none;
   selectionDisplay         = selectionDisplay_none;
   isColumnSelectionEnabled = false;
   isLineSelectionON        = false;
   horzRuler                = new HorzRuler( this );

   connect( this, SIGNAL( blockCountChanged( int ) )           , this, SLOT( hbUpdateLineNumberAreaWidth( int ) ) );
   connect( this, SIGNAL( updateRequest( const QRect &, int ) ), this, SLOT( hbUpdateLineNumberArea( const QRect &, int ) ) );

   hbUpdateLineNumberAreaWidth( 0 );

   connect( this, SIGNAL( cursorPositionChanged() )            , this, SLOT( hbSlotCursorPositionChanged() ) );
   connect( this, SIGNAL( cursorPositionChanged() )            , this, SLOT( hbUpdateHorzRuler() ) );

   horzRuler->setFrameShape( QFrame::Panel );
   horzRuler->setFrameShadow( QFrame::Sunken );

   QPalette pl( QPlainTextEdit::palette() );
   m_selectionColor = pl.color( QPalette::Highlight );

}

/*----------------------------------------------------------------------*/

HBQPlainTextEdit::~HBQPlainTextEdit()
{
   disconnect( this, SIGNAL( blockCountChanged( int ) )            );
   disconnect( this, SIGNAL( updateRequest( const QRect &, int ) ) );
   disconnect( this, SIGNAL( cursorPositionChanged() )             );

   delete lineNumberArea;

   if( block )
      hb_itemRelease( block );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbSetEventBlock( PHB_ITEM pBlock )
{
   if( pBlock )
      block = hb_itemNew( pBlock );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbRefresh()
{
   update();
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbShowPrototype( const QString & tip )
{
   if( tip == ( QString ) "" )
   {
      QToolTip::hideText();
      isTipActive = false;
   }
   else
   {
      QRect r = HBQPlainTextEdit::cursorRect();
      QToolTip::showText( mapToGlobal( QPoint( r.x(), r.y()+20 ) ), tip );
      isTipActive = true;
   }
}

/*----------------------------------------------------------------------*/

bool HBQPlainTextEdit::event( QEvent *event )
{
   if( event->type() == QEvent::KeyPress )
   {
      QKeyEvent *keyEvent = ( QKeyEvent * ) event;
      if( ( keyEvent->key() == Qt::Key_Tab ) && ( keyEvent->modifiers() & Qt::ControlModifier ) )
      {
         return false;
      }
      else
      {
         if( ( keyEvent->key() == Qt::Key_Tab ) && !( keyEvent->modifiers() & Qt::ControlModifier & Qt::AltModifier & Qt::ShiftModifier ) )
         {
            this->hbInsertTab( 0 );
            return true;
         }
         else if( ( keyEvent->key() == Qt::Key_Backtab ) && ( keyEvent->modifiers() & Qt::ShiftModifier ) )
         {
            this->hbInsertTab( 1 );
            return true;
         }
      }
   }
   else if( event->type() == QEvent::ToolTip )
   {
      event->ignore();
      #if 0
      QHelpEvent * helpEvent = static_cast<QHelpEvent *>( event );

      if( helpEvent && isTipActive )
      {
         event->ignore();
      }
      #endif
      return false;//true;
   }

   return QPlainTextEdit::event( event );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbSetSelectionColor( const QColor & color )
{
   m_selectionColor = color;

   QPalette pl( QPlainTextEdit::palette() );
   pl.setColor( QPalette::Highlight, m_selectionColor );
   pl.setColor( QPalette::HighlightedText, QColor( 0,0,0 ) );
   setPalette( pl );
}

/*----------------------------------------------------------------------*/

static bool isNavableKey( int k )
{
   return ( k == Qt::Key_Right || k == Qt::Key_Left || k == Qt::Key_Up     || k == Qt::Key_Down     ||
            k == Qt::Key_Home  || k == Qt::Key_End  || k == Qt::Key_PageUp || k == Qt::Key_PageDown );
}

/*----------------------------------------------------------------------*/

bool HBQPlainTextEdit::isCursorInSelection()
{
   int cb = columnBegins <= columnEnds ? columnBegins : columnEnds;
   int ce = columnBegins <= columnEnds ? columnEnds   : columnBegins;
   int rb = rowBegins    <= rowEnds    ? rowBegins    : rowEnds;
   int re = rowBegins    <= rowEnds    ? rowEnds      : rowBegins;

   QTextCursor c = textCursor();
   int col = c.columnNumber();
   int row = c.blockNumber();

   return( col >= cb && col <= ce && row >= rb && row <= re );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbClearColumnSelection()
{
   setCursorWidth( 1 );

   rowBegins    = -1;
   rowEnds      = -1;
   columnBegins = -1;
   columnEnds   = -1;
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbSetSelectionInfo( PHB_ITEM selectionInfo )
{
   rowBegins     = hb_arrayGetNI( selectionInfo, 1 );
   rowEnds       = hb_arrayGetNI( selectionInfo, 2 );
   columnBegins  = hb_arrayGetNI( selectionInfo, 3 );
   columnEnds    = hb_arrayGetNI( selectionInfo, 4 );
   selectionMode = hb_arrayGetNI( selectionInfo, 5 );

   update();
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbGetSelectionInfo()
{
   PHB_ITEM p1 = hb_itemPutNI( NULL, 21000 );
   PHB_ITEM p2 = hb_itemNew( NULL );

   hb_arrayNew( p2, 6 );

   hb_arraySetNI( p2, 1, rowBegins      );
   hb_arraySetNI( p2, 2, columnBegins   );
   hb_arraySetNI( p2, 3, rowEnds        );
   hb_arraySetNI( p2, 4, columnEnds     );
   hb_arraySetNI( p2, 5, selectionMode  );
   hb_arraySetNI( p2, 6, selectionState );

   hb_vmEvalBlockV( block, 2, p1, p2 );
   hb_itemRelease( p1 );
   hb_itemRelease( p2 );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbHighlightSelectedColumns( bool yes )
{
   hbSetSelectionMode( ( yes ? selectionMode_column : selectionMode_stream ), true );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbSetSelectionMode( int mode, bool on )
{
   switch( mode )
   {
      case selectionMode_stream:
      {
         if( columnBegins >= 0 )
         {
            hbToStream();
         }
         selectionMode = selectionMode_stream;
         isColumnSelectionEnabled = false;
         isLineSelectionON = false;
         break;
      }
      case selectionMode_column:
      {
         selectionMode = selectionMode_column;
         isColumnSelectionEnabled = true;
         isLineSelectionON = false;
         break;
      }
      case selectionMode_line:
      {
         isColumnSelectionEnabled = false;
         if( on )
         {
            isLineSelectionON = true;
            hbClearColumnSelection();
            QTextCursor c( textCursor() );
            rowBegins    = c.blockNumber();
            rowEnds      = c.blockNumber();
            columnBegins = 0;
            columnEnds   = 0;
            selectionMode = selectionMode_line;
         }
         else
         {
            isLineSelectionON = false;
            selectionMode = selectionMode_stream;
         }

         break;
      }
      default:
      {
         selectionMode = selectionMode_none;
         hbClearColumnSelection();
      }
   }

   update();
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbToStream()
{
   int rb = rowBegins <= rowEnds ? rowBegins : rowEnds;
   int re = rowBegins <= rowEnds ? rowEnds   : rowBegins;

   if( selectionMode == selectionMode_line )
   {
      QTextCursor c = textCursor();

      c.movePosition( QTextCursor::Start                                            );
      c.movePosition( QTextCursor::Down     , QTextCursor::MoveAnchor, rb           );
      c.movePosition( QTextCursor::Right    , QTextCursor::MoveAnchor, columnBegins );
      c.movePosition( QTextCursor::Down     , QTextCursor::MoveAnchor, re - rb      );
      c.movePosition( QTextCursor::EndOfLine, QTextCursor::MoveAnchor               );
      int cce = c.columnNumber();
      if( cce > columnEnds )
      {
         c.movePosition( QTextCursor::StartOfLine, QTextCursor::MoveAnchor             );
         c.movePosition( QTextCursor::Right      , QTextCursor::MoveAnchor, columnEnds );
      }
      else
         columnEnds = cce;

      columnBegins = 0; rowBegins = rb; rowEnds = re;
      setTextCursor( c );
   }
   else if( selectionMode == selectionMode_column )
   {
      QTextCursor c = textCursor();

      c.movePosition( QTextCursor::Start );
      c.movePosition( QTextCursor::Down     , QTextCursor::MoveAnchor, re );
      c.movePosition( QTextCursor::EndOfLine, QTextCursor::MoveAnchor     );
      if( c.columnNumber() > columnEnds )
      {
         c.movePosition( QTextCursor::StartOfLine, QTextCursor::MoveAnchor             );
         c.movePosition( QTextCursor::Right      , QTextCursor::MoveAnchor, columnEnds );
      }
      columnEnds = c.columnNumber(); rowBegins = rb; rowEnds = re;
      setTextCursor( c );
   }
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbCut( int k )
{
   PHB_ITEM p1 = hb_itemPutNI( NULL, 21014 );
   PHB_ITEM p2 = hb_itemNew( NULL );

   hb_arrayNew( p2, 7 );
   hb_arraySetNI( p2, 1, rowBegins      );
   hb_arraySetNI( p2, 2, columnBegins   );
   hb_arraySetNI( p2, 3, rowEnds        );
   hb_arraySetNI( p2, 4, columnEnds     );
   hb_arraySetNI( p2, 5, selectionMode  );
   hb_arraySetNI( p2, 6, selectionState );
   hb_arraySetNI( p2, 7, k              );

   hb_vmEvalBlockV( block, 2, p1, p2 );
   hb_itemRelease( p1 );
   hb_itemRelease( p2 );

   if( selectionMode == selectionMode_column && k == 0 )
      columnEnds = columnBegins;
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbCopy()
{
   PHB_ITEM p1 = hb_itemPutNI( NULL, 21011 );
   PHB_ITEM p2 = hb_itemNew( NULL );

   hb_arrayNew( p2, 7 );
   hb_arraySetNI( p2, 1, rowBegins      );
   hb_arraySetNI( p2, 2, columnBegins   );
   hb_arraySetNI( p2, 3, rowEnds        );
   hb_arraySetNI( p2, 4, columnEnds     );
   hb_arraySetNI( p2, 5, selectionMode  );
   hb_arraySetNI( p2, 6, selectionState );
   hb_arraySetNI( p2, 7, 0              );

   hb_vmEvalBlockV( block, 2, p1, p2 );
   hb_itemRelease( p1 );
   hb_itemRelease( p2 );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbPaste()
{
   PHB_ITEM p1 = hb_itemPutNI( NULL, 21012 );
   PHB_ITEM p2 = hb_itemPutNI( NULL, selectionMode );
   hb_vmEvalBlockV( block, 1, p1, p2 );
   hb_itemRelease( p1 );
   hb_itemRelease( p2 );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::mouseDoubleClickEvent( QMouseEvent *event )
{
   if( block )
   {
      PHB_ITEM p1 = hb_itemPutNI( NULL, QEvent::MouseButtonDblClick );
      hb_vmEvalBlockV( block, 1, p1 );
      hb_itemRelease( p1 );
   }
   QPlainTextEdit::mouseDoubleClickEvent( event );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::mousePressEvent( QMouseEvent *event )
{
   selectionState = 1;
   setCursorWidth( 1 );
   QPlainTextEdit::mousePressEvent( event );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::mouseReleaseEvent( QMouseEvent *event )
{
   selectionState = 1;
   setCursorWidth( 1 );
   QPlainTextEdit::mouseReleaseEvent( event );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::mouseMoveEvent( QMouseEvent *event )
{
   if( isColumnSelectionEnabled )
      selectionMode = selectionMode_column;
   else
      selectionMode = selectionMode_stream;

   if( event->buttons() & Qt::LeftButton )
   {
      if( selectionState == 1 )
      {
         selectionState = 2;
         hbClearColumnSelection();
      }

      if( columnBegins == -1 )
      {
         if( isColumnSelectionEnabled )
            setCursorWidth( 0 );

         QTextCursor c( textCursor() );

         rowBegins    = c.blockNumber();
         columnBegins = c.columnNumber();
         rowEnds      = rowBegins;
         columnEnds   = columnBegins;

         emit selectionChanged();
      }
      else
      {
         if( isColumnSelectionEnabled )
         {
            QTextCursor c( cursorForPosition( QPoint( 1,1 ) ) );
            rowEnds    = c.blockNumber()  + ( event->y() / fontMetrics().height() );
            columnEnds = c.columnNumber() + ( event->x() / fontMetrics().averageCharWidth() );
         }
         QPlainTextEdit::mouseMoveEvent( event );
         QTextCursor c = textCursor();

         if( ! isColumnSelectionEnabled )
         {
            rowEnds    = c.blockNumber();
            columnEnds = c.columnNumber();
         }
         c.clearSelection();
         setTextCursor( c );
         event->accept();
         repaint();
      }
   }
}

/*----------------------------------------------------------------------*/

bool HBQPlainTextEdit::hbKeyPressColumnSelection( QKeyEvent * event )
{
   bool ctrl  = event->modifiers() & Qt::ControlModifier;
   bool shift = event->modifiers() & Qt::ShiftModifier;
   if( ctrl && shift )
      return false;

   int k = event->key();

   if( ctrl && ( k == Qt::Key_C || k == Qt::Key_V || k == Qt::Key_X ||
                 k == Qt::Key_A || k == Qt::Key_Z || k == Qt::Key_Y ) )
   {
      event->ignore();
      return true;
   }

   if( isColumnSelectionEnabled )
   {
      selectionMode = selectionMode_column;
   }
   else if( selectionMode != selectionMode_line )
   {
      selectionMode = selectionMode_stream;
   }

   bool bClear = false;

   if( selectionMode == selectionMode_column || selectionMode == selectionMode_stream )
   {
      QTextCursor c( textCursor() );
      int col = c.columnNumber();
      int row = c.blockNumber();

      if( shift && isNavableKey( k ) )
      {
         if( selectionState == 0 )
         {
            hbClearColumnSelection();
         }
         if( selectionMode == selectionMode_column )
            setCursorWidth( 0 );
         else
            setCursorWidth( 1 );

         if( columnBegins == -1 )
         {
            selectionState = 1;
            //
            rowBegins      = row;
            columnBegins   = col;
            rowEnds        = row;
            columnEnds     = col;
         }

         if( selectionMode == selectionMode_column )
         {
            switch( k )
            {
            case Qt::Key_Left:
               if( col == 0 )
               {
                  columnEnds--;
                  columnEnds = columnEnds < 0 ? 0 : columnEnds;
                  repaint();
                  event->ignore();
                  return true;
               }
               break;
            case Qt::Key_Right:
               c.movePosition( QTextCursor::EndOfLine, QTextCursor::MoveAnchor );
               if( c.columnNumber() <= columnEnds )
               {
                  columnEnds++;
                  #if 0    /* Tobe Matured */
                  int w = fontMetrics().averageCharWidth();
                  if( ( columnEnds * w ) > viewport()->width() )
                  {
                     int v = horizontalScrollBar()->value();
                     horizontalScrollBar()->setValue( v + w );
                     if( horizontalScrollBar()->value() == v )
                     {
                        horizontalScrollBar()->setMaximum( horizontalScrollBar()->maximum() + w );
                        horizontalScrollBar()->setValue( v + w );
                     }
                  }
                  #endif
                  repaint();
                  event->ignore();
                  return true;
               }
               break;
            }
         }

         c.clearSelection();
         setTextCursor( c );

         QKeyEvent * ev = new QKeyEvent( event->type(), event->key(), Qt::NoModifier, event->text() );
         QPlainTextEdit::keyPressEvent( ev );

         c   = textCursor();
         col = c.columnNumber();
         row = c.blockNumber();

         if( selectionMode == selectionMode_column )
         {
            switch( k )
            {
            case Qt::Key_Right:
               columnEnds++;
               break;
            case Qt::Key_Left:
               columnEnds--;
               columnEnds = columnEnds < 0 ? 0 : columnEnds;
               break;
            case Qt::Key_Up:
            case Qt::Key_PageUp:
            case Qt::Key_Down:
            case Qt::Key_PageDown:
               rowEnds = row;
               break;
            default:
               rowEnds    = row;
               columnEnds = col;
            }
         }
         else
         {
            rowEnds    = row;
            columnEnds = col;
         }
         update();
         event->ignore();
         return true;
      }                                 //   if( shift &&  isNavableKey( k ) )
      else if( selectionMode == selectionMode_column )
      {
         if( ! ctrl && k >= ' ' && k < 127 && columnBegins >= 0 )
         {
            if( ( columnBegins == columnEnds && selectionState > 0 ) || isCursorInSelection() )
            {
               PHB_ITEM p1 = hb_itemPutNI( NULL, 21013 );
               PHB_ITEM p2 = hb_itemNew( NULL );
               hb_arrayNew( p2, 7 );
               hb_arraySetNI( p2, 1, rowBegins      );
               hb_arraySetNI( p2, 2, columnBegins   );
               hb_arraySetNI( p2, 3, rowEnds        );
               hb_arraySetNI( p2, 4, columnEnds     );
               hb_arraySetNI( p2, 5, selectionMode  );
               hb_arraySetNI( p2, 6, selectionState );
               hb_arraySetPtr( p2, 7, event         );
               hb_vmEvalBlockV( block, 2, p1, p2 );
               hb_itemRelease( p1 );
               hb_itemRelease( p2 );

               if( columnBegins == columnEnds )
               {
                  columnBegins++;
                  columnEnds++;
               }
               repaint();
               event->ignore();
               return true;
            }
         }
         if( ! ctrl && ( k == Qt::Key_Backspace || k == Qt::Key_Delete ) && columnBegins >= 0  && selectionState > 0 )
         {
            hbCut( k );

            if( k == Qt::Key_Backspace )
            {
               columnBegins--;
               columnEnds--;
            }
            else
            {
               columnEnds = columnBegins;
            }
            repaint();
            event->ignore();
            return true;
         }
         else
         {
            bClear = true;
         }
      }
      else if( selectionMode == selectionMode_stream || selectionMode == selectionMode_line )
      {
         if( selectionState > 0 && ! ctrl && k == Qt::Key_Delete )
         {
            hbCut( k );
            repaint();
            selectionState = 0;
            event->ignore();
            return true;
         }
         else
         {
            bClear = true;
         }
      }
      else
      {
         bClear = true;
      }

      if( bClear )
      {
         if( selectionState > 0 )
         {
            emit selectionChanged();
         }
         setCursorWidth( 1 );
         selectionState = 0;
         if( columnEnds == columnBegins )
         {
            hbClearColumnSelection();
         }
      }
   }
   else if( selectionMode == selectionMode_line )
   {
      if( isLineSelectionON && ( k == Qt::Key_Up || k == Qt::Key_Down ) )
      {
         QPlainTextEdit::keyPressEvent( event );
         QTextCursor c( textCursor() );
         if( ( k == Qt::Key_Down && c.blockNumber() == rowEnds   + 1 ) ||
             ( k == Qt::Key_Up   && c.blockNumber() == rowBegins - 1 ) )
         {
            rowEnds = c.blockNumber();
         }
         event->ignore();
         update();
         return true;
      }
   }
   return false;
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::keyPressEvent( QKeyEvent * event )
{
   if( hbKeyPressColumnSelection( event ) )
   {
      return;
   }

   if( c && c->popup()->isVisible() )
   {
      // The following keys are forwarded by the completer to the widget
      switch( event->key() )
      {
      case Qt::Key_Enter:
      case Qt::Key_Return:
      case Qt::Key_Escape:
      case Qt::Key_Tab:
      case Qt::Key_Backtab:
         event->ignore();
         return;                                    // let the completer do default behavior
      case Qt::Key_Space:
         if( block )
         {
            PHB_ITEM p1 = hb_itemPutNI( NULL, 21001 );
            hb_vmEvalBlockV( block, 1, p1 );
            hb_itemRelease( p1 );
         }
         break;
      default:
         break;
      }
   }

   QPlainTextEdit::keyPressEvent( event );

   if( ! c )
      return;

   if( ( event->modifiers() & ( Qt::ControlModifier | Qt::AltModifier ) ) )
   {
      c->popup()->hide();
      return;
   }

   const bool ctrlOrShift = event->modifiers() & ( Qt::ControlModifier | Qt::ShiftModifier );
   if( ( ctrlOrShift && event->text().isEmpty() ) )
       return;

   static  QString            eow( " ~!@#$%^&*()+{}|:\"<>?,./;'[]\\-=" );               /* end of word */
   bool    hasModifier      = ( event->modifiers() != Qt::NoModifier ) && !ctrlOrShift;
   QString completionPrefix = hbTextUnderCursor();

   if( ( hasModifier ||
         event->text().isEmpty() ||
         completionPrefix.length() < 3 ||
         eow.contains( event->text().right( 1 ) ) ) )
   {
      c->popup()->hide();
      return;
   }

   if( completionPrefix != c->completionPrefix() )
   {
      c->setCompletionPrefix( completionPrefix );
      c->popup()->setCurrentIndex( c->completionModel()->index( 0, 0 ) );
   }
   QRect cr = cursorRect();

   cr.setWidth( c->popup()->sizeHintForColumn( 0 ) + c->popup()->verticalScrollBar()->sizeHint().width() );
   cr.setTop( cr.top() + 25 );
   cr.setBottom( cr.bottom() + 25 );

   c->complete( cr ); // popup it up!
}

/*----------------------------------------------------------------------*/
#if 0
QString HBQPlainTextEdit::hbTextForPrefix()
{
   QTextCursor tc = textCursor();
   tc.select( QTextCursor::WordUnderCursor );
   return tc.selectedText();
}
#endif
/*----------------------------------------------------------------------*/

QString HBQPlainTextEdit::hbTextUnderCursor()
{
   QTextCursor tc = textCursor();
   tc.select( QTextCursor::WordUnderCursor );
   return tc.selectedText();
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::resizeEvent( QResizeEvent *e )
{
   setContentsMargins( 0,0,0,0 );
   viewport()->setContentsMargins( 0,0,0,0 );

   QPlainTextEdit::resizeEvent( e );

   QRect cr = contentsRect();
   lineNumberArea->setGeometry( QRect( cr.left(), cr.top() + HORZRULER_HEIGHT, hbLineNumberAreaWidth(), cr.height() ) );

   horzRuler->setGeometry( QRect( cr.left(), cr.top(), cr.width(), HORZRULER_HEIGHT ) );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::focusInEvent( QFocusEvent * event )
{
   if( c )
      c->setWidget( this );

   QPlainTextEdit::focusInEvent( event );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::paintEvent( QPaintEvent * event )
{
   QPainter painter( viewport() );

   int curBlock      = textCursor().blockNumber();

   QTextBlock tblock = firstVisibleBlock();
   int blockNumber   = tblock.blockNumber();
   int height        = ( int ) blockBoundingRect( tblock ).height();
   int top           = ( int ) blockBoundingGeometry( tblock ).translated( contentOffset() ).top();
   int bottom        = top + height;

   while( tblock.isValid() && top <= event->rect().bottom() )
   {
      if( tblock.isVisible() && bottom >= event->rect().top() )
      {
         int index = bookMarksGoto.indexOf( blockNumber + 1 );
         if( index != -1 )
         {
            QRect r( 0, top, viewport()->width(), height );
            painter.fillRect( r, brushForBookmark( index ) );
         }
         else if( curBlock == blockNumber && m_currentLineColor.isValid() )
         {
            if( highlightCurLine == true )
            {
               QRect r = HBQPlainTextEdit::cursorRect();
               r.setX( 0 );
               r.setWidth( viewport()->width() );
               painter.fillRect( r, QBrush( m_currentLineColor ) );
            }
         }
      }
      tblock = tblock.next();
      top    = bottom;
      bottom = top + height;
      ++blockNumber;
   }
   this->hbPaintSelection( event );

   painter.end();
   QPlainTextEdit::paintEvent( event );

   #if 0
   QPainter * painter = new QPainter( viewport() );

   int curBlock      = textCursor().blockNumber();

   QTextBlock tblock = firstVisibleBlock();
   int blockNumber   = tblock.blockNumber();
   int height        = ( int ) blockBoundingRect( tblock ).height();
   int top           = ( int ) blockBoundingGeometry( tblock ).translated( contentOffset() ).top();
   int bottom        = top + height;

   this->hbPaintSelection( event );

   while( tblock.isValid() && top <= event->rect().bottom() )
   {
      if( tblock.isVisible() && bottom >= event->rect().top() )
      {
         int index = bookMarksGoto.indexOf( blockNumber + 1 );
         if( index != -1 )
         {
            QRect r( 0, top, viewport()->width(), height );
            painter->fillRect( r, brushForBookmark( index ) );
         }
         else if( curBlock == blockNumber && m_currentLineColor.isValid() )
         {
            if( highlightCurLine == true )
            {
               QRect r = HBQPlainTextEdit::cursorRect();
               r.setX( 0 );
               r.setWidth( viewport()->width() );
               painter->fillRect( r, QBrush( m_currentLineColor ) );
            }
         }
      }
      tblock = tblock.next();
      top    = bottom;
      bottom = top + height;
      ++blockNumber;
   }

   #if 0  /* A day wasted - I could not find how I can execute paiting from within prg code */
   if( block )
   {
      PHB_ITEM p1 = hb_itemPutNI( NULL, QEvent::Paint );
      PHB_ITEM p2 = hb_itemPutPtr( NULL, painter );
      hb_vmEvalBlockV( block, 2, p1, p2 );
      hb_itemRelease( p1 );
      hb_itemRelease( p2 );
   }
   #endif

   painter->end();
   delete ( ( QPainter * ) painter );
   QPlainTextEdit::paintEvent( event );
   #endif
}
/*----------------------------------------------------------------------*/

QBrush HBQPlainTextEdit::brushForBookmark( int index )
{
   QBrush br;

   if(      index == 0 )
      br = QBrush( QColor( 255, 255, 127 ) );
   else if( index == 1 )
      br = QBrush( QColor( 175, 175, 255 ) );
   else if( index == 2 )
      br = QBrush( QColor( 255, 175, 175 ) );
   else if( index == 3 )
      br = QBrush( QColor( 175, 255, 175 ) );
   else if( index == 4 )
      br = QBrush( QColor( 255, 190, 125 ) );
   else if( index == 5 )
      br = QBrush( QColor( 175, 255, 255 ) );
   else
      br = QBrush( m_currentLineColor );

   return br;
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::horzRulerPaintEvent( QPaintEvent *event )
{
   QRect cr = event->rect();
   QPainter painter( horzRuler );

   painter.fillRect( cr, m_horzRulerBkColor );
   painter.setPen( Qt::gray );
   painter.drawLine( cr.left(), cr.bottom(), cr.width(), cr.bottom() );
   painter.setPen( Qt::black );
   int fontWidth = fontMetrics().averageCharWidth();
   int left = cr.left() + ( fontWidth / 2 ) + ( lineNumberArea->isVisible() ? lineNumberArea->width() : 0 );

   QRect rc( cursorRect( textCursor() ) );
   QTextCursor cursor( cursorForPosition( QPoint( 1, rc.top() + 1 ) ) );

   int i;
   for( i = cursor.columnNumber(); left < cr.width(); i++ )
   {
      if( i % 10 == 0 )
      {
         painter.drawLine( left, cr.bottom()-3, left, cr.bottom()-5 );
         QString number = QString::number( i );
         painter.drawText( left - fontWidth, cr.top()-2, fontWidth * 2, 17, Qt::AlignCenter, number );
      }
      else if( i % 5 == 0 )
      {
         painter.drawLine( left, cr.bottom()-3, left, cr.bottom()-5 );
      }
      else
      {
         painter.drawLine( left, cr.bottom()-3, left, cr.bottom()-4 );
      }
      if( i == textCursor().columnNumber() )
      {
         painter.fillRect( QRect( left, cr.top() + 2, fontWidth, 11 ), QColor( 100,100,100 ) );
      }
      left += fontWidth;
   }
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::lineNumberAreaPaintEvent( QPaintEvent *event )
{
   QPainter painter( lineNumberArea );
   painter.fillRect( event->rect(), m_lineAreaBkColor );

   QTextBlock block = firstVisibleBlock();
   int blockNumber  = block.blockNumber();
   int top          = ( int ) blockBoundingGeometry( block ).translated( contentOffset() ).top();
   int bottom       = top +( int ) blockBoundingRect( block ).height();
   int off          = fontMetrics().height() / 4;

   while( block.isValid() && top <= event->rect().bottom() )
   {
      if( block.isVisible() && bottom >= event->rect().top() )
      {
         QString number = QString::number( blockNumber + 1 );
         painter.setPen( (  blockNumber + 1 ) % 10 == 0 ? Qt::red : Qt::black );
         painter.drawText( 0, top, lineNumberArea->width()-2, fontMetrics().height(), Qt::AlignRight, number );

         int index = bookMarksGoto.indexOf( number.toInt() );
         if( index != -1 )
         {
            painter.setBrush( brushForBookmark( index ) );
            painter.drawRect( 5, top + off, off * 2, off * 2 );
         }
      }
      block  = block.next();
      top    = bottom;
      bottom = top +( int ) blockBoundingRect( block ).height();
      ++blockNumber;
   }
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbPaintSelection( QPaintEvent * event )
{
   HB_SYMBOL_UNUSED( event );
//HB_TRACE( HB_TR_ALWAYS, ( "       1     " ) );
#if 0
HB_TRACE( HB_TR_ALWAYS, ( "%i %i %i %i %i %i %i %i",
                 event->rect().x(), event->rect().y(), event->rect().width(), event->rect().height(),
                 cursorRect().x() , cursorRect().y() , cursorRect().width() , cursorRect().height() ) );
#endif
   if( rowBegins >= 0 && rowEnds >= 0 )
   {
      int cb = columnBegins <= columnEnds ? columnBegins : columnEnds;
      int ce = columnBegins <= columnEnds ? columnEnds   : columnBegins;
      int rb = rowBegins    <= rowEnds    ? rowBegins    : rowEnds;
      int re = rowBegins    <= rowEnds    ? rowEnds      : rowBegins;

      QTextCursor ct = cursorForPosition( QPoint( 2,2 ) );
      int          t = ct.blockNumber();
      int          c = ct.columnNumber();
      int fontHeight = fontMetrics().height();
      int          b = t + ( viewport()->height() / fontHeight ) + 1;

      re = re > b ? b : re;

      if( re >= t && rb < b )
      {
         QPainter p( viewport() );

         int marginX = ( c > 0 ? 0 : contentsRect().left() ) + 2 ;
         int fontWidth = fontMetrics().averageCharWidth();

         int top = ( ( rb <= t ) ? 0 : ( ( rb - t ) * fontHeight ) );
         int btm = ( ( re - t + 1 ) * fontHeight ) - top;
         btm = btm > viewport()->height() ? viewport()->height() : btm;

         if( selectionMode == selectionMode_column )
         {
            #if 0
            int x = ( ( cb - c ) * fontWidth ) + marginX;
            int w = ( ce - cb ) * fontWidth;

            QRect r( x, top, ( w == 0 ? 1 : w ), btm );

            p.fillRect( r, QBrush( m_selectionColor ) );
            #endif
            int x = cb < c ? 0 : ( ( cb - c ) * fontWidth ) + marginX;
            int w = ce < c ? 0 : ( ( ce - cb - c ) * fontWidth );

            QRect r( x, top, ( w == 0 ? 1 : w ), btm );

            p.fillRect( r, QBrush( m_selectionColor ) );
         }
         else if( selectionMode == selectionMode_stream )
         {
            int i;
            int width  = viewport()->width();

            for( i = rb; i <= re; i++ )
            {
               if( i >= t )
               {
                  QRect r;

                  if( i == rb )
                  {
                     if( rb == re )
                     {
                        int x = ( ( columnBegins - c ) * fontWidth ) + marginX;
                        int w = ( columnEnds - columnBegins - c ) * fontWidth;
                        r = QRect( x, top, ( w == 0 ? 1 : w ), fontHeight );
                     }
                     else
                     {
                        int x = ( ( columnBegins - c ) * fontWidth ) + marginX;
                        r = QRect( x, top, width, fontHeight );
                     }
                  }
                  else if( i == re )
                  {
                     int x = ( ( columnEnds - c ) * fontWidth ) + marginX;
                     r = QRect( 0, top, x, fontHeight );
                  }
                  else
                  {
                     r = QRect( 0, top, width, fontHeight );
                  }
                  p.fillRect( r, QBrush( m_selectionColor ) );
                  top += fontHeight;
               }
            }
         }
         else if( selectionMode == selectionMode_line )
         {
            QRect r( 0, top, viewport()->width(), btm );
            p.fillRect( r, QBrush( m_selectionColor ) );
         }
      }
   }
//HB_TRACE( HB_TR_ALWAYS, ( "        2     " ) );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbBookmarks( int block )
{
   int found = bookMark.indexOf( block );
   if( found == -1 )
   {
      bookMark.push_back( block );
      qSort( bookMark );
   }
   else
   {
      bookMark.remove( found );
   }

   found = -1;
   int i = 0;
   for( i = 0; i < bookMarksGoto.size(); i++ )
   {
      if( bookMarksGoto[ i ] == block )
      {
         bookMarksGoto.removeAt( i );
         found = i;
         break;
      }
   }

   if( found == -1 )
   {
      bookMarksGoto.append( block );
   }

   hbUpdateLineNumberAreaWidth( 0 );
   lineNumberArea->repaint();
   update();
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbGotoBookmark( int block )
{
   if( bookMarksGoto.size() > 0 )
   {
      int i;
      for( i = 0; i < bookMarksGoto.size(); i++ )
      {
         if( bookMarksGoto[ i ] == block )
         {
            QTextCursor cursor( document()->findBlockByNumber( block - 1 ) );
            setTextCursor( cursor );
            break;
         }
      }
   }
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbNextBookmark( int block )
{
   if( bookMark.count() > 0 )
   {
      QVector<int>::iterator i = qUpperBound( bookMark.begin(), bookMark.end(), block );
      if( i != bookMark.end() )
      {
         QTextCursor cursor( document()->findBlockByNumber( *i - 1 ) );
         setTextCursor( cursor );
      }
      else
      {
         QTextCursor cursor( document()->findBlockByNumber( *bookMark.begin() - 1 ) );
         setTextCursor( cursor );
      }
   }
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbPrevBookmark( int block )
{
   if( bookMark.count() > 0 )
   {
      QVector<int>::iterator i = qUpperBound( bookMark.begin(), bookMark.end(), block );
      i -= 2;
      if( i >= bookMark.begin() )
      {
         QTextCursor cursor( document()->findBlockByNumber( *i - 1 ) );
         setTextCursor( cursor );
      }
      else
      {
         QVector<int>::iterator it = bookMark.end();
         --it;
         QTextCursor cursor( document()->findBlockByNumber( *it - 1 ) );
         setTextCursor( cursor );
      }
   }
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbNumberBlockVisible( bool b )
{
   numberBlock = b;
   if( b )
   {
      lineNumberArea->show();
      hbUpdateLineNumberAreaWidth( hbLineNumberAreaWidth() );
   }
   else
   {
      lineNumberArea->hide();
      hbUpdateLineNumberAreaWidth( 0 );
   }
   update();
}

/*----------------------------------------------------------------------*/

bool HBQPlainTextEdit::hbNumberBlockVisible()
{
   return numberBlock;
}

/*----------------------------------------------------------------------*/

int HBQPlainTextEdit::hbLineNumberAreaWidth()
{
   int digits = 1;
   int max = qMax( 1, blockCount() );
   while( max >= 10 )
   {
      max /= 10;
      ++digits;
   }
   int width  = fontMetrics().width( QLatin1Char( '9' ) );
   int iM     = fontMetrics().height() / 2;
   int iMark  = bookMarksGoto.size() > 0 ? ( 5 + iM + 2 ) : 0;
   int space  = iMark + ( width * digits ) + 2;

   return space;
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbUpdateLineNumberAreaWidth( int )
{
   if( numberBlock )
   {
      setViewportMargins( hbLineNumberAreaWidth(), HORZRULER_HEIGHT, 0, 0 );
   }
   else
   {
      setViewportMargins( 0, HORZRULER_HEIGHT, 0, 0 );
   }
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbUpdateHorzRuler()
{
  horzRuler->update();
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbUpdateLineNumberArea( const QRect &rect, int dy )
{
   if( dy )
      lineNumberArea->scroll( 0, dy );
   else
      lineNumberArea->update( 0, rect.y(), lineNumberArea->width(), rect.height() );

   if( rect.contains( viewport()->rect() ) )
   {
      hbUpdateLineNumberAreaWidth( 0 );
   }
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbSetSpaces( int newSpaces )
{
   spaces = newSpaces;
   spacesTab = "";

   if( spaces > 0 )
   {
      for( int i = 0; i < spaces; ++i )
          spacesTab += " ";
   }
   else
   {
      if( spaces == -101 )
         spacesTab = "\t";
   }
}

/*----------------------------------------------------------------------*/

int HBQPlainTextEdit::hbGetIndex( const QTextCursor &crQTextCursor )
{
   QTextBlock b;
   int column = 1;
   b = crQTextCursor.block();
   column = crQTextCursor.position() - b.position();
   return column;
}

/*----------------------------------------------------------------------*/

int HBQPlainTextEdit::hbGetLine( const QTextCursor &crQTextCursor )
{
   QTextBlock b,cb;
   int line = 1;
   cb = crQTextCursor.block();
   for( b = document()->begin();b!=document()->end();b = b.next() )
   {
      if( b==cb )
         return line;
      line++;
   }
   return line;
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbSlotCursorPositionChanged()
{
   if( m_currentLineColor.isValid() )
      viewport()->update();

   if( styleHightlighter != "none" )
      hbBraceHighlight();
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbSetStyleHightlighter( const QString &style )
{
   styleHightlighter = style;
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbShowHighlighter( const QString &style, bool b )
{
   if( b )
   {
      if( styleHightlighter != "none" )
      {
         delete highlighter;
         highlighter = 0;
      }
      highlighter = new HBQSyntaxHighlighter( document() );
   }
   else
   {
      delete highlighter;
      highlighter = 0;
   }
   styleHightlighter = style;
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbEscapeQuotes()
{
   QTextCursor cursor( textCursor() );
   QString selTxt( cursor.selectedText() );
   if( selTxt.isEmpty() )
      return;

   QString txt = selTxt.replace( QString( "'" ), QString( "\\\'" ) );
   insertPlainText( txt );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbEscapeDQuotes()
{
   QTextCursor cursor( textCursor() );
   QString selTxt( cursor.selectedText() );
   if( selTxt.isEmpty() )
      return;

   QString txt = selTxt.replace( QString( "\"" ), QString( "\\\"" ) );
   insertPlainText( txt );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbUnescapeQuotes()
{
   QTextCursor cursor( textCursor() );
   QString selTxt( cursor.selectedText() );
   if( selTxt.isEmpty() )
      return;

   QString txt = selTxt.replace( QString( "\\\'" ), QString( "'" ) );
   insertPlainText( txt );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbUnescapeDQuotes()
{
   QTextCursor cursor( textCursor() );
   QString selTxt( cursor.selectedText() );
   if( selTxt.isEmpty() )
      return;

   QString txt = selTxt.replace( QString( "\\\"" ), QString( "\"" ) );
   insertPlainText( txt );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbCaseUpper()
{
   QTextCursor cursor = textCursor();
   QString selTxt( cursor.selectedText() );
   if( selTxt.isEmpty() )
      return;

   int b = cursor.selectionStart();
   int e = cursor.selectionEnd();
   cursor.beginEditBlock();

   insertPlainText( selTxt.toUpper() );

   cursor.setPosition( b );
   cursor.movePosition( QTextCursor::NextCharacter, QTextCursor::KeepAnchor, e-b );
   cursor.endEditBlock();
   setTextCursor( cursor );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbCaseLower()
{
   QTextCursor cursor = textCursor();
   QString selTxt( cursor.selectedText() );
   if( selTxt.isEmpty() )
      return;

   int b = cursor.selectionStart();
   int e = cursor.selectionEnd();
   cursor.beginEditBlock();

   insertPlainText( selTxt.toLower() );

   cursor.setPosition( b );
   cursor.movePosition( QTextCursor::NextCharacter, QTextCursor::KeepAnchor, e-b );
   cursor.endEditBlock();
   setTextCursor( cursor );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbConvertQuotes()
{
   QTextCursor cursor = textCursor();
   QString selTxt( cursor.selectedText() );
   if( selTxt.isEmpty() )
      return;

   int b = cursor.selectionStart();
   int e = cursor.selectionEnd();
   cursor.beginEditBlock();

   insertPlainText( selTxt.replace( QString( "\"" ), QString( "\'" ) ) );

   cursor.setPosition( b );
   cursor.movePosition( QTextCursor::NextCharacter, QTextCursor::KeepAnchor, e-b );
   cursor.endEditBlock();
   setTextCursor( cursor );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbConvertDQuotes()
{
   QTextCursor cursor = textCursor();
   QString selTxt( cursor.selectedText() );
   if( selTxt.isEmpty() )
      return;

   int b = cursor.selectionStart();
   int e = cursor.selectionEnd();
   cursor.beginEditBlock();

   insertPlainText( selTxt.replace( QString( "\'" ), QString( "\"" ) ) );

   cursor.setPosition( b );
   cursor.movePosition( QTextCursor::NextCharacter, QTextCursor::KeepAnchor, e-b );
   cursor.endEditBlock();
   setTextCursor( cursor );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbReplaceSelection( const QString & txt )
{
   QTextCursor cursor = textCursor();
   QString selTxt( cursor.selectedText() );
   if( selTxt.isEmpty() )
      return;

   int b = cursor.selectionStart();
   cursor.beginEditBlock();

   insertPlainText( txt );

   cursor.setPosition( b );
   cursor.movePosition( QTextCursor::NextCharacter, QTextCursor::KeepAnchor, txt.length() );
   cursor.endEditBlock();
   setTextCursor( cursor );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbStreamComment()
{
   QTextCursor cursor = textCursor();
   QString selTxt( cursor.selectedText() );
   if( selTxt.isEmpty() )
      return;

   int b = cursor.selectionStart();
   int e = cursor.selectionEnd();
   cursor.beginEditBlock();

   insertPlainText( "/*" + selTxt + "*/"  );

   cursor.setPosition( b );
   cursor.movePosition( QTextCursor::NextCharacter, QTextCursor::KeepAnchor, e-b+4 );
   cursor.endEditBlock();
   setTextCursor( cursor );
}

/*----------------------------------------------------------------------*/

QString HBQPlainTextEdit::hbGetSelectedText()
{
   QTextCursor cursor( textCursor() );
   QString selTxt( cursor.selectedText() );
   if( selTxt.isEmpty() )
      return "";

   QString txt = selTxt.replace( 0x2029, QString( "\n" ) );
   return txt;
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbInsertTab( int mode )
{
   QTextCursor cursor = textCursor();
   QTextCursor c( cursor );

   c.setPosition( cursor.position() );
   setTextCursor( c );

   if( mode == 0 )
   {
      insertPlainText( spacesTab );
   }
   else
   {
      int icol = c.columnNumber();
      int ioff = qMin( icol, spaces );
      c.setPosition( c.position() - ioff );
   }
   setTextCursor( c );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbMoveLine( int iDirection )
{
   QTextCursor cursor = textCursor();
   QTextCursor c = cursor;

   cursor.beginEditBlock();

   cursor.movePosition( QTextCursor::StartOfLine );
   cursor.movePosition( QTextCursor::EndOfLine, QTextCursor::KeepAnchor );
   QString textCurrentLine = cursor.selectedText();

   if( iDirection == -1 && cursor.blockNumber() > 0 )
   {
      cursor.movePosition( QTextCursor::StartOfLine );
      cursor.movePosition( QTextCursor::Up );
      cursor.movePosition( QTextCursor::EndOfLine, QTextCursor::KeepAnchor );
      QString textPrevLine = cursor.selectedText();
      setTextCursor( cursor );
      insertPlainText( textCurrentLine );
      cursor.movePosition( QTextCursor::Down );
      cursor.movePosition( QTextCursor::StartOfLine );
      cursor.movePosition( QTextCursor::EndOfLine, QTextCursor::KeepAnchor );
      setTextCursor( cursor );
      insertPlainText( textPrevLine );
      c.movePosition( QTextCursor::Up );
   }
   else if( iDirection == 1 && cursor.blockNumber() < cursor.document()->blockCount() - 1 )
   {
      cursor.movePosition( QTextCursor::StartOfLine );
      cursor.movePosition( QTextCursor::Down );
      cursor.movePosition( QTextCursor::EndOfLine, QTextCursor::KeepAnchor );
      QString textPrevLine = cursor.selectedText();
      setTextCursor( cursor );
      insertPlainText( textCurrentLine );
      cursor.movePosition( QTextCursor::Up );
      cursor.movePosition( QTextCursor::StartOfLine );
      cursor.movePosition( QTextCursor::EndOfLine, QTextCursor::KeepAnchor );
      setTextCursor( cursor );
      insertPlainText( textPrevLine );
      c.movePosition( QTextCursor::Down );
   }
   cursor.endEditBlock();
   setTextCursor( c );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbDeleteLine()
{
   QTextCursor cursor = textCursor();
   QTextCursor c = cursor;

   cursor.beginEditBlock();

   cursor.movePosition( QTextCursor::StartOfLine );
   cursor.movePosition( QTextCursor::EndOfLine, QTextCursor::KeepAnchor );
   cursor.movePosition( QTextCursor::Down, QTextCursor::KeepAnchor );

   QString textUnderCursor = cursor.selectedText();
   setTextCursor( cursor );
   insertPlainText( "" );
   cursor.endEditBlock();

   setTextCursor( c );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbBlockIndent( int steps )
{
   QTextCursor cursor = textCursor();

   if( cursor.hasSelection() )
   {
      QTextCursor c = cursor;
      QTextDocument * doc = c.document();

      int bs = doc->findBlock( c.selectionStart() ).blockNumber();
      int be = doc->findBlock( c.selectionEnd() ).blockNumber();

      cursor.beginEditBlock();

      cursor.movePosition( QTextCursor::Start );
      cursor.movePosition( QTextCursor::NextBlock, QTextCursor::MoveAnchor, bs );

      int s = abs( steps );
      int i, j;
      for( i = bs; i <= be; i++ )
      {
         setTextCursor( cursor );
         for( j = 0; j < s; j++ )
         {
            cursor.movePosition( QTextCursor::StartOfLine );

            if( steps < 0 )
            {
               cursor.movePosition( QTextCursor::NextCharacter, QTextCursor::KeepAnchor );
               QString textUnderCursor = cursor.selectedText();
               if( textUnderCursor == " " )
               {
                  setTextCursor( cursor );
                  insertPlainText( "" );
               }
            }
            else
            {
               setTextCursor( cursor );
               insertPlainText( " " );
            }
         }
         cursor.movePosition( QTextCursor::NextBlock, QTextCursor::MoveAnchor, 1 );
      }
      cursor.endEditBlock();

      setTextCursor( c );
   }
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbBlockComment()
{
   QTextCursor cursor = textCursor();
   QTextCursor c = cursor;
   QTextDocument * doc = c.document();

   int bs = doc->findBlock( c.selectionStart() ).blockNumber();
   int be = doc->findBlock( c.selectionEnd() ).blockNumber();

   cursor.beginEditBlock();

   cursor.movePosition( QTextCursor::Start );
   cursor.movePosition( QTextCursor::NextBlock, QTextCursor::MoveAnchor, bs );
   int i;
   for( i = bs; i <= be; i++ )
   {
      setTextCursor( cursor );

      cursor.movePosition( QTextCursor::StartOfLine );
      cursor.movePosition( QTextCursor::NextCharacter, QTextCursor::KeepAnchor );
      cursor.movePosition( QTextCursor::NextCharacter, QTextCursor::KeepAnchor );
      QString textUnderCursor = cursor.selectedText();
      if( textUnderCursor == "//" )
      {
         setTextCursor( cursor );
         insertPlainText( "" );
      }
      else
      {
         cursor.movePosition( QTextCursor::StartOfLine );
         insertPlainText( "//" );
      }
      cursor.movePosition( QTextCursor::NextBlock, QTextCursor::MoveAnchor, 1 );
   }
   cursor.endEditBlock();
   setTextCursor( c );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbDuplicateLine()
{
   QTextCursor cursor = textCursor();
   QTextCursor c = cursor;
   cursor.movePosition( QTextCursor::StartOfLine );
   cursor.movePosition( QTextCursor::EndOfLine, QTextCursor::KeepAnchor );
   QString textUnderCursor = cursor.selectedText();
   cursor.movePosition( QTextCursor::EndOfLine );
   setTextCursor( cursor );
   insertPlainText( "\n" + textUnderCursor );
   setTextCursor( c );
}

/*----------------------------------------------------------------------*/

void HBQPlainTextEdit::hbBraceHighlight()
{
   QColor lineColor = QColor( Qt::yellow ).lighter( 160 );

   QTextDocument *doc = document();

   extraSelections.clear();
   setExtraSelections( extraSelections );
   selection.format.setBackground( lineColor );

   QTextCursor cursor = textCursor();

   cursor.movePosition( QTextCursor::NextCharacter, QTextCursor::KeepAnchor );
   QString brace = cursor.selectedText();

   if(    ( brace != "{" ) && ( brace != "}" )
       && ( brace != "[" ) && ( brace != "]" )
       && ( brace != "(" ) && ( brace != ")" )
       && ( brace != "<" ) && ( brace != ">" ) )
   {
      return;
   }

   QString openBrace;
   QString closeBrace;

   if( ( brace == "{" ) || ( brace == "}" ) )
   {
      openBrace = "{";
      closeBrace = "}";
   }
   if( ( brace == "[" ) || ( brace == "]" ) )
   {
      openBrace = "[";
      closeBrace = "]";
   }
   if( ( brace == "(" ) || ( brace == ")" ) )
   {
      openBrace = "(";
      closeBrace = ")";
   }
   if( ( brace == "<" ) || ( brace == ">" ) )
   {
      openBrace = "<";
      closeBrace = ">";
   }

   QTextCursor cursor1;
   QTextCursor cursor2;
   QTextCursor matches;

   if( brace == openBrace )
   {
      cursor1 = doc->find( closeBrace, cursor );
      cursor2 = doc->find( openBrace, cursor );
      if( cursor2.isNull() )
      {
         matches = cursor1;
      }
      else
      {
         while( cursor1.position() > cursor2.position() )
         {
            cursor1 = doc->find( closeBrace, cursor1 );
            cursor2 = doc->find( openBrace, cursor2 );
            if( cursor2.isNull() )
                break;
         }
         matches = cursor1;
      }
   }
   else
   {
      if( brace == closeBrace )
      {
         cursor1 = doc->find( openBrace, cursor, QTextDocument::FindBackward );
         cursor2 = doc->find( closeBrace, cursor, QTextDocument::FindBackward );
         if( cursor2.isNull() )
         {
            matches = cursor1;
         }
         else
         {
            while( cursor1.position() < cursor2.position() )
            {
               cursor1 = doc->find( openBrace, cursor1, QTextDocument::FindBackward );
               cursor2 = doc->find( closeBrace, cursor2, QTextDocument::FindBackward );
               if( cursor2.isNull() )
                   break;
            }
            matches = cursor1;
         }
      }
   }
   if( ! matches.isNull() )
   {
      if( m_matchBracesAll )
      {
         selection.cursor = cursor;
         extraSelections.append( selection );
      }
      selection.cursor = cursor1;
      extraSelections.append( selection );
      setExtraSelections( extraSelections );
   }
}

/*----------------------------------------------------------------------*/
#endif
