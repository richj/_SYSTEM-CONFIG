Attribute VB_Name = "Module1"
Sub UATReply()
     
    Dim Msg As Outlook.MailItem
    Dim MsgReply As Outlook.MailItem
    Dim strGreetName As String
    Dim lGreetType As Long
     
     ' set reference to open/selected mail item
    On Error Resume Next
    Select Case TypeName(Application.ActiveWindow)
    Case "Explorer"
        Set Msg = ActiveExplorer.Selection.item(1)
    Case "Inspector"
        Set Msg = ActiveInspector.CurrentItem
    Case Else
    End Select
    On Error GoTo 0
     
    If Msg Is Nothing Then GoTo ExitProc
     
     ' figure out greeting line
    On Error Resume Next

     
    Set MsgReply = Msg.ReplyAll
     
    With MsgReply
        .Subject = "DEPLOYED TO UAT:" & Msg.Subject
        .To = "UAT Release <UATRelease@Pulte.com>;" & Msg.Sender
        
        .HTMLBody = "<span style=""font-family : verdana;font-size : 10pt""><p>This has been successfully deployed to UAT</p><p>Please let me know if you have any questions</p><p>Thanks</p><p>Rich</p></span>" & .HTMLBody
        .Display
    End With
     
ExitProc:
    Set Msg = Nothing
    Set MsgReply = Nothing
End Sub


Sub PRODReply()
     
    Dim Msg As Outlook.MailItem
    Dim MsgReply As Outlook.MailItem
    Dim strGreetName As String
    Dim lGreetType As Long
     
     ' set reference to open/selected mail item
    On Error Resume Next
    Select Case TypeName(Application.ActiveWindow)
    Case "Explorer"
        Set Msg = ActiveExplorer.Selection.item(1)
    Case "Inspector"
        Set Msg = ActiveInspector.CurrentItem
    Case Else
    End Select
    On Error GoTo 0
     
    If Msg Is Nothing Then GoTo ExitProc
     
     ' figure out greeting line
    On Error Resume Next

     
    Set MsgReply = Msg.ReplyAll
     
    With MsgReply
        .Subject = "DEPLOYED TO PRODUCTION:" & Msg.Subject
        .To = "PFS CM Release <PFSCMRelease@Pulte.com>;"
        
        .HTMLBody = "<span style=""font-family : verdana;font-size : 10pt""><p>This has been successfully deployed to PRODUCTION and is ready for verification/shakeout.</p><p>Any relevant script results are below if available.</p><p>Please let me know if you have any questions</p><p>Thanks</p><p>Rich</p></span>" & .HTMLBody
        .Display
    End With
     
ExitProc:
    Set Msg = Nothing
    Set MsgReply = Nothing
End Sub

Sub PRODStart()
     
    Dim Msg As Outlook.MailItem
    Dim MsgReply As Outlook.MailItem
    Dim strGreetName As String
    Dim lGreetType As Long
     
     ' set reference to open/selected mail item
    On Error Resume Next
    Select Case TypeName(Application.ActiveWindow)
    Case "Explorer"
        Set Msg = ActiveExplorer.Selection.item(1)
    Case "Inspector"
        Set Msg = ActiveInspector.CurrentItem
    Case Else
    End Select
    On Error GoTo 0
     
    If Msg Is Nothing Then GoTo ExitProc
     
     ' figure out greeting line
    On Error Resume Next

     
    Set MsgReply = Msg.ReplyAll
     
    With MsgReply
        .Subject = "COMMENCING DEPLOYMENT TO PRODUCTION:" & Msg.Subject
        .To = "PFS CM Release <PFSCMRelease@Pulte.com>;"
        
        .HTMLBody = "<span style=""font-family : verdana;font-size : 10pt""><p>Beginning deployment for this PCR</p><p>Thanks</p><p>Rich</p></span>" & .HTMLBody
        .Display
    End With
     
ExitProc:
    Set Msg = Nothing
    Set MsgReply = Nothing
End Sub

Sub DueMonday()

    Dim sel As Outlook.Selection
    Set sel = Application.ActiveExplorer.Selection
    Dim DayToStart As Date
    Dim item As Object
    Dim i As Integer
    
    DayToStart = (Now + (9 - Weekday(Now)))
    For i = 1 To sel.Count
         Set item = sel.item(i)
         If item.Class = olMail Then
                Dim mail As MailItem
                Set mail = item
                mail.MarkAsTask (olMarkNoDate)
                mail.TaskStartDate = DayToStart
                
                StrCats = mail.Categories
                If InStr(StrCats, "PCRs") = 0 Then
                    If Not StrCats = "" Then
                        StrCats = StrCats & ","
                    End If
                    StrCats = StrCats & "#PCRs - Myne"
                    mail.Categories = StrCats
                End If
                mail.Save
         End If

    Next i


End Sub

Sub Defer()

    Dim sel As Outlook.Selection
    Set sel = Application.ActiveExplorer.Selection
    Dim DayToStart As Date
    Dim item As Object
    Dim i As Integer
    
    DeferDays = InputBox("Days to defer", "Defer", 1)
    If IsNumeric(DeferDays) Then
        DayToStart = Now + DeferDays
        For i = 1 To sel.Count
             Set item = sel.item(i)
             If item.Class = olMail Then
                    Dim mail As MailItem
                    Set mail = item
                    mail.MarkAsTask (olMarkNoDate)
                    mail.TaskStartDate = DayToStart
                    
                    StrCats = mail.Categories
                    If InStr(StrCats, "PCRs") = 0 Then
                        If Not StrCats = "" Then
                            StrCats = StrCats & ","
                        End If
                        StrCats = StrCats & "#PCRs - Myne"
                        mail.Categories = StrCats
                    End If
                    mail.Save
             End If
    
        Next i
    End If
End Sub

Sub Postpone()

    Dim sel As Outlook.Selection
    Set sel = Application.ActiveExplorer.Selection
    Dim DayToStart As Date
    Dim item As Object
    Dim i As Integer
    
    DeferDays = InputBox("Days to postpone", "Postpone", 1)
    If IsNumeric(DeferDays) Then
        DayToStart = Now + DeferDays
        For i = 1 To sel.Count
             Set item = sel.item(i)
             If item.Class = olTask Then
                    Dim Task As TaskItem
                    Set Task = item
                    Task.StartDate = DayToStart
                    Task.Save
             End If
    
        Next i
    End If
End Sub

Sub LateTasksNoMore()

    Dim myNameSpace As Outlook.NameSpace
    Dim myFolder As Outlook.Folder
    Dim myItem As Outlook.TaskItem
    Dim allItems As Outlook.Items
    Dim myItems As Outlook.Items
    
    Set myNameSpace = Application.GetNamespace("MAPI")
    Set myFolder = myNameSpace.GetDefaultFolder(olFolderTasks)
    Set allItems = myFolder.Items

    Let StrFilter = "([StartDate] < '" & Format(Date, "ddddd") & "') And NOT([Complete] = TRUE)"
    
    Set myItems = allItems.Restrict(StrFilter)

    For Each myItem In myItems
        myItem.StartDate = Now()
        myItem.DueDate = Now()
        myItem.Save
    Next myItem

End Sub

Sub INBOX()
    Dim olApp As Outlook.Application
    Dim objNS As Outlook.NameSpace
    Dim rootFolder As Outlook.Folder
    Dim myNewFolder As Outlook.Folder
    Dim inTask As Outlook.TaskItem
    Set olApp = Outlook.Application
    Set objNS = olApp.GetNamespace("MAPI")
    Set rootFolder = objNS.GetDefaultFolder(olFolderTasks)
  
    Set myNewFolder = rootFolder.Folders("_Inbox")
        
    For Each inTask In myNewFolder.Items
            inTask.StartDate = Now()
            inTask.DueDate = Now()
            inTask.Save
    Next
ProgramExit:
      Exit Sub
ErrorHandler:
      MsgBox Err.Number & " - " & Err.Description
      Resume ProgramExit
End Sub


Sub A1Today()

    Dim myNameSpace As Outlook.NameSpace
    Dim myFolder As Outlook.Folder
    Dim myItem As Outlook.TaskItem
    Dim allItems As Outlook.Items
    Dim myItems As Outlook.Items
    
    Set myNameSpace = Application.GetNamespace("MAPI")
    Set myFolder = myNameSpace.GetDefaultFolder(olFolderTasks)
    Set allItems = myFolder.Items

    Let StrFilter = "([StartDate] < '" & Format(Date, "ddddd") & "') And NOT([Complete] = TRUE)"
    
    Set myItems = allItems.Restrict(StrFilter)

    For Each myItem In myItems
        myItem.StartDate = Now()
        myItem.DueDate = Now()
        myItem.Save
    Next myItem

    Dim olApp As Outlook.Application
    Dim objNS As Outlook.NameSpace
    Dim rootFolder As Outlook.Folder
    Dim myNewFolder As Outlook.Folder
    Dim inTask As Outlook.TaskItem
    Set olApp = Outlook.Application
    Set objNS = olApp.GetNamespace("MAPI")
    Set rootFolder = objNS.GetDefaultFolder(olFolderTasks)
  
    Set myNewFolder = rootFolder.Folders("_Inbox")
        
    For Each inTask In myNewFolder.Items
            inTask.StartDate = Now()
            inTask.DueDate = Now()
            inTask.Save
    Next
ProgramExit:
      Exit Sub
ErrorHandler:
      MsgBox Err.Number & " - " & Err.Description
      Resume ProgramExit
End Sub

Sub StartEQDue()

    Dim myNameSpace As Outlook.NameSpace
    Dim myFolder As Outlook.Folder
    Dim myItem As Outlook.TaskItem
    Dim allItems As Outlook.Items
    Dim myItems As Outlook.Items
    
    Set myNameSpace = Application.GetNamespace("MAPI")
    Set myFolder = myNameSpace.GetDefaultFolder(olFolderTasks)
    Set allItems = myFolder.Items

    'Let StrFilter = "(([StartDate] <> [DueDate]) And NOT([Complete] = TRUE)"
    Let StrFilter = "([Complete] = TRUE)"
    
    Set myItems = allItems.Restrict(StrFilter)

    For Each myItem In myItems
        MsgBox (myItem.Subject)
        
        'myItem.StartDate = Now()
        'myItem.DueDate = Now()
        'myItem.Save
    Next myItem

End Sub
