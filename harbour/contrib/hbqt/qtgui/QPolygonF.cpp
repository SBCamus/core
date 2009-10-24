/*
 * $Id$
 */

/* -------------------------------------------------------------------- */
/* WARNING: Automatically generated source file. DO NOT EDIT!           */
/*          Instead, edit corresponding .qth file,                      */
/*          or the generator tool itself, and run regenarate.           */
/* -------------------------------------------------------------------- */

/*
 * Harbour Project source code:
 * QT wrapper main header
 *
 * Copyright 2009 Pritpal Bedi <pritpal@vouchcac.com>
 *
 * Copyright 2009 Marcos Antonio Gambeta <marcosgambeta at gmail dot com>
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
#include "../hbqt.h"

/*----------------------------------------------------------------------*/
#if QT_VERSION >= 0x040500
/*----------------------------------------------------------------------*/

#include <QtCore/QPointer>

#include <QtGui/QPolygonF>


/* QPolygonF ()
 * QPolygonF ( int size )
 * QPolygonF ( const QPolygonF & polygon )
 * QPolygonF ( const QVector<QPointF> & points )
 * QPolygonF ( const QRectF & rectangle )
 * QPolygonF ( const QPolygon & polygon )
 * ~QPolygonF ()
 */

QT_G_FUNC( release_QPolygonF )
{
#if defined(__debug__)
   hb_snprintf( str, sizeof(str), "release_QPolygonF" );  OutputDebugString( str );
#endif
   void * ph = ( void * ) Cargo;
   if( ph )
   {
      delete ( ( QPolygonF * ) ph );
      ph = NULL;
   }
}

HB_FUNC( QT_QPOLYGONF )
{
   QGC_POINTER * p = ( QGC_POINTER * ) hb_gcAllocate( sizeof( QGC_POINTER ), gcFuncs() );
   void * pObj = NULL;

   pObj = new QPolygonF() ;

   p->ph = pObj;
   p->func = release_QPolygonF;

   hb_retptrGC( p );
}
/*
 * QRectF boundingRect () const
 */
HB_FUNC( QT_QPOLYGONF_BOUNDINGRECT )
{
   hb_retptrGC( hbqt_ptrTOgcpointer( new QRectF( hbqt_par_QPolygonF( 1 )->boundingRect() ), release_QRectF ) );
}

/*
 * bool containsPoint ( const QPointF & point, Qt::FillRule fillRule ) const
 */
HB_FUNC( QT_QPOLYGONF_CONTAINSPOINT )
{
   hb_retl( hbqt_par_QPolygonF( 1 )->containsPoint( *hbqt_par_QPointF( 2 ), ( Qt::FillRule ) hb_parni( 3 ) ) );
}

/*
 * QPolygonF intersected ( const QPolygonF & r ) const
 */
HB_FUNC( QT_QPOLYGONF_INTERSECTED )
{
   hb_retptrGC( hbqt_ptrTOgcpointer( new QPolygonF( hbqt_par_QPolygonF( 1 )->intersected( *hbqt_par_QPolygonF( 2 ) ) ), release_QPolygonF ) );
}

/*
 * bool isClosed () const
 */
HB_FUNC( QT_QPOLYGONF_ISCLOSED )
{
   hb_retl( hbqt_par_QPolygonF( 1 )->isClosed() );
}

/*
 * QPolygonF subtracted ( const QPolygonF & r ) const
 */
HB_FUNC( QT_QPOLYGONF_SUBTRACTED )
{
   hb_retptrGC( hbqt_ptrTOgcpointer( new QPolygonF( hbqt_par_QPolygonF( 1 )->subtracted( *hbqt_par_QPolygonF( 2 ) ) ), release_QPolygonF ) );
}

/*
 * QPolygon toPolygon () const
 */
HB_FUNC( QT_QPOLYGONF_TOPOLYGON )
{
   hb_retptrGC( hbqt_ptrTOgcpointer( new QPolygon( hbqt_par_QPolygonF( 1 )->toPolygon() ), release_QPolygon ) );
}

/*
 * void translate ( const QPointF & offset )
 */
HB_FUNC( QT_QPOLYGONF_TRANSLATE )
{
   hbqt_par_QPolygonF( 1 )->translate( *hbqt_par_QPointF( 2 ) );
}

/*
 * void translate ( qreal dx, qreal dy )
 */
HB_FUNC( QT_QPOLYGONF_TRANSLATE_1 )
{
   hbqt_par_QPolygonF( 1 )->translate( hb_parnd( 2 ), hb_parnd( 3 ) );
}

/*
 * QPolygonF united ( const QPolygonF & r ) const
 */
HB_FUNC( QT_QPOLYGONF_UNITED )
{
   hb_retptrGC( hbqt_ptrTOgcpointer( new QPolygonF( hbqt_par_QPolygonF( 1 )->united( *hbqt_par_QPolygonF( 2 ) ) ), release_QPolygonF ) );
}


/*----------------------------------------------------------------------*/
#endif             /* #if QT_VERSION >= 0x040500 */
/*----------------------------------------------------------------------*/
