.386                            ;

.model flat,stdcall             ;

option casemap:none             

include windows.inc
include ole32.inc
includelib  gdi32.lib
include gdi32.inc
includelib  user32.lib
include user32.inc
includelib	kernel32.lib
include kernel32.inc
includelib	comctl32.lib
include	comctl32.inc
includelib	shell32.lib
include shell32.inc
includelib	msvcrt.lib
includelib  ole32.lib

printf PROTO C :ptr sbyte, :VARARG	
scanf PROTO C :ptr sbyte, :VARARG
strlen PROTO C :ptr sbyte, :VARARG
sscanf PROTO C :dword, :dword, :vararg
sprintf PROTO C :dword, :dword, :vararg

.data                           
H_app dd ? ;存放应用程序的句柄
H_win dd ? ;存放窗口的句柄

tips db "计算器: Designed by Zhang Chi",0
winClassName db "计算器",0
winCaptionName db "计算器",0
edit byte "edit", 0
static byte "static", 0
button byte "button", 0

numdata db ".", 0
num0 byte "0", 0
num1 byte "1", 0
num2 byte "2", 0
num3 byte "3", 0
num4 byte "4", 0
num5 byte "5", 0
num6 byte "6", 0
num7 byte "7", 0
num8 byte "8", 0
num9 byte "9", 0
point byte ".", 0
divop byte "/", 0
mulop byte "*", 0
subop byte "-", 0
addop byte "+", 0
equop byte "=", 0
sinop byte "sin", 0
cosop byte "cos", 0
tanop byte "tan", 0
back byte " ", 0
ceop byte "CE",0

hInstance		dd	?					;主程序句柄
tempOutput		db  ".",0,30 dup(0) ;临时字符串
Output			db	30 dup(0)	;输出字符串

nstack			dq 30 dup(0.0)
ntop			dd 0               ;运算数栈

opstack			db 30 dup(0)         ;运算符栈
optop			dd 0

formatStr       db '%lf',0
formatStr2      db '%f',0

;---------------------------- 常量声明 ----------------------------
ID_NUM0	equ 300
ID_NUM1	equ 301
ID_NUM2 equ 302
ID_NUM3	equ 303
ID_NUM4	equ 304
ID_NUM5	equ 305
ID_NUM6	equ 306
ID_NUM7	equ 307
ID_NUM8	equ 308
ID_NUM9	equ 309

.code

_WinMain proc uses ebx edi esi, hWnd, uMsg, wParam, lParam
		local structps: PAINTSTRUCT
		local structrect: RECT
		local hDc

		mov eax, uMsg

		.IF eax == WM_PAINT
			invoke BeginPaint, hWnd, addr structps
			mov hDc, eax
			invoke EndPaint, hWnd, addr structps
		
		.ELSEIF eax == WM_CLOSE
			invoke DestroyWindow, H_win
			invoke PostQuitMessage, NULL
		
		.ELSEIF eax == WM_CREATE
			invoke CreateWindowEx, NULL, offset static, offset tips, WS_CHILD or WS_VISIBLE, 5, 10, 300, 20, hWnd, 100, H_app, NULL

			invoke CreateWindowEx, WS_EX_RIGHT, offset static, offset Output, WS_CHILD or WS_VISIBLE or WS_BORDER OR WS_SIZEBOX, 30, 50, 145, 50, hWnd, 90, H_app, NULL ; txt

			invoke CreateWindowEx, NULL, OFFSET button, OFFSET num0, WS_CHILD OR  WS_VISIBLE, 30, 230, 55, 25, hWnd, 300, H_app, NULL ; 0
			
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET point, WS_CHILD OR  WS_VISIBLE, 90, 230, 25, 25, hWnd, 12, H_app, NULL ; .
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET addop, WS_CHILD OR  WS_VISIBLE, 120, 230, 25, 25, hWnd, 13, H_app, NULL ; +
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET equop, WS_CHILD OR  WS_VISIBLE, 150, 230, 25, 25, hWnd, 17, H_app, NULL ; =

			invoke CreateWindowEx, NULL, OFFSET button, OFFSET num1, WS_CHILD OR  WS_VISIBLE, 30, 200, 25, 25, hWnd, 301, H_app, NULL;1
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET num2, WS_CHILD OR  WS_VISIBLE, 60, 200, 25, 25, hWnd, 302, H_app, NULL;2
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET num3, WS_CHILD OR  WS_VISIBLE, 90, 200, 25, 25, hWnd, 303, H_app, NULL;3
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET subop, WS_CHILD OR  WS_VISIBLE, 120, 200, 25, 25, hWnd, 14, H_app, NULL ; -
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET sinop, WS_CHILD OR  WS_VISIBLE, 150, 200, 25, 25, hWnd, 18, H_app, NULL ; sin

			invoke CreateWindowEx, NULL, OFFSET button, OFFSET num4, WS_CHILD OR  WS_VISIBLE, 30, 170, 25, 25, hWnd, 304, H_app, NULL;4
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET num5, WS_CHILD OR  WS_VISIBLE, 60, 170, 25, 25, hWnd, 305, H_app, NULL;5
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET num6, WS_CHILD OR  WS_VISIBLE, 90, 170, 25, 25, hWnd, 306, H_app, NULL;6
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET mulop, WS_CHILD OR  WS_VISIBLE, 120, 170, 25, 25, hWnd, 15, H_app, NULL ; *
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET cosop, WS_CHILD OR  WS_VISIBLE, 150, 170, 25, 25, hWnd, 19, H_app, NULL ; cos

			invoke CreateWindowEx, NULL, OFFSET button, OFFSET num7, WS_CHILD OR  WS_VISIBLE, 30, 140, 25, 25, hWnd, 307, H_app, NULL;7
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET num8, WS_CHILD OR  WS_VISIBLE, 60, 140, 25, 25, hWnd, 308, H_app, NULL;8
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET num9, WS_CHILD OR  WS_VISIBLE, 90, 140, 25, 25, hWnd, 309, H_app, NULL;9
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET divop, WS_CHILD OR  WS_VISIBLE, 120, 140, 25, 25, hWnd, 16, H_app, NULL ; /
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET tanop, WS_CHILD OR  WS_VISIBLE, 150, 140, 25, 25, hWnd, 20, H_app, NULL ; tan

			invoke CreateWindowEx, NULL, OFFSET button, OFFSET back, WS_CHILD OR  WS_VISIBLE, 30, 110, 85, 25, hWnd, 21, H_app, NULL ;保留按钮，为了美观，之后优化可以为其添加同能
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET ceop, WS_CHILD OR  WS_VISIBLE, 120, 110, 55, 25, hWnd, 22, H_app, NULL ; CE

		.ELSEIF	eax == WM_COMMAND
			mov eax,wParam
			.if eax == 22 ;CE
				mov [ntop],0
				mov [optop],0
				mov BYTE PTR[Output],0
				invoke SetDlgItemText, hWnd, 90, offset Output
			.elseif (eax <= ID_NUM9) && (eax >= ID_NUM0)
				sub	eax,ID_NUM0
				add eax,30h
				mov bl,al
				invoke strlen,addr Output
				.if (byte ptr[Output+eax-1]<'0')||(byte ptr[Output+eax-1]>'9')
					.if byte ptr[Output+eax-1]!='.'
					xor	eax,eax
					.endif
				.endif
				
				mov byte ptr[Output+eax],bl
				mov byte ptr[Output+1+eax],0
				invoke SetDlgItemText, hWnd, 90, offset Output
			
			.elseif eax==12
				invoke strlen,addr Output
				.if (byte ptr[Output+eax-1] != '.')
					mov byte ptr[Output+eax],'.'
					mov byte ptr[Output+1+eax],0
				.endif
				invoke SetDlgItemText, hWnd, 90, offset Output

			.elseif (eax>=13) && (eax<=16)           ;+-*/
				push eax
			    mov ebx,[ntop]
				invoke sscanf,addr Output,addr formatStr,addr nstack[ebx*8]
				inc [ntop]                                ;运算符之前的操作数入栈
				.if [optop]>0
					fld qword ptr[nstack]
					.if byte ptr[opstack]=='+'
						fadd qword ptr[nstack+8]
					.elseif byte ptr[opstack]=='-'
						fsub qword ptr[nstack+8]
					.elseif byte ptr[opstack]=='*'
						fmul qword ptr[nstack+8]
					.else
						fdiv qword ptr[nstack+8]
					.endif
					fstp qword ptr[nstack]
					dec [ntop]
					dec [optop]
				.endif
				pop eax
				.if eax==13
					mov byte ptr[Output],'+'
				.elseif eax==14
					mov byte ptr[Output],'-'
				.elseif eax==15
					mov byte ptr[Output],'*'
				.else
					mov byte ptr[Output],'/'
				.endif
				
				mov byte ptr[Output+1],0
				mov al,byte ptr [Output]
				mov byte ptr [opstack],al
				inc [optop]
				invoke SetDlgItemText, hWnd, 90, offset Output
			.elseif (eax>=18) && (eax<=20)            ;sin cos tan
				push eax
				mov esi,[ntop]
				invoke sscanf,addr Output,addr formatStr,addr nstack[esi*8]
				fld qword ptr nstack[esi*8]
				pop eax
				.if eax==18
					fsin
				.elseif eax==19
					fcos
				.elseif eax==20
					fcos
					fstp nstack[esi*8+8]
					fld nstack[esi*8]
					fsin
					fdiv nstack[esi*8+8]
				.endif
				fstp qword ptr nstack[esi*8]
				invoke sprintf,addr Output,addr formatStr2,nstack[esi*8]
				invoke SetDlgItemText, hWnd, 90, offset Output
			.elseif eax==17                              ;=
				mov ebx,[ntop]
				invoke sscanf,addr Output,addr formatStr,addr nstack[ebx*8]
				inc dword ptr [ntop]                                ;=之前的操作数入栈
				.if dword ptr [optop]>0
					fld qword ptr[nstack]
					.if byte ptr[opstack]=='+'
						fadd qword ptr[nstack+8]
					.elseif byte ptr[opstack]=='-'
						fsub qword ptr[nstack+8]
					.elseif byte ptr[opstack]=='*'
						fmul qword ptr[nstack+8]
					.else
						fdiv qword ptr[nstack+8]
					.endif
					fstp qword ptr[nstack]
					mov dword ptr [ntop],0
					mov dword ptr [optop],0
				.endif
				invoke sprintf,addr Output,addr formatStr2,qword ptr [nstack]
				invoke SetDlgItemText, hWnd, 90, offset Output
			.endif
		.ELSE
			invoke DefWindowProc, hWnd, uMsg, wParam, lParam
			JMP ENDPROC
		.ENDIF
ENDPROC:
		ret
_WinMain endp

main proc                          
        local structWndClass: WNDCLASSEX
		local structMsg: MSG 
		invoke GetModuleHandle, NULL ;获得相应程序的句柄
		mov H_app,eax ;存放应用程序的句柄
		invoke RtlZeroMemory, addr structWndClass, sizeof structWndClass
		invoke LoadCursor, 0, IDC_ARROW
		mov structWndClass.hCursor, eax
		push H_app
		pop structWndClass.hInstance

		mov structWndClass.cbSize, sizeof WNDCLASSEX
		mov structWndClass.style, CS_BYTEALIGNWINDOW or CS_BYTEALIGNWINDOW
		mov structWndClass.lpfnWndProc, offset _WinMain ;最关键的，设置窗口信息处理函数
		mov structWndClass.cbClsExtra, 0
		mov structWndClass.cbWndExtra,DLGWINDOWEXTRA
		mov structWndClass.hbrBackground, COLOR_WINDOW + 1
		mov structWndClass.lpszMenuName,NULL
		mov structWndClass.lpszClassName, offset winClassName
		invoke RegisterClassEx, addr structWndClass
		invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset winClassName, offset winCaptionName, WS_OVERLAPPEDWINDOW, 200, 250, 250, 350, NULL, NULL, H_app, NULL
		mov H_win, eax ;存放窗口程序的句柄
		invoke ShowWindow, H_win, SW_SHOWNORMAL
		invoke UpdateWindow, H_win
		
		.WHILE TRUE
			invoke GetMessage, addr	structMsg, NULL, 0, 0
			.break .if eax == 0
			invoke TranslateMessage, addr structMsg		
			invoke DispatchMessage,	addr structMsg		
		.ENDW
		
		invoke ExitProcess, NULL
        ret
main endp
end main