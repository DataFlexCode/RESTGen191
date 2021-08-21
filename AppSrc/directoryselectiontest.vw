//AB/ Project DirectorySelectionTest
//AB/ Object prj is a VIEW_Project
//AB/     Set ProjectName to "DirectorySelectionTest"
//AB/     Set ProjectFileName to "DirectorySelectionTest.VW"
//AB/     Set GenerateFileName to "NONAME"

// Project Object Structure
//   DirectorySelectionTest is a dbView
//     Form1 is a Form
//       oDirectSelect is a DirectorySelectDialog

// Register all objects
Register_Object DirectorySelectionTest
Register_Object Form1
Register_Object oDirectSelect


//AB/ AppBuild VIEW

//AB-IgnoreStart

Use DFAllEnt.pkg

//AB-IgnoreEnd

ACTIVATE_VIEW Activate_DirectorySelectionTest FOR DirectorySelectionTest

Object DirectorySelectionTest is a dbView
    Set Label to "DirectorySelectionTest"
    Set Size to 150 300
    Set Location to 28 95

    //AB-DDOStart


    //AB-DDOEnd

    Object Form1 is a Form

        //AB-StoreTopStart
        Use DirSel.pkg   // DirectorySelectDialog class package
        
        Object oDirectSelect is a DirectorySelectDialog
            set Label to "Choose Install Directory"
        End_Object  // oDirectSelect
        //AB-StoreTopEnd

        Set Label to "Select a Directory"
        Set Label_Col_Offset to 0
        Set Label_Justification_Mode to jMode_Top
        Set Prompt_Button_Mode to pb_PromptOn
        Set Size to 13 196
        Set Location to 63 49

        //AB-StoreStart
        Procedure Prompt
            local integer iDialog iOk
            local string sPath
        
            get Object_ID of (oDirectSelect(Self)) to iDialog
        
            send Show_Dialog to iDialog
        
            get piDirectorySelected of iDialog to iOk
        
            if (iOk<>0) begin
                get psSelectedDirectoryPath of iDialog to sPath
                set Value item 0 to sPath
            end
        End_Procedure  // Prompt
        //AB-StoreEnd

    End_Object    // Form1

End_Object    // DirectorySelectionTest

//AB/ End_Object    // prj
