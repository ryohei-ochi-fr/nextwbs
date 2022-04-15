Option Explicit
Dim editTaskId As Boolean
Dim editTaskName As Boolean

' 選択時の最終行
Dim slrTaskId As Long
' 変更後の最終行
Dim chrTaskId As Long

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

    
    ' TaskId 列(名前付きセル範囲)の 選択時 最終行を格納する
    slrTaskId = Cells(Rows.Count, Range("TaskId").Column).End(xlUp).Row
    Call Logger(L_DEBUG, "TaskId 列の最終行 = " & slrTaskId)
    Cells(2, 4) = slrTaskId

End Sub

Private Sub Worksheet_Change(ByVal Target As Range)
    editTaskId = True
    editTaskName = True
    Dim i As Long
    Dim rcTaskId As Long
    Dim rcTaskName As Long
    
    
    ' TaskId列が編集されたか判定
    If Intersect(Target, Range("TaskId")) Is Nothing Then
        editTaskId = False
    End If

    ' changeイベントを停止する
    Application.EnableEvents = False

    
    ' TaskId 列(名前付きセル範囲)の 編集後 最終行を格納する
    chrTaskId = Cells(Rows.Count, Range("TaskId").Column).End(xlUp).Row
    Call Logger(L_DEBUG, "TaskId 列の最終行 = " & chrTaskId)
    Cells(2, 5) = chrTaskId
    
    ' 行変化の判定
    If slrTaskId = chrTaskId Then
        Cells(2, 6) = "行数変化なし"
    Else
        If slrTaskId < chrTaskId Then
            Cells(2, 6) = "行数増加"
        Else
            Cells(2, 6) = "行数減少"
        End If
    End If
    

    ' changeイベントを再開する
    Application.EnableEvents = True

End Sub

Private Sub Logger(ByVal level As LOGLEVEL, ByVal massage As String)

    Dim category As String
    
    If level = L_DEBUG Then category = "DEBUG"
    If level = L_INFO Then category = "INFO"
    
    If level >= debugLogLevel Then
        Debug.Print category & ": " & massage
    End If
    
End Sub

