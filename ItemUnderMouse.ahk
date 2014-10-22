/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\ItemUnderMouse.exe
Created_Date=1
[VERSION]
Set_Version_Info=1
Company_Name=TheQwerty
File_Description=Helper application for ItemUnderMouse XYplorer script.
File_Version=1.0.0.0
Inc_File_Version=1
Product_Name=ItemUnderMouse
Product_Version=1.1.16.5
Set_AHK_Version=1
[ICONS]
Icon_1=%In_Dir%\res\icon.ico
Icon_2=%In_Dir%\res\icon.ico
Icon_3=%In_Dir%\res\icon.ico
Icon_4=%In_Dir%\res\icon.ico
Icon_5=%In_Dir%\res\icon.ico
Icon_6=%In_Dir%\res\icon.ico
Icon_7=%In_Dir%\res\icon.ico

* * * Compile_AHK SETTINGS END * * *
*/

/*
================================================================================
ItemUnderMouse.ahk

Sends information about the current mouse position back to a calling window
via a WM_COPYDATA message.

Also focuses the control under the mouse cursor if the mouse is over the
calling window.


[ABOUT]
Author    = TheQwerty
Date      = 2014-10-22 18:00z
Requires  = AHK_L v1.1.16.05

[]
================================================================================
*/


#NoTrayIcon
#NoEnv
#SingleInstance FORCE

; Default message
result = 0|Unknown

; Ensure we were passed an argument.
if 0 != 1
{
	MsgBox Usage:  %A_ScriptName% xyHwnd
	result = -1|Missing caller hwnd.
}
else
{
	; Ensure argument is an existing window.
	hwnd = %1%
	IfWinNotExist, ahk_id %hwnd%
	{
		MsgBox Window '%hwnd%' not found.
		result = -1|Caller hwnd does not exist.
	}
	else
	{
		; Get mouse coordinates relative to screen.
		CoordMode Mouse, Screen
		MouseGetPos x, y, win, ctrl, 0
		result = 1|%win%|%ctrl%|%x%|%y%

		; Control names can change in XY, so
		; if the mouse is over the calling window
		; focus the control under the mouse.
		if (win == hwnd)
		{
			MouseGetPos ,,,, ctrlHwnd, 2
			ControlFocus,, ahk_id %ctrlHwnd%
		}
	}
}

; Send the information back to specified window.
size := StrLen(result)
if A_IsUnicode
{
	data := result
}
else
{
	VarSetCapacity(data, size*2, 0)
	StrPut(result, &data, size, "UTF-16")
}

VarSetCapacity(COPYDATA, A_PtrSize * 3, 0)
NumPut(4194305, COPYDATA, 0, "Ptr")
NumPut(size*2, COPYDATA, A_PtrSize, "UInt")
NumPut(&data, COPYDATA, A_PtrSize*2, "Ptr")
SendMessage 0x4a, 0, &COPYDATA,, ahk_id %hwnd%