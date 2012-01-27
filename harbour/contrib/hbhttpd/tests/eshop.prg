/*
 * $Id$
 */

REQUEST DBFCDX

MEMVAR server, get, post, cookie, session

PROCEDURE Main()

   LOCAL oServer

   LOCAL oLogAccess
   LOCAL oLogError

   LOCAL nPort

   IF HB_ARGCHECK( "help" )
      ? "Usage: app [options]"
      ? "Options:"
      ? "  //help               Print help"
      ? "  //stop               Stop running server"
      RETURN
   ENDIF

   IF HB_ARGCHECK( "stop" )
      HB_MEMOWRIT( ".uhttpd.stop", "" )
      RETURN
   ELSE
      FErase( ".uhttpd.stop" )
   ENDIF

   rddSetDefault( "DBFCDX" )
   SET( _SET_DATEFORMAT, "yyyy-mm-dd" )


   IF ! HB_FILEEXISTS( "users.dbf" )
      FErase( "users.cdx" )
      dbCreate( "users", { { "USER", "C", 16, 0 }, { "PASSWORD", "C", 16, 0 }, { "NAME", "C", 50, 0 } }, , .T. , "user" )
      dbAppend()
      FIELD->USER := "demo"
      FIELD->PASSWORD := "demo"
      FIELD->NAME := "Demo"
      OrdCreate( "users", "user", "USER" )
      dbCloseArea()
   ELSEIF ! HB_FILEEXISTS( "users.cdx" )
      dbUseArea( .T. , , "users", , .F. , .F. )
      OrdCreate( "users", "user", "USER" )
      dbCloseArea()
   ENDIF

   IF ! HB_FILEEXISTS( "carts.dbf" )
      FErase( "carts.cdx" )
      dbCreate( "carts", { { "USER", "C", 16, 0 }, { "CODE", "C", 16, 0 }, { "AMOUNT", "N", 6, 0 }, { "TOTAL", "N", 9, 2 } }, , .T. , "cart" )
      OrdCreate( "carts", "user", "USER+CODE" )
      dbCloseArea()
   ELSEIF ! HB_FILEEXISTS( "carts.cdx" )
      dbUseArea( .T. , , "carts", , .F. , .F. )
      OrdCreate( "carts", "user", "USER+CODE" )
      dbCloseArea()
   ENDIF

   IF ! HB_FILEEXISTS( "items.dbf" )
      FErase( "items.cdx" )
      dbCreate( "items", { { "CODE", "C", 16, 0 }, { "TITLE", "C", 80, 0 }, { "PRICE", "N", 9, 2 } }, , .T. , "items" )
      OrdCreate( "items", "code", "CODE" )
      dbCloseArea()
   ELSEIF ! HB_FILEEXISTS( "item.cdx" )
      dbUseArea( .T. , , "items", , .F. , .F. )
      OrdCreate( "items", "code", "CODE" )
      dbCloseArea()
   ENDIF

   oLogAccess := UHttpdLog():New( "eshop_access.log" )

   IF ! oLogAccess:Add( "" )
      oLogAccess:Close()
      ? "Access log file open error " + hb_ntos( FError() )
      RETURN
   ENDIF

   oLogError := UHttpdLog():New( "eshop_error.log" )

   IF ! oLogError:Add( "" )
      oLogError:Close()
      oLogAccess:Close()
      ? "Error log file open error " + hb_ntos( FError() )
      RETURN
   ENDIF

   ? "Listening on port:", nPort := 8002

   oLogError:Add( "hello" )

   oServer := UHttpdNew()

   IF ! oServer:Run( {;
      "FirewallFilter" => "", ;
      "LogAccess"      => {| m | oLogAccess:Add( m + hb_eol() ) }, ;
      "LogError"       => {| m | oLogError:Add( m + hb_eol() ) }, ;
      "Trace"          => {| ... | QOut( ... ) }, ;
      "Port"           => nPort, ;
      "Idle"           => {| o | iif( HB_FILEEXISTS( ".uhttpd.stop" ), ( FErase(".uhttpd.stop" ), o:Stop() ), NIL ) }, ;
      "Mount"          => {;
         "/hello"            => {|| UWrite( "Hello!" ) }, ;
         "/info"             => {|| UProcInfo() }, ;
         "/files/*"          => {| x | QOUT( HB_DIRBASE() + "/files/" + X ), UProcFiles( HB_DIRBASE() + "/files/" + X, .F. ) }, ;
         "/app/login"        => @proc_login(), ;
         "/app/logout"       => @proc_logout(), ;
         "/app/account"      => @proc_account(), ;
         "/app/account/edit" => @proc_account_edit(), ;
         "/app/register"     => @proc_register(), ;
         "/app/main"         => @proc_main(), ;
         "/app/shopping"     => @proc_shopping(), ;
         "/app/cart"         => @proc_cart(), ;
         "/"                 => {|| URedirect( "/app/login" ) } } } )
      oLogError:Close()
      oLogAccess:Close()
      ? "Server error:", oServer:cError
      ErrorLevel( 1 )
      RETURN
   ENDIF

   oLogError:Close()
   oLogAccess:Close()

   RETURN

STATIC FUNCTION proc_login()

   LOCAL cUser

   IF server["REQUEST_METHOD"] == "POST"
      dbUseArea( .T. , , "users", "users", .T. , .T. )
      OrdSetFocus( "user" )
      cUser := PadR( HB_HGetDef( post, "user", "" ), 16 )
      USessionStart()
      IF !Empty( cUser ) .AND. dbSeek( cUser, .F. ) .AND. ! Deleted() .AND. ;
            PadR( HB_HGetDef( post, "password", "" ), 16 ) == FIELD->PASSWORD
         session["user"] := cUser
         URedirect( "main" )
      ELSE
         URedirect( "login?err" )
         USessionDestroy()
      ENDIF
      dbCloseArea()
   ELSE
      IF HB_HHasKey( get, "err" )
         RETURN { "errtext" => "Invalid user name or password!" }
      ENDIF
      RETURN { => }
   ENDIF

   RETURN NIL

STATIC FUNCTION proc_logout()

   USessionStart()
   USessionDestroy()

   RETURN { => }

STATIC FUNCTION proc_main()

   USessionStart()
   IF ! HB_HHasKey( session, "user" )
      URedirect( "/app/login" )
      RETURN NIL
   ENDIF

   RETURN { => }

STATIC FUNCTION proc_shopping()

   LOCAL oW, nT, cCode

   USessionStart()
   IF ! HB_HHasKey( session, "user" )
      URedirect( "/app/login" )
      RETURN NIL
   ENDIF

   dbUseArea( .T. , , "carts", "carts", .T. , .F. )
   OrdSetFocus( "user" )
   dbUseArea( .T. , , "items", "items", .T. , .T. )
   OrdSetFocus( "code" )

   IF HB_HHasKey( get, "add" )
      cCode := PadR( get["add"], 16 )
      IF items->( dbSeek( cCode ) ) .AND. carts->( FLock() )
         IF ! carts->( dbSeek( session["user"] + cCode ) )
            carts->( dbAppend() )
            carts->USER := session["user"]
            carts->CODE := cCode
         ENDIF
         carts->AMOUNT += 1
         carts->TOTAL += items->PRICE
         carts->( dbUnlock() )
      ENDIF
      URedirect( "shopping" )
      RETURN NIL
   ENDIF

   dbSelectArea( "carts" )
   ORDSCOPE( 0, session["user"] )
   ORDSCOPE( 1, session["user"] )
   nT := 0
   carts->( dbEval( { || nT += FIELD->TOTAL } ) )
   dbSelectArea( "items" )
   oW := UWBrowseNew( "br_item" )
   oW:AddColumn( 101, "Item No.",    "CODE" )
   oW:AddColumn( 102, "Title",       "TITLE" )
   oW:AddColumn( 103, "Price",       "PRICE" )
   oW:AddColumn( 104, "",            { || ULink( "Add to cart", "?add=" + RTrim( FIELD->CODE ) ) }, .T. )
   oW:nPageSize := 10
   IF HB_HHasKey( get, "_pos" )
      oW:nPos := Val( get["_pos"] )
   ENDIF

   RETURN { "browse" => oW:Output(), "cartsum" => nT }

STATIC FUNCTION proc_cart()

   LOCAL oW, nT, cCode

   USessionStart()
   IF ! HB_HHasKey( session, "user" )
      URedirect( "/app/login" )
      RETURN NIL
   ENDIF

   dbUseArea( .T. , , "items", "items", .T. , .T. )
   OrdSetFocus( "code" )
   dbUseArea( .T. , , "carts", "carts", .T. , .F. )
   OrdSetFocus( "user" )

   IF HB_HHasKey( get, "del" )
      cCode := PadR( get["del"], 16 )
      IF items->( dbSeek( cCode ) ) .AND. carts->( FLock() )
         IF carts->( dbSeek( session["user"] + cCode ) )
            carts->( dbDelete() )
            carts->USER := ""
            carts->CODE := cCode
         ENDIF
         carts->( dbUnlock() )
      ENDIF
      URedirect( "cart" )
      RETURN NIL
   ENDIF

   ORDSCOPE( 0, session["user"] )
   ORDSCOPE( 1, session["user"] )
   nT := 0
   carts->( dbEval( { || nT += FIELD->TOTAL } ) )

   oW := UWBrowseNew( "br_cart" )
   oW:AddColumn( 101, "Item No.",    "CODE" )
   oW:AddColumn( 102, "Title",       { || items->( dbSeek( carts->CODE, .F. ), FIELD->TITLE ) } )
   oW:AddColumn( 103, "Amount",      "AMOUNT" )
   oW:AddColumn( 104, "Total",       "TOTAL" )
   oW:AddColumn( 104, "",            { || ULink( "Delete", "?del=" + RTrim( FIELD->CODE ) ) }, .T. )
   oW:nPageSize := 10
   IF HB_HHasKey( get, "_pos" )
      oW:nPos := Val( get["_pos"] )
   ENDIF

   RETURN { "browse" => oW:Output(), "cartsum" => nT }

STATIC FUNCTION proc_account()

   USessionStart()
   IF ! HB_HHasKey( session, "user" )
      URedirect( "/app/login" )
      RETURN NIL
   ENDIF
   dbUseArea( .T. , , "users", "users", .T. , .F. )
   OrdSetFocus( "user" )
   dbSeek( session["user"], .F. )

   RETURN { "user" => users->USER, "name" => users->NAME }

STATIC FUNCTION proc_account_edit()

   LOCAL cName, cPassword1, cPassword2, aRet

   USessionStart()
   IF ! HB_HHasKey( session, "user" )
      URedirect( "/app/login" )
      RETURN NIL
   ENDIF
   dbUseArea( .T. , , "users", "users", .T. , .F. )
   OrdSetFocus( "user" )
   dbSeek( session["user"], .F. )

   cName := users->NAME
   IF HB_HHasKey( session, "formdata_account/edit" )
      cName := session["formdata_account/edit", "name"]
   ENDIF
   IF server["REQUEST_METHOD"] == "POST"
      cName := HB_HGetDef( post, "name", "" )
      cPassword1 := HB_HGetDef( post, "password1", "" )
      cPassword2 := HB_HGetDef( post, "password2", "" )
      IF Empty( cName )
         session["formdata_account/edit"] := { "name" => cName }
         URedirect( "?err=1" )
      ELSEIF ( ! Empty( cPassword1 ) .OR. ! Empty( cPassword2 ) ) .AND. ! ( cPassword1 == cPassword2 )
         session["formdata_account/edit"] := { "name" => cName }
         URedirect( "?err=2" )
      ELSE
         FLock()
         FIELD->NAME := cName
         IF ! Empty( cPassword1 )
            FIELD->PASSWORD := cPassword1
         ENDIF
         dbUnlock()
         IF HB_HHasKey( session, "formdata_account/edit" )
            HB_HDel( session, "formdata_account/edit" )
         ENDIF
         URedirect( "/app/account" )
      ENDIF
      RETURN NIL
   ENDIF

   aRet := { "user" => users->USER, "name" => cName }
   IF HB_HHasKey( get, "err" )
      IF get["err"] == "1"
         aRet["errtext"] := "Name value should not be empty!"
      ELSEIF get["err"] == "2"
         aRet["errtext"] := "Passwords do not match!"
      ENDIF
   ENDIF

   RETURN aRet

STATIC FUNCTION proc_register()

   LOCAL cUser, cName, cPassword1, cPassword2, aRet

   USessionStart()
   cUser := ""
   cName := ""
   IF HB_HHasKey( session, "formdata_register" )
      cUser := session["formdata_register", "user"]
      cName := session["formdata_register", "name"]
   ENDIF
   IF server["REQUEST_METHOD"] == "POST"
      dbUseArea( .T. , , "users", "users", .T. , .F. )
      OrdSetFocus( "user" )
      cUser := HB_HGetDef( post, "user", "" )
      cName := HB_HGetDef( post, "name", "" )
      cPassword1 := HB_HGetDef( post, "password1", "" )
      cPassword2 := HB_HGetDef( post, "password2", "" )

      IF Empty( cUser ) .OR. Empty( cName ) .OR. Empty( cPassword1 ) .OR. Empty( cPassword2 )
         session["formdata_register"] := { "user" => cUser, "name" => cName }
         URedirect( "?err=1" )
      ELSEIF !( cPassword1 == cPassword2 )
         session["formdata_register"] := { "user" => cUser, "name" => cName }
         URedirect( "?err=2" )
      ELSEIF dbSeek( cUser, .F. )
         session["formdata_register"] := { "user" => cUser, "name" => cName }
         URedirect( "?err=3" )
      ELSE
         FLock()
         dbAppend()
         FIELD->USER := cUser
         FIELD->NAME := cName
         FIELD->PASSWORD := cPassword1
         dbUnlock()
         USessionDestroy()
         USessionStart()
         session["user"] := cUser
         URedirect( "/app/main" )
      ENDIF
      RETURN NIL
   ENDIF
   aRet := { "user" => cUser, "name" => cName }
   IF HB_HHasKey( get, "err" )
      IF get["err"] == "1"
         aRet["errtext"] := "All fields are required!"
      ELSEIF get["err"] == "2"
         aRet["errtext"]  := "Passwords does not match!"
      ELSEIF get["err"] == "3"
         aRet["errtext"]  := "This user already exists!"
      ENDIF
   ENDIF

   RETURN aRet
