Option Explicit

' rev.012

Dim httpReq As New XMLHTTP60   '「Microsoft XML, v6.0」を参照設定
Dim ServerIP As String
Dim ServerPort As String
Dim TaskIdIssue As Boolean
Dim TaskIdProtect As Boolean
Dim TaskIdDelete As Boolean

Dim editTaskId As Boolean
Dim editTaskName As Boolean
Dim newTaskId As String
Dim colTaskId As Variant
Dim colTaskId2 As Variant


' 選択時の最終行
Dim slrTaskId As Long
Dim slrTaskName As Long
' 変更後の最終行
Dim chrTaskId As Long
Dim chrTaskName As Long

Dim debugLogLevel As Integer

Enum LOGLEVEL
    L_DEBUG = 1
    L_INFO = 2
    L_WARN = 3
    L_ERROR = 4
    L_FATAL = 5
End Enum

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
    
    TaskIdProtect = Worksheets("環境設定").Range("TaskIdProtect").Value

    
    Call Logger(L_INFO, ServerIP)
    Call Logger(L_INFO, "TaskId 列を colTaskId へ格納")
    
    debugLogLevel = L_ERROR

    
    If TaskIdProtect Then
    
        debugLogLevel = L_INFO
    
    
        ' TaskId 列(名前付きセル範囲)を格納する
        colTaskId = Range("TaskId")
        
        'Call Logger(L_INFO, "TaskId 列を colTaskId へ格納")
        
        ' TaskId 列(名前付きセル範囲)の 選択時 最終行を格納する
        slrTaskId = Cells(Rows.Count, Range("TaskId").Column).End(xlUp).Row
        'Call Logger(L_DEBUG, "TaskId 列の最終行 = " & slrTaskId)
    
        ' TaskName 列(名前付きセル範囲)の 選択時 最終行を格納する
        slrTaskName = Cells(Rows.Count, Range("TaskName").Column).End(xlUp).Row
        'Call Logger(L_DEBUG, "TaskName 列の最終行 = " & slrTaskName)
        
    End If

End Sub

Private Sub Worksheet_Change(ByVal Target As Range)
    ServerIP = Worksheets("環境設定").Range("ServerIP").Value
    ServerPort = Worksheets("環境設定").Range("ServerPort").Value
    
    TaskIdProtect = Worksheets("環境設定").Range("TaskIdProtect").Value
    TaskIdIssue = Worksheets("環境設定").Range("TaskIdIssue").Value
    TaskIdDelete = Worksheets("環境設定").Range("TaskIdDelete").Value
    
    If TaskIdProtect Then
    
        editTaskId = True
        editTaskName = True
        
        Dim i As Long
        Dim rcTaskId As Long
        Dim rcTaskName As Long
        Dim res As String
    
        ' TaskId 列が編集されたか判定
        If Intersect(Target, Range("TaskId")) Is Nothing Then
            editTaskId = False
        End If
        
        ' TaskName 列が編集されたか判定
        If Intersect(Target, Range("TaskName")) Is Nothing Then
            editTaskName = False
        End If

        ' changeイベントを停止する
        Application.EnableEvents = False
        
        On Error GoTo ENDCODE
        
        ' todo TaskIdが空なら発番
        
    
        If editTaskName And Not editTaskId Then
            ' TaskName 列(名前付きセル範囲)の 編集後 最終行を格納する
            chrTaskName = Cells(Rows.Count, Range("TaskName").Column).End(xlUp).Row
            Call Logger(L_DEBUG, "TaskName 列の最終行 = " & chrTaskName)
            
            If slrTaskName < chrTaskName Then
            
                If TaskIdIssue Then
    
                    ' 行数増加
                    For i = 0 To Target.Rows.Count - 1
                    
                        If Cells(Target.Row + i, Range("TaskId").Column) = "" Then
                            res = getTaskId()
                        
                            Cells(Target.Row + i, Range("TaskId").Column) = _
                                WorksheetFunction.FilterXML(res, "/result/taskId")
                        End If
                    Next
                End If
            End If
        End If
        
        If editTaskId Then
            ' TaskId 列(名前付きセル範囲)の 編集後 最終行を格納する
            chrTaskId = Cells(Rows.Count, Range("TaskId").Column).End(xlUp).Row
            Call Logger(L_DEBUG, "TaskId 列の最終行 = " & chrTaskId)
    
            
            
            ' 行変化の判定
            If slrTaskId = chrTaskId Then
                
                If TaskIdProtect Then
                
                    ' 行数変化なし
                    Call Logger(L_INFO, "【判定】TaskId 行数変化なし" & "")
                    
                    For i = 0 To Target.Rows.Count - 1
                        Cells(Target.Row + i, Range("TaskId").Column) = colTaskId(Target.Row + i, 1)
                    Next i
                
                End If

            Else
                If slrTaskId < chrTaskId Then
                    
                    If TaskIdIssue Then
                        
                        ' 行数増加
                        For i = 0 To Target.Rows.Count - 1
                        
                            res = getTaskId()
                        
                            Cells(Target.Row + i, Range("TaskId").Column) = _
                                WorksheetFunction.FilterXML(res, "/result/taskId")
                        
                        Next
                    End If
                Else
                    
                    If TaskIdDelete Then
    
                        ' 行数減少
                        For i = 0 To Target.Rows.Count - 1
                        
                            If colTaskId(Target.Row + i, 1) <> "" Then
                        
                                res = deleteTaskId(colTaskId(Target.Row + i, 1))
                                
                            End If
                        Next
                    End If
                End If
            End If
                
        End If
    
    End If

ENDCODE:
    ' changeイベントを再開する
    Application.EnableEvents = True

End Sub
Private Function deleteTaskId(ByVal taskId As String)
    
    With httpReq
        .Open "DELETE", _
              "http://" & ServerIP & ":" & ServerPort & _
              "/tasks/" & taskId
        .send
    End With
    
    ' todo 失敗時のリトライやエラー処理
    Do While httpReq.readyState < 4
        DoEvents
    Loop
    
    Call Logger(L_INFO, "HTTPレスポンス = " & httpReq.responseText)
    deleteTaskId = httpReq.responseText
    
End Function

Private Function getTaskId()
    
    With httpReq
        .Open "GET", _
              "http://" & ServerIP & ":" & ServerPort & _
              "/tasks/xml/" & "NEWTASK" & "/" & _
              Int(Rnd * 1000)
        .send
    End With
    
    ' todo 失敗時のリトライやエラー処理
    Do While httpReq.readyState < 4
        DoEvents
    Loop
    
    Call Logger(L_INFO, "HTTPレスポンス = " & httpReq.responseText)
    getTaskId = httpReq.responseText
    
End Function

Private Sub Logger(ByVal level As LOGLEVEL, ByVal massage As String)

    Dim category As String
    
    If level = L_DEBUG Then category = "DEBUG"
    If level = L_INFO Then category = "INFO "
    
    If level >= debugLogLevel Then
        Debug.Print category & ": " & massage
    End If
    
End Sub