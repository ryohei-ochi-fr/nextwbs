Option Explicit

Dim httpReq As New XMLHTTP60   '「Microsoft XML, v6.0」を参照設定
Const API_URL As String = "http://localhost:3000/"

Dim editTaskId As Boolean
Dim editTaskName As Boolean
Dim newTaskId As String
Dim colTaskId As Variant


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

    debugLogLevel = L_DEBUG

    
    ' TaskId 列(名前付きセル範囲)を格納する
    colTaskId = Range("TaskId")
    Call Logger(L_INFO, "TaskId 列を colTaskId へ格納")
    
    ' TaskId 列(名前付きセル範囲)の 選択時 最終行を格納する
    slrTaskId = Cells(Rows.Count, Range("TaskId").Column).End(xlUp).Row
    Call Logger(L_DEBUG, "TaskId 列の最終行 = " & slrTaskId)
    Cells(2, 4) = slrTaskId

    ' TaskName 列(名前付きセル範囲)の 選択時 最終行を格納する
    slrTaskName = Cells(Rows.Count, Range("TaskName").Column).End(xlUp).Row
    Call Logger(L_DEBUG, "TaskId 列の最終行 = " & slrTaskName)
    Cells(3, 4) = slrTaskName

End Sub

Private Sub Worksheet_Change(ByVal Target As Range)
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

    If editTaskName Then
        ' TaskName 列(名前付きセル範囲)の 編集後 最終行を格納する
        chrTaskName = Cells(Rows.Count, Range("TaskName").Column).End(xlUp).Row
        Call Logger(L_DEBUG, "TaskName 列の最終行 = " & chrTaskName)
        Cells(3, 5) = chrTaskName
        Cells(3, 6) = ""
        
        If slrTaskName < chrTaskName Then
            Cells(3, 6) = "行数増加"
            
            For i = 0 To Target.Rows.Count - 1
            
                If Cells(Target.Row + i, Range("TaskId").Column) = "" Then
                    res = getHttpRequest("GET", _
                        API_URL & "tasks/xml/" & "NEW" & "/" & _
                        Int(Rnd * 1000) _
                    )
                
                    Cells(Target.Row + i, Range("TaskId").Column) = _
                        WorksheetFunction.FilterXML(res, "/result/taskId")
                End If
            Next
        End If
    End If
    
    If editTaskId Then
        ' TaskId 列(名前付きセル範囲)の 編集後 最終行を格納する
        chrTaskId = Cells(Rows.Count, Range("TaskId").Column).End(xlUp).Row
        Call Logger(L_DEBUG, "TaskId 列の最終行 = " & chrTaskId)
        Cells(2, 5) = chrTaskId
        Cells(2, 6) = ""
        
        
        ' 行変化の判定
        If slrTaskId = chrTaskId Then
            Cells(2, 6) = "行数変化なし"
            Call Logger(L_INFO, "【判定】TaskId 行数変化なし" & "")
            
            For i = 0 To Target.Rows.Count - 1
                Cells(Target.Row + i, Range("TaskId").Column) = colTaskId(Target.Row + i, Range("TaskId").Column)
            Next i
        Else
            If slrTaskId < chrTaskId Then
                Cells(2, 6) = "行数増加"
    
                For i = 0 To Target.Rows.Count - 1
                
                    res = getHttpRequest("GET", _
                        API_URL & "tasks/xml/" & "NEW" & "/" & _
                        Int(Rnd * 1000) _
                    )
                
                    Cells(Target.Row + i, Range("TaskId").Column) = _
                        WorksheetFunction.FilterXML(res, "/result/taskId")
                
                Next
            Else
                Cells(2, 6) = "行数減少"
                
                For i = 0 To Target.Rows.Count - 1
                
                    If colTaskId(Target.Row + i, Range("TaskId").Column) <> "" Then
                
                        res = getHttpRequest("DELETE", _
                            API_URL & "tasks/" & colTaskId(Target.Row + i, Range("TaskId").Column))
                    End If
                Next
            End If
        End If
            
    End If
    


    ' changeイベントを再開する
    Application.EnableEvents = True

End Sub

Private Function getHttpRequest(ByVal method As String, ByVal urlString As String)
    
    Call Logger(L_INFO, "HTTPリクエスト = " & urlString)
    
    With httpReq
      .Open method, urlString
      .send
    End With
    
    ' todo 失敗時のリトライやエラー処理
    Do While httpReq.readyState < 4
        DoEvents
    Loop
    
    Call Logger(L_INFO, "HTTPレスポンス = " & httpReq.responseText)
    getHttpRequest = httpReq.responseText
    
End Function

Private Sub Logger(ByVal level As LOGLEVEL, ByVal massage As String)

    Dim category As String
    
    If level = L_DEBUG Then category = "DEBUG"
    If level = L_INFO Then category = "INFO "
    
    If level >= debugLogLevel Then
        Debug.Print category & ": " & massage
    End If
    
End Sub

