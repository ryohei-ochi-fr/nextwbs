Option Explicit

' include JsonConverter.bas
' from https://github.com/VBA-tools/VBA-JSON
Dim httpReq As New XMLHTTP60   '「Microsoft XML, v6.0」を参照設定
Dim params As New Dictionary   '「Microsoft Scripting Runtime」を参照設定
Const API_URL As String = "http://133.189.3.70:3000"

Dim colTaskId As Variant
Dim rlTaskId As Long
Dim rlTaskName As Long

Dim debugLogLevel As Integer

Enum LOGLEVEL
    L_DEBUG = 1
    L_INFO = 2
    L_WARN = 3
    L_ERROR = 4
    L_FATAL = 5
End Enum

Dim editTaskId As Boolean
Dim editTaskName As Boolean

Private Sub Worksheet_SelectionChange(ByVal Target As Range)

    debugLogLevel = L_INFO


    On Error GoTo ENDUP
    
    'If Intersect(Target, Range("TaskId")) Is Nothing Then Exit Sub
    
    ' TaskId 列(名前付きセル範囲)を格納する
    colTaskId = Range("TaskId")
    Call Logger(L_INFO, "TaskId 列を colTaskId へ格納")
    
    ' TaskId 列(名前付きセル範囲)の最終行を格納する
    rlTaskId = Cells(Rows.Count, Range("TaskId").Column).End(xlUp).Row
    Call Logger(L_DEBUG, "TaskId 列の最終行 = " & rlTaskId)
    
    ' TaskName 列(名前付きセル範囲)の最終行を格納する
    rlTaskName = Cells(Rows.Count, Range("TaskName").Column).End(xlUp).Row
    Call Logger(L_DEBUG, "TaskName 列の最終行 = " & rlTaskName)
    

ENDUP:

End Sub

Private Sub Worksheet_Change(ByVal Target As Range)
    'On Error Resume Next
    
    Dim i As Long
    Dim rcTaskId, rcTaskName
    
    editTaskId = True
    editTaskName = True
    
    If Intersect(Target, Range("TaskId")) Is Nothing Then
        editTaskId = False
    End If
    
    
    If Intersect(Target, Range("TaskName")) Is Nothing Then
        editTaskName = False
    End If
    
    
    If editTaskId Or editTaskName Then
    
       ' 列の最終行を取得する
       rcTaskId = Cells(Rows.Count, Range("TaskId").Column).End(xlUp).Row
       rcTaskName = Cells(Rows.Count, Range("TaskName").Column).End(xlUp).Row
       
       
       Call Logger(L_DEBUG, "変更行 = " & Target.Row)
       Call Logger(L_DEBUG, "変更行数 = " & Target.Rows.Count)
       
       
       
       
       '**************************************************************************************
       ' close todo 列の挿入、削除イベント判定
       ' close todo TaskNameコピペ 複数行の処理
       ' todo TaskId列 未入力行での挿入をキャンセル
       ' todo 行コピーで既存を上書きした場合の復元とキャンセル
       '**************************************************************************************
       
       
       
       Call Logger(L_DEBUG, "rcTaskId = " & rcTaskId)
       Call Logger(L_DEBUG, "rlTaskId = " & rlTaskId)
       
       Dim newTaskId As String
       Dim newTaskName As String
       
       
       ' changeイベントを停止する
       Application.EnableEvents = False
       
       ' 変更された行を復元する(行数変化なし)
       If rlTaskId = rcTaskId Then
           Call Logger(L_INFO, "【判定】TaskId 行数変化なし" & "")
           
           For i = 0 To Target.Count - 1
               Cells(Target.Row + i, Range("TaskId").Column) = colTaskId(Target.Row + i, Range("TaskId").Column)
           Next i
           
           ' TaskName 列が増加した場合、TaskId を採番
           If rlTaskName <> rcTaskName Then
               Call Logger(L_INFO, "【判定】TaskName 列の行が増減" & "")
               
               For i = 0 To Target.Rows.Count - 1
               
                   If Cells(Target.Row + i, Range("TaskId").Column) = "" Then
                       
                       newTaskName = Cells(Target.Row + i, Range("TaskName").Column).Value
                       
                       newTaskId = getHttpRequest( _
                           API_URL & "/tasks/" & _
                           newTaskName & "/" & _
                           Int(Rnd * 1000) _
                       )
                       
                       Cells(Target.Row + i, Range("TaskId").Column) = newTaskId
                       
                   End If
               Next
           End If
       End If
       
       If rlTaskId < rcTaskId Then
           Call Logger(L_INFO, "【判定】TaskId 行数が増加" & "")
           
           ' 挿入された行にTaskIdをセットする(行数が増加)
           For i = 0 To Target.Rows.Count - 1
           
               If Cells(Target.Row + i, Range("TaskId").Column) = "" Then
                   
                   newTaskName = Cells(Target.Row + i, Range("TaskName").Column).Value
                   
                   If newTaskName = "" Then newTaskName = "new"
                   
                   newTaskId = getHttpRequest( _
                       API_URL & "/tasks/" & _
                       newTaskName & "/" & _
                       Int(Rnd * 1000) _
                   )
               
                   Cells(Target.Row + i, Range("TaskId").Column) = newTaskId
                   
               End If
           Next i
           
       End If
       
       If rlTaskId > rcTaskId Then
           Call Logger(L_INFO, "【判定】TaskId 行数が減少" & "")
           
           ' 削除された行のTaskIdをDELETEする(行数が減少)
           For i = 0 To Target.Rows.Count - 1
               
               With httpReq
                 .Open "DELETE", API_URL & "/tasks/" & colTaskId(Target.Row + i, Range("TaskId").Column)
                 .send
               End With
               
               Do While httpReq.readyState < 4
                   DoEvents
               Loop
    
               Call Logger(L_INFO, "【結果】DELETE TaskId = " & colTaskId(Target.Row + i, Range("TaskId").Column))
    
           Next i
           
       End If
       
       ' changeイベントを再開する
       Application.EnableEvents = True
    End If
    
End Sub

Private Function getHttpRequest(ByVal urlString As String)
    
    With httpReq
      .Open "GET", urlString
      .send
    End With
    
    Do While httpReq.readyState < 4
        DoEvents
    Loop
    
    Call Logger(L_INFO, "GETレスポンス = " & httpReq.responseText)

    ' JSONパース
    Dim jsonObj As Object
    Set jsonObj = JsonConverter.ParseJson(httpReq.responseText)
    
    Call Logger(L_INFO, "JSON整形 = " & JsonConverter.ConvertToJson(jsonObj, " "))
    
    Call Logger(L_INFO, "【結果】INSERT TaskId = " & jsonObj("taskId"))
    getHttpRequest = jsonObj("taskId")
    
    
    ' todo 失敗時のリトライやエラー処理
    
End Function


Private Sub Logger(ByVal level As LOGLEVEL, ByVal massage As String)

    Dim category As String
    
    If level = L_DEBUG Then category = "DEBUG"
    If level = L_INFO Then category = "INFO"
    
    If level >= debugLogLevel Then
        Debug.Print category & ": " & massage
    End If
    
End Sub
