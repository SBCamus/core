/*
 * $Id$
 */

function main()

   local aRdd := rddList()

   QOut( "Registered RDD's:", LTrim( Str( Len( aRdd ) ) ), "=>" )
   aEval( aRdd, { | cDriver | QQOut( "", cDriver ) } )
   QOut()
   dbUseArea(,, "TestRdd.dbf" )
   Bof()
   dbSelectArea( 2 )
   dbUseArea(, "SDF", "TestRdd.dbf" )
   rddSetDefault("DBF")
   dbSelectArea( 3 )
   dbUseArea(,, "TestRdd.dbf" )
   Eof()
   dbSelectArea( 4 )
   dbUseArea(, "DELIM", "TestRdd.dbf" )
   Found()
   dbGoBottom()
   dbGoTo( 1 )
   dbSelectArea( 5 )
   dbUseArea(, "DBFNTX", "TestRdd.dbf" )
   dbGoTop()
   dbSkip()
   dbCloseArea()
   dbCloseAll()

return nil
