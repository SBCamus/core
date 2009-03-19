/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * QT wrapper main header
 *
 * Copyright 2009 Marcos Antonio Gambeta <marcosgambeta at gmail dot com>
 * Copyright 2009 Pritpal Bedi <pritpal@vouchcac.com>
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

#include "hbapi.h"
#include "hbqt.h"

#if QT_VERSION >= 0x040500

#include <QtGui/QAbstractPrintDialog>

/*----------------------------------------------------------------------*/
/*
int fromPage () const
*/
HB_FUNC( QT_QABSTRACTPRINTDIALOG_FROMPAGE )
{
  hb_retni( hbqt_par_QAbstractPrintDialog( 1 )->fromPage() );
}

/*
int maxPage () const
*/
HB_FUNC( QT_QABSTRACTPRINTDIALOG_MAXPAGE )
{
  hb_retni( hbqt_par_QAbstractPrintDialog( 1 )->maxPage() );
}

/*
int minPage () const
*/
HB_FUNC( QT_QABSTRACTPRINTDIALOG_MINPAGE )
{
  hb_retni( hbqt_par_QAbstractPrintDialog( 1 )->minPage() );
}

/*
PrintRange printRange () const
*/
HB_FUNC( QT_QABSTRACTPRINTDIALOG_PRINTRANGE )
{
  hb_retni( hbqt_par_QAbstractPrintDialog( 1 )->printRange() );
}

/*
QPrinter * printer () const
*/
HB_FUNC( QT_QABSTRACTPRINTDIALOG_PRINTER )
{
  hbqt_ret_QPrinter( hbqt_par_QAbstractPrintDialog( 1 )->printer() );
}

/*
void setFromTo ( int from, int to )
*/
HB_FUNC( QT_QABSTRACTPRINTDIALOG_SETFROMTO )
{
  hbqt_par_QAbstractPrintDialog( 1 )->setFromTo( hb_parni( 2 ), hb_parni( 3 ) );
}

/*
void setMinMax ( int min, int max )
*/
HB_FUNC( QT_QABSTRACTPRINTDIALOG_SETMINMAX )
{
  hbqt_par_QAbstractPrintDialog( 1 )->setMinMax( hb_parni( 2 ), hb_parni( 3 ) );
}

/*
void setPrintRange ( PrintRange range )
*/
HB_FUNC( QT_QABSTRACTPRINTDIALOG_SETPRINTRANGE )
{
  hbqt_par_QAbstractPrintDialog( 1 )->setPrintRange( ( QAbstractPrintDialog::PrintRange ) hb_parni( 2 ) );
}

/*
int toPage () const
*/
HB_FUNC( QT_QABSTRACTPRINTDIALOG_TOPAGE )
{
  hb_retni( hbqt_par_QAbstractPrintDialog( 1 )->toPage() );
}

/*----------------------------------------------------------------------*/
#endif
