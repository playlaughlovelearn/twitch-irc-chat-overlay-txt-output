SetTitleMatchMode, 2
start:
OnExit, exit
WinGetTitle,title,Viewers:
StringSplit,title_array,title,%A_Space%
Loop, %title_array0%
{
    part := title_array%a_index%
    ;MsgBox, Color number %a_index% is %part%.
    IfInString,part,Viewers
    {
    StringSplit,part_array,part,:
    }
}

FileName :=  A_WorkingDir . "\viewers.txt"

file := FileOpen(FileName, "w")
file.Write(%part_array2%)
file.Close()
Sleep, 5000
Goto, start
exit:
FileDelete, viewers.txt

