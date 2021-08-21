Use Windows.pkg
Use DFClient.pkg
Use cTextEdit.pkg
Use StructFunctions.pkg
Use JsonFunctions.pkg
Use seq_chnl.pkg
Use dfSpnFrm.pkg
Use File_dlg.pkg
//Use dirsel.pkg
Use cJsonObject.pkg

// ToDo: do this only in the places it need to be done:
Set_Argument_Size 10485760  // 10Mb

#REPLACE BIF_RETURNONLYFSDIRS       |CI$000001 // 0x00000001. Only return file system directories. If the user selects folders that are not part of the file system, the OK button is grayed. Note  The OK button remains enabled for "\\server" items, as well as "\\server\share" and directory items. However, if the user selects a "\\server" item, passing the PIDL returned by SHBrowseForFolder to SHGetPathFromIDList fails.
#REPLACE BIF_DONTGOBELOWDOMAIN      |CI$000002 // 0x00000002. Do not include network folders below the domain level in the dialog box's tree view control.
#REPLACE BIF_STATUSTEXT             |CI$000004 // 0x00000004. Include a status area in the dialog box. The callback function can set the status text by sending messages to the dialog box. This flag is not supported when BIF_NEWDIALOGSTYLE is specified.
#REPLACE BIF_RETURNFSANCESTORS      |CI$000008 // 0x00000008. Only return file system ancestors. An ancestor is a subfolder that is beneath the root folder in the namespace hierarchy. If the user selects an ancestor of the root folder that is not part of the file system, the OK button is grayed.
#REPLACE BIF_EDITBOX                |CI$000010 // 0x00000010. Version 4.71. Include an edit control in the browse dialog box that allows the user to type the name of an item.
#REPLACE BIF_VALIDATE               |CI$000020 // 0x00000020. Version 4.71. If the user types an invalid name into the edit box, the browse dialog box calls the application's BrowseCallbackProc with the BFFM_VALIDATEFAILED message. This flag is ignored if BIF_EDITBOX is not specified.
#REPLACE BIF_NEWDIALOGSTYLE         |CI$000040 // 0x00000040. Version 5.0. Use the new user interface. Setting this flag provides the user with a larger dialog box that can be resized. The dialog box has several new capabilities, including: drag-and-drop capability within the dialog box, reordering, shortcut menus, new folders, delete, and other shortcut menu commands. Note  If COM is initialized through CoInitializeEx with the COINIT_MULTITHREADED flag set, SHBrowseForFolder fails if BIF_NEWDIALOGSTYLE is passed.
#REPLACE BIF_BROWSEINCLUDEURLS      |CI$000080 // 0x00000080. Version 5.0. The browse dialog box can display URLs. The BIF_USENEWUI and BIF_BROWSEINCLUDEFILES flags must also be set. If any of these three flags are not set, the browser dialog box rejects URLs. Even when these flags are set, the browse dialog box displays URLs only if the folder that contains the selected item supports URLs. When the folder's IShellFolder::GetAttributesOf method is called to request the selected item's attributes, the folder must set the SFGAO_FOLDER attribute flag. Otherwise, the browse dialog box will not display the URL.
//#REPLACE BIF_USENEWUI //Version 5.0. Use the new user interface, including an edit box. This flag is equivalent to BIF_EDITBOX | BIF_NEWDIALOGSTYLE. Note  If COM is initialized through CoInitializeEx with the COINIT_MULTITHREADED flag set, SHBrowseForFolder fails if BIF_USENEWUI is passed.
#REPLACE BIF_UAHINT                 |CI$000100 // 0x00000100. Version 6.0. When combined with BIF_NEWDIALOGSTYLE, adds a usage hint to the dialog box, in place of the edit box. BIF_EDITBOX overrides this flag.
#REPLACE BIF_NONEWFOLDERBUTTON      |CI$000200 // 0x00000200. Version 6.0. Do not include the New Folder button in the browse dialog box.
#REPLACE BIF_NOTRANSLATETARGETS     |CI$000400 // 0x00000400. Version 6.0. When the selected item is a shortcut, return the PIDL of the shortcut itself rather than its target.
#REPLACE BIF_BROWSEFORCOMPUTER      |CI$001000 // 0x00001000. Only return computers. If the user selects anything other than a computer, the OK button is grayed.
#REPLACE BIF_BROWSEFORPRINTER       |CI$002000 // 0x00002000. Only allow the selection of printers. If the user selects anything other than a printer, the OK button is grayed. In Windows XP and later systems, the best practice is to use a Windows XP-style dialog, setting the root of the dialog to the Printers and Faxes folder (CSIDL_PRINTERS).
#REPLACE BIF_BROWSEINCLUDEFILES     |CI$004000 // 0x00004000. Version 4.71. The browse dialog box displays files as well as folders.
#REPLACE BIF_SHAREABLE              |CI$008000 // 0x00008000. Version 5.0. The browse dialog box can display sharable resources on remote systems. This is intended for applications that want to expose remote shares on a local system. The BIF_NEWDIALOGSTYLE flag must also be set.
#REPLACE BIF_BROWSEFILEJUNCTIONS    |CI$010000 // 0x00010000. Windows 7 and later. Allow folder junctions such as a library or a compressed file with a .zip file name extension to be browsed.

Struct BrowseInfo
    Integer hwndOwner
    Integer pidlRoot
    String  pszDisplayName
    String  lpszTitle
    Integer ulFlags
    Integer lpfn
    Integer lParam
    Integer iImage
End_Struct

External_Function SHBrowseForFolder "SHBrowseForFolder" Shell32.dll Pointer BrowseInfo Returns Integer
External_Function SHGetPathFromIDList "SHGetPathFromIDList" Shell32.dll Integer pidList Integer lpBuffer Returns Integer

Define C_US for (Ascii("_"))

Deferred_View Activate_oRestGen for ;
Object oRestGen is a View
    Set Border_Style to Border_Thick
    Set Size to 303 487
    Set Location to 0 0
    Set Label to "Json to Structs Generator"
    Set Icon to "favicon.ico"
   
    Property String[] pasOriginalNames
    Property String[] pasReplacedNames
    Property Integer  piWarnings
    
    Function UCFirst String sVal Returns String
        Function_Return (Uppercase(Left(sVal, 1)) + Right(sVal, (Length(sVal) - 1)))
    End_Function
    
    Procedure ReplaceNames Handle hoJson
        String[]  asOriginal asReplaced
        Integer   i j iMembs iLast iPos
        UChar[]   ucaName
        String    sName sRepl
        Handle    hoMemb
        
        Get MemberCount of hoJson to iMembs
        Decrement iMembs
        
        For j from 0 to iMembs
            Get MemberNameByIndex of hoJson j to sName
        
            If (Length(sName) = 0) Begin
                Move 0                                  to iPos
            End
            Else Begin
                Move (SearchArray(sName, asOriginal))   to iPos            
            End
            
            // If name has length and we don't have it already, process:
            If (iPos = -1) Begin
                Move (StringToUCharArray(sName))        to ucaName
                Move (SizeOfArray(ucaName) - 1)         to iLast
                
                For i from 0 to iLast
    
                    Case Begin
                        // A digit in 1st place
                        Case ((i = 0) and ((ucaName[i] >= 48) and (ucaName[i] <= 57)))
                            Move C_US to ucaName[i]
                            Case Break
                        // Double-quote
                        Case (ucaName[i] = 34)
                            Move C_US to ucaName[i]
                            Case Break
                        // ASCII 36-47
                        Case ((ucaName[i] >= 36) and (ucaName[i] <= 47))
                            Move C_US to ucaName[i]
                            Case Break
                        // ASCII 58-64
                        Case ((ucaName[i] >= 58) and (ucaName[i] <= 64))
                            Move C_US to ucaName[i]
                            Case Break
                        // ASCII 91-94
                        Case ((ucaName[i] >= 91) and (ucaName[i] <= 94))
                            Move C_US to ucaName[i]
                            Case Break
                        // ASCII 96
                        Case (ucaName[i] = 96)
                            Move C_US to ucaName[i]
                            Case Break
                        // Greater than ASCII 123
                        Case (ucaName[i] >= 123)
                            Move C_US to ucaName[i]
                            Case Break
                    Case End
                    
                Loop
                        
            End            
                        
            Move (UCharArrayToString(ucaName))    to sRepl
            
            If (sName <> sRepl) Begin  // There have been replacements
                Move (SizeOfArray(asOriginal))    to iPos
                Move sName                        to asOriginal[iPos]
                Move sRepl                        to asReplaced[iPos]
            End
            
        Loop
        
        Move (SizeOfArray(asReplaced) - 1) to iLast
        
        For i from 0 to iLast
            Get Member        of hoJson asOriginal[i] to hoMemb
            Send RemoveMember of hoJson asOriginal[i]
            Send SetMember    of hoJson asReplaced[i] hoMemb
            Send Destroy      of hoMemb
        Loop
        
        Set pasOriginalNames to asOriginal
        Set pasReplacedNames to asReplaced
    End_Procedure
    
//    Function NamesReplacement Handle hoJson Returns Boolean
//        Integer i iLast
//        String[]  asOriginal asReplaced
//        String    sName
//        Handle    hoMemb
//        
//        Get MemberCount of hoJson to iLast
//        Decrement iLast
//        
//        For i from 0 to iLast
//            Get MemberNameByIndex of hoJson i to sName
//            Get MemberByIndex     of hoJson i to hoMemb
//            Send ReplaceNames hoMemb sName (&asOriginal) (&asReplaced) //(&tJson.aChildNodes[i]) (&asOriginal) (&asReplaced)
//        Loop
//        
//        Set pasOriginalNames to asOriginal
//        Set pasReplacedNames to asReplaced
//        
//        Function_Return (SizeOfArray(asReplaced) > 0)
//    End_Function
    
    Procedure WriteArray Handle hoJson String sFile String sName Integer iChn Integer iLevel String sParent
        Integer iIndent iWarn iMembs iType
        String  sPre sPath sMemb
        Handle  hoMemb
                
        Get Value of oInnerPrefix   to sPre
        Get Value of oOutput        to sPath
        Get Spin_Value of oIndent   to iIndent
        
        Get MemberCount of hoJson to iMembs
        
        If (iMembs = 0) Begin
            Showln "***** WARNING: EMPTY ARRAY *****"
            ShowLn '     Cannot determine member type for array "' sName '" in ' sFile
            Showln '     Defaulting type to string, which is probably wrong (it may be a complex type)'
            Showln '     Suggest you populate the FIRST occurance of the "' sName '" array'
            Showln '     with one filled-out item in the JSON window and regenerate'
            Writeln channel iChn (Repeat(" ", iIndent)) "String[] " sName
            Get piWarnings to iWarn
            Set piWarnings to (iWarn + 1)
            Procedure_Return
        End
        
        Get MemberByIndex     of hoJson 0 to hoMemb
        Get JsonType          of hoMemb   to iType
        
        Case Begin
            Case ((iType = jsonTypeString) or (iType = jsonTypeNull))
                WriteLn channel iChn (Repeat(" ", iIndent)) "String[]  " sName
                Case Break
            Case (iType = jsonTypeDouble)
                WriteLn channel iChn (Repeat(" ", iIndent)) "Number[]  " sName
                Case Break
            Case (iType = jsonTypeInteger)
                WriteLn channel iChn (Repeat(" ", iIndent)) "Integer[] " sName
                Case Break
            Case (iType = jsonTypeBoolean)
                WriteLn channel iChn (Repeat(" ", iIndent)) "Boolean[] " sName
                Case Break
            Case (iType = jsonTypeObject)
                WriteLn channel iChn (Repeat(" ", iIndent)) sPre (UCFirst(Self, sName)) "[] " sName
                Close_Output channel iChn
                Send WriteStruct hoMemb (sPre + UCFirst(Self, sName)) iChn (iLevel + 1) sName sParent
                Append_Output channel iChn (sFile + ".struct")
                Case Break
            Case (iType = jsonTypeArray)
                Showln "***** WARNING: Multi-dimensional array *****"
                Showln "Cannot process - defaulting to string, which IS WRONG!"
                Writeln channel iChn (Repeat(" ", iIndent)) "String[] " sName
                Case Break
        Case End
                
    End_Procedure
    
    Procedure WriteMember Handle hoJson String sFile String sName Integer iChn Integer iLevel String sMembName
        Integer iIndent iType
        String  sNewFile sPath sPre
        
        Get Spin_Value of oIndent   to iIndent
        Get Value of oInnerPrefix   to sPre
        Get Value of oOutput        to sPath
        Get JsonType of hoJson      to iType

        Case Begin
            Case ((iType = jsonTypeString) or (iType = jsonTypeNull))
                Writeln channel iChn (Repeat( " ", iIndent)) "String   " sMembName
                Case Break
            Case (iType = jsonTypeDouble)
                Writeln channel iChn (Repeat( " ", iIndent)) "Number   " sMembName
                Case Break
            Case (iType = jsonTypeInteger)
                Writeln channel iChn (Repeat( " ", iIndent)) "Integer  " sMembName
                Case Break
            Case (iType = jsonTypeBoolean)
                Writeln channel iChn (Repeat( " ", iIndent)) "Boolean  " sMembName
                Case Break
            Case (iType = jsonTypeObject) // So need to write a child struct to a new file
                Writeln channel iChn (Repeat( " ", iIndent)) sPre (UCFirst(Self, sMembName)) " " sMembName
                Close_Output channel iChn
                Send WriteStruct hoJson (sPre + UCFirst(Self, sMembName)) iChn (iLevel + 1) sName sMembName
                Append_Output channel iChn (sFile + ".struct")
                Case Break
            Case (iType = jsonTypeArray)
                Send WriteArray hoJson sFile sMembName iChn iLevel sName
                Case Break
        Case End
        
    End_Procedure
    
    Procedure WriteStruct Handle hoJson String sName Integer iChn Integer iLevel String sParent String sRealName// tJsonNode ByRef tJson String sName Integer iChn Integer iLevel
        String   sPath sLine sFile sPre sRPath sMembName
        String[] asOriginal asReplaced
        Integer  i iLast iReadCh iIndent iLastName iType iCount iChildType
        Boolean  bExist
        Handle   hoMemb
        
        Get Value of oOutput        to sPath
        Get Value of oInnerPrefix   to sPre
        Move (sPath + "\" + sName)  to sFile
        Get Spin_Value of oIndent   to iIndent
        
        // First delete any intermediate files for this struct:
        File_Exist (sFile + ".struct") bExist
        
        If bExist Begin
            EraseFile (sFile + ".struct")
        End
        
        File_Exist (sFile + ".uses") bExist
        
        If bExist Begin
            EraseFile (sFile + ".uses")
        End
        
        // Now write the struct itself
        
        Direct_Output channel iChn (sFile  + ".struct")

        Writeln channel iChn "Struct " sName
        
        Send ReplaceNames hoJson  // Replaces invald names in the JSON
        
        Get pasOriginalNames to asOriginal
        Get pasReplacedNames to asReplaced

        Get MemberCount of hoJson to iLast
        Decrement iLast
        
        For i from 0 to iLast
            Get MemberByIndex of hoJson i      to hoMemb
            Get MemberNameByIndex of hoJson i  to sMembName
            Send WriteMember hoMemb sFile sName iChn iLevel sMembName
        Loop
        
        Writeln channel iChn "End_Struct"
        Close_Output channel iChn
        
        Direct_Output channel iChn (sFile + ".code")
        
        // Write class and construct_object
        Writeln channel iChn "Class cStructHandler_" sName " is a cObject"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", iIndent)) "Procedure Construct_Object"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Forward Send Construct_Object"
        Writeln channel iChn

//        Get pasReplacedNames to asReplaced
        Move (SizeOfArray(asReplaced) - 1) to iLastName
//
//        Get pasOriginalNames to asOriginal
        
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Property String[] pasOriginalNames"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Property String[] pasReplacedNames"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Property String[] pasMemberObjects"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Property Handle[] pahMemberObjects"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "String[] asOriginal asReplaced"
        Writeln channel iChn
        
        For i from 0 to iLastName
            Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Move '" asOriginal[i] "' to asOriginal[" i "]"
        Loop
        
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Set pasOriginalNames to asOriginal"
        
        For i from 0 to iLastName
            Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Move '" asReplaced[i] "' to asReplaced[" i "]"
        Loop
        
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Set pasReplacedNames to asReplaced"

        If (sParent = "") Begin
            Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Broadcast Send RegisterWithParent of (Parent(Self))"
        End

        Writeln channel iChn (Repeat(" ", iIndent)) "End_Procedure"
        Writeln channel iChn

        // If not the top level write RegisterWithParent
        If (sParent <> "") Begin
            Writeln channel iChn (Repeat(" ", iIndent)) "Procedure RegisterWithParent"
            Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Send RegisterMember of oStructHandler_" sParent " '" sRealName "' Self"
            Writeln channel iChn (Repeat(" ", iIndent)) "End_Procedure"
            Writeln channel iChn
        End
        
        // Write member handle registration
        Writeln channel iChn (Repeat(" ", iIndent)) "Procedure RegisterMember String sMemb Handle hMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "String[] asMembs"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Handle[] ahMembs"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Get pasMemberObjects to asMembs"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Get pahMemberObjects to ahMembs"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Move sMemb to asMembs[SizeOfArray(asMembs)]"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Move hMemb to ahMembs[SizeOfArray(ahMembs)]"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Set pasMemberObjects to asMembs"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Set pahMemberObjects to ahMembs"
        Writeln channel iChn (Repeat(" ", iIndent)) "End_Procedure"
        Writeln channel iChn
        
        // Write member handle retriever
        Writeln channel iChn (Repeat(" ", iIndent)) "Function MemberHandler String sMemb Returns Handle"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Integer iPos"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "String[] asMembs"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Handle[] ahMembs"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Get pasMemberObjects to asMembs"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Get pahMemberObjects to ahMembs"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Move (SearchArray(sMemb, asMembs)) to iPos"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "If (iPos > -1) Function_Return ahMembs[iPos]"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Function_Return 0"
        Writeln channel iChn (Repeat(" ", iIndent)) "End_Function"
        Writeln channel iChn
        
        // Now need to write the translation stuff
        Writeln channel iChn (Repeat(" ", iIndent)) "Procedure ConvertNames Handle hoJson Boolean bToOriginal"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "String[]  asOrig asRepl"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "String    sMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Integer   i iMax iType"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Boolean   bHas"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Handle    hoMemb hoObj hoHandler"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Get pasOriginalNames to asOrig"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Get pasReplacedNames to asRepl"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Move (SizeOfArray(asRepl) - 1 ) to iMax"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "If bToOriginal Begin"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 3))) "For i from 0 to iMax"
        Writeln channel iChn (Repeat(" ", (iIndent * 4))) "Get HasMember of hoJson asRepl[i] to bHas"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 4))) "If bHas Begin"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Get  Member         of hoJson asRepl[i] to hoMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Send RemoveMember   of hoJson asRepl[i]"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Send SetMember      of hoJson asOrig[i]    hoMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Send Destroy        of hoMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 4))) "End"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 3))) "Loop"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "End"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Else Begin"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 3))) "For i from 0 to iMax"
        Writeln channel iChn (Repeat(" ", (iIndent * 4))) "Get HasMember of hoJson asOrig[i] to bHas"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 4))) "If bHas Begin"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Get  Member         of hoJson asOrig[i] to hoMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Send RemoveMember   of hoJson asOrig[i]"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Send SetMember      of hoJson asRepl[i]    hoMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Send Destroy        of hoMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 4))) "End"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 3))) "Loop"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "End"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Get MemberCount of hoJson to iMax"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Decrement iMax"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "For i from 0 to iMax"
        Writeln channel iChn (Repeat(" ", (iIndent * 3))) "Get MemberNameByIndex of hoJson i to sMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 3))) "Get MemberJsonType of hoJson sMemb to iType"
        Writeln channel iChn            
        Writeln channel iChn (Repeat(" ", (iIndent * 3))) "If ((iType = jsonTypeArray) or (iType = jsonTypeObject)) Begin"
        Writeln channel iChn (Repeat(" ", (iIndent * 4))) "Get MemberHandler sMemb to hoHandler"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 4))) "If hoHandler Begin"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Get Member of hoJson sMemb to hoMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Send ConvertNames of hoHandler hoMemb bToOriginal"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Send Destroy of hoMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Get Member of hoJson sMemb to hoMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Get Member of hoJson sMemb to hoMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 5))) "Get Member of hoJson sMemb to hoMemb"
        Writeln channel iChn (Repeat(" ", (iIndent * 4))) "End"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 3))) "End"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Loop"
        Writeln channel iChn
        Writeln channel iChn (Repeat(" ", iIndent)) "End_Procedure"

        WriteLn
        Writeln channel iChn (Repeat(" ", iIndent)) "Procedure AddReplacement String sOriginal String sReplacement"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Integer iMax"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "String[] asTemp"
        WriteLn
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Get pasOriginalNames to asTemp"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Move (SizeOfArray(asTemp)) to iMax"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Move sOriginal to asTemp[iMax]"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Set pasOriginalNames to asTemp"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Get pasReplacedNames to asTemp"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Move (SizeOfArray(asTemp)) to iMax"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Move sReplacement to asTemp[iMax]"
        Writeln channel iChn (Repeat(" ", (iIndent * 2))) "Set pasReplacedNames to asTemp"
        Writeln channel iChn (Repeat(" ", iIndent)) "End_Procedure"
        
        Writeln channel iChn 
        Writeln channel iChn "End_Class"
        Writeln channel iChn 
        Writeln channel iChn "Object oStructHandler_" sName " is a cStructHandler_" sName

        Writeln channel iChn "End_Object"
        
        Close_Output channel iChn
        
        // The .struct file has been written and closed.
        // XXX - The .code file should have been written.
        // Now assemble them into the .pkg file.
        
        Get Value of oRelPath to sRPath

        Direct_Output channel iChn (sFile + ".pkg")
        
        Writeln channel iChn "// File: " sName ".pkg generated by Unicorn InterGlobal's " (Module_Name(Self)) " program, " (String(CurrentDateTime()))

// ToDo: Change to reflect new usage
        Writeln channel iChn '// '
        Writeln channel iChn '// Usage:'
        Writeln channel iChn '//   Use this file in your program: "Use ' sRPath '\' sName '.pkg"'
        Writeln channel iChn '// '
        Writeln channel iChn '//   Declare a struct variable: "' sName ' tYourVarName"'
        Writeln channel iChn '//   and a string:              "String sYourJsonString"' 
        Writeln channel iChn '// '
        Writeln channel iChn '//   On receiving a JSON string, do:'
        Writeln channel iChn '// '
        Writeln channel iChn '//        "Send JsonStringToStruct of oStructHandler_' sName ' (&sYourJsonString) (&tYourVarName)"'
        Writeln channel iChn '// '
        Writeln channel iChn '//   to populate the struct with the JSON data.'
        Writeln channel iChn '// '
        Writeln channel iChn '//   To generate a JSON string, do:'
        Writeln channel iChn '// '
        Writeln channel iChn '//        "Send StructToJsonString of oStructHandler_' sName ' (&tYourVarName) (&sYourJsonString)"'
        Writeln channel iChn '// '
        Writeln channel iChn '//   to load the string with the struct data.'
        Writeln channel iChn '// '

        Writeln channel iChn
        Writeln channel iChn "Use cJsonObject"
        Writeln channel iChn "Register_Object oStructHandler_" sName
        
        For i from 0 to iLast
            Get MemberNameByIndex of hoJson i          to sMembName
            Get MemberJsonType    of hoJson sMembName  to iType
            
            If (iType = jsonTypeObject) Begin
                Writeln channel iChn "Use " sRPath "\" sPre (UCFirst(Self, sMembName)) ".pkg"
            End
            
            If (iType = jsonTypeArray) Begin
                Get MemberByIndex of hoJson i to hoMemb
                Get MemberCount   of hoMemb   to iCount
                
                If iCount Begin
                    Get MemberJsonType of hoMemb 0 to iChildType
                    
                    If (iChildType = jsonTypeObject) Begin
                        Writeln channel iChn "Use " sRPath "\" sPre (UCFirst(Self, sMembName)) ".pkg"
                    End
                    
                End
                
            End
            
        Loop
            
        Writeln channel iChn
        
        Get Seq_New_Channel to iReadCh
        Direct_Input channel iReadCh (sFile + ".struct")
        
        While not (SeqEOF)
            Readln channel iReadCh sLine
            Writeln channel iChn sLine
        Loop
        
        Close_Input channel iReadCh
        
        Direct_Input channel iReadCh (sFile + ".code")
        
        While not (SeqEOF)
            Readln channel iReadCh sLine
            Writeln channel iChn sLine
        Loop
        
        Close_Input channel iReadCh
        Send Seq_Release_Channel iReadCh
            
        Close_Output channel iChn

        EraseFile (sFile + ".struct")
        EraseFile (sFile + ".code")
        Showln "Created struct and code for " sName
    End_Procedure
    
    Procedure Generate
        String  sSource sPath sOName sIPre sErr sPartPath
        String[] asOriginals asReplaces asDirs
        Boolean bOK bExist bReps bHas
        Integer iChn i iLast iWarns iType
        Handle  hoJson hoMemb        
        
        Get Value of oJsonText to sSource
        
        If (sSource = "") Begin
            Send UserError "You need to paste sample JSON into the window before attempting to generate struct(s) from it" "Nothing to work on"
            Procedure_Return
        End
        
        If (Value(oOuterName(Self)) = "") Begin
            Send UserError "You must specify a path to write the packages to" "No Path specified"
            Procedure_Return
        End
        
        Get Create (RefClass(cJsonObject)) to hoJson
        
        Get ParseString of hoJson sSource to bOK
        
        If not bOK Begin
            Get psParseError of hoJson to sErr
            Send UserError ("JSON" * sErr)
            Procedure_Return
        End
        
        // Initalise array properties:
        Set pasOriginalNames to asOriginals
        Set pasReplacedNames to asReplaces
                
        Get JsonType of hoJson to iType
        
//        If ((iType = jsonTypeArray) or (iType = jsonTypeObject)) Begin
//            Get NamesReplacement hoJson to bReps
//            
//            Get pasOriginalNames to asOriginals
//            Get pasReplacedNames to asReplaces
//            Move (SizeOfArray(asReplaces) - 1) to iLast
//            
//            For i from 0 to iLast
//                Get HasMember of hoJson asOriginals[i] to bHas
//                
//                If bHas Begin
//                    Get  Member       of hoJson asOriginals[i] to hoMemb
//                    Send RemoveMember of hoJson asOriginals[i]
//                    Send SetMember    of hoJson asReplaces[i]     hoMemb
//                End
//                
//            Loop
//            
//        End
        
        Get Value of oOutput    to sPath
        Get Value of oOuterName to sOName
        Get Seq_New_Channel     to iChn
        
        Showln "Generating struct packanges for " sOName " in " sPath
        Set piWarnings          to 0
        
        // Check if the output directory exists; if not create it
        File_Exist sPath bExist

        If not bExist Begin
            Move (StrSplitToArray(sPath, "\"))  to asDirs
            Move (SizeOfArray(asDirs) - 1)      to iLast
            Move asDirs[0]                      to sPartPath
            
            For i from 1 to iLast
                File_Exist sPartPath bExist
                
                If not bExist Begin
                    Make_Directory sPartPath
                End
                
                Move (sPartPath + "\" + asDirs[i]) to sPartPath
            Loop
            
            File_Exist sPartPath bExist
            
            If not bExist Begin
                Make_Directory sPartPath
            End
            
        End
        
        Send WriteStruct hoJson sOName iChn 0 "" ""
        
        Send Seq_Release_Channel iChn
                
        Get piWarnings to iWarns
        Showln "Struct and code generation for " sOName " complete"
        Showln "There " (If((iWarns = 1), "was ", "were ")) (String(iWarns)) " warning" (If((iWarns = 1), "", "s"))
        
        RunProgram Shell Background "explorer" sPath        
    End_Procedure

    Object oJsonText is a cTextEdit
        Set Size to 230 467
        Set Location to 20 10
        Set peAnchors to anAll
        Set Label to "Paste sample JSON here:"
        Set psToolTip to "Paste the JSON text on which to base your struct(s) here"
        Set piMaxChars to 10000000
    End_Object

    Object oOuterName is a Form
        Set Size to 13 111
        Set Location to 255 105
        Set peAnchors to anBottomLeft
        Set Label_Col_Offset to 94
        Set Label to "Outer struct name:"
        Set Value to "t"
        Set psToolTip to "Name for the outer struct from your JSON"
        
        Procedure Exiting Handle hoDestination returns Integer
            Integer iRet
            String  sVal sInner
            
            Get Value of oInnerPrefix to sInner
            
            If (sInner = "") Begin
                Get Value                   to sVal
                Set Value of oInnerPrefix   to sVal
            End
            
            Forward Get Msg_Exiting hoDestination to iRet
            
            Procedure_Return iRet
        End_Procedure
        
    End_Object

    Object oInnerPrefix is a Form
        Set Size to 13 100
        Set Location to 255 318
        Set Label to "Inner struct name prefix:"
        Set Label_Col_Offset to 80
        Set Value to ""
        Set psToolTip to "Text to prefix the names of any structs within your JSON with"
        Set peAnchors to anBottomLeftRight
    End_Object

    Object oOutput is a Form
        Set Size to 13 372
        Set Location to 271 105
        Set Label to "Path to write packages to:"
        Set Label_Col_Offset to 94
        Set peAnchors to anBottomLeftRight
        Set psToolTip to "Path to create your struct packages at"
        Set Prompt_Button_Mode to PB_PromptOn
        
        Procedure Activating
//            String  sAppSrc
            String  sPath iSep
            Handle hoCL
            Integer iLen i
            
            Forward Send Activating
            
//            Move (psAppSrcPath(phoWorkspace(oApplication(Desktop)))) to sAppSrc
//            Set Value to (sAppSrc + "\ApiStructs")
            
            Get phoCommandLine of oApplication to hoCL
            
            If (hoCL and CountOfArgs(hoCL)) Begin
                Get Argument of hoCL 1 to sPath
                If (sPath = "") Break
                
                Move (Length(sPath)) to iLen
                
                For i from 0 to (iLen - 1)
                    If (Mid(sPath, 1, (iLen - i)) = "\") Move (iLen - i) to iSep
                    If iSep Break
                Loop
                
                If iSep Begin
                    Set Value to  (Left(sPath, iSep) + "AppSrc\ApiStructs")
                End
                
            End
            
        End_Procedure
        
        Procedure Prompt
            Boolean bOK
            String  sPath sDir
            Handle  hWnd
            BrowseInfo tBI
            Integer iItem iOK i iLen

            Get Window_Handle           to tBI.hwndOwner
            Move "Select Output Folder" to tBI.lpszTitle
            Move 0                      to tBI.pidlRoot
            Move (BIF_NEWDIALOGSTYLE + BIF_UAHINT)   to tBI.ulFlags
            
            Move (SHBrowseForFolder(AddressOf(tBI))) to iItem
            
            If iItem Begin
                ZeroString 512                                      to sPath
                Move (SHGetPathFromIDList(iItem, AddressOf(sPath))) to iOK
                Move (CString(sPath))                               to sPath
                Set Value                                           to sPath
                
                Move (Length(sPath))    to iLen
                Move ""                 to sDir
                
                For i from 0 to iLen
                    
                    If (Mid(sPath, 1, (iLen - i)) = "\") Begin
                        Move (Right(sPath, i)) to sDir
                    End
                
                    If (sDir <> "") Break
                Loop
                
            End
            
            Set Value of oRelPath to sDir
        End_Procedure
        
    End_Object

    Object oRelPath is a Form
        Set Size to 13 330
        Set Location to 287 105
        Set Label to "Struct path relative to AppSrc:"
        Set Label_Col_Offset to 94
        Set Value to "ApiStructs"
        Set peAnchors to anBottomLeftRight
        Set psToolTip to "Relative path from you AppSrc directory to your structs directory"
    End_Object

    Object oIndent is a SpinForm
        Set Size to 13 23
        Set Location to 255 454
        Set Label to "Indent:"
        Set Label_Col_Offset to 26
        Set Spin_Value to 4
        Set psToolTip to "Number of spaces to indent each source code level"
        Set peAnchors to anBottomRight
    End_Object

    Object GenerateBtn is a Button
        Set Size to 14 39
        Set Location to 287 438
        Set Label to "Generate"
        Set peAnchors to anBottomRight
        Set psToolTip to "Generate the struct packages"
    
        Procedure OnClick
            Send Generate
        End_Procedure
    
    End_Object

//    Object oTestIt is a Button
//        Set Location to 245 433
//        Set Label to "Test it..."
//        
//        Procedure OnClick
//            String  sSource sNew
//            tJsonNode tJson
//            tSPAPIFilesBase tFiles
//            Boolean bOK
//            
//            Get Value of oJsonText to sSource
//            Send JsonStringToStruct of oStructHandler_tSPAPIFilesBase (&sSource) (&tFiles)
//            
//            Send StructToJsonString of oStructHandler_tSPAPIFilesBase (&tFiles) (&sNew)
//            Showln sNew
//            
//            Move 0 to WindowIndex
//        End_Procedure
//    
//    End_Object
    
CD_End_Object
