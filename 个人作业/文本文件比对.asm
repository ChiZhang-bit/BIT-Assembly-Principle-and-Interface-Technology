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
sprintf PROTO C :ptr sbyte, :VARARG
strcmp PROTO C :ptr sbyte, :VARARG
strcat PROTO C :ptr sbyte, :VARARG

.data                           
H_app dd ? ;存放应用程序的句柄
H_win dd ? ;存放窗口的句柄
H_edit1 HWND ? ;文件1
H_edit2 HWND ? ;文件2
file1_path byte 256 dup(?)
fp1 HANDLE ?
fp2 HANDLE ?
file2_path byte 256 dup(?)
differs byte 2048 dup(0)
differ_num dd ?
buffer1 byte 2048 dup(0)
buffer2 byte 2048 dup(0)
errorflag byte 1

tips db "在下方输入或选择两个文件的绝对路径或相对路径：",0
winClassName db "文本文件比对",0
winCaptionName db "文本文件比对",0
choosefile db "选择文件", 0
edit byte "edit", 0
static byte "static", 0
button byte "button", 0
start byte "开始进行比较", 0
file1error db "文件1路径出错",0
file2error db "文件2路径出错",0
errortitle byte "错误报告",0
SameContent	 db "文件内容相同", 0
DiffContent db "第%d行不同", 0AH,0
Anstitle byte "文本对比结果", 0
Selecttips byte "选择一个文本文件", 0

.code
ReadLine proc stdcall uses ebx, fileHand: HANDLE, lpLineBuf: ptr byte
    ; 读完文件 eax 返回值为 0
    LOCAL br:DWORD
    LOCAL char:BYTE
    mov ebx, lpLineBuf

L2:
    invoke ReadFile, fileHand ,addr char, 1, ADDR br, NULL
	
	.if br == 0
		jmp L1
	.endif
    mov al, char  
    mov [ebx], al
    inc ebx
    
    .if char == 0AH
		jmp L1 ;判断是否为换行\n 为换行就return
	.elseif
		jmp	L2
	.endif
L1:
    xor al,al
    mov [ebx], al
    invoke strlen, lpLineBuf
    ret     
ReadLine endp

CompareFile proc fpath1:ptr byte, fpath2:ptr byte
	local lp1 :dword
	local lp2 :dword
	local index_line :dword
	local buffer_differ[1024] :byte
	MOV errorflag, 1
	invoke CreateFile, fpath1, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
	mov fp1, eax
	;判断路径是否出错
	.if fp1 == 0
		invoke MessageBox, NULL, offset file1error, offset errortitle, MB_OK + MB_ICONQUESTION
		MOV errorflag, 0
		JMP ENDFUNC
	.endif
	invoke CreateFile, fpath2, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
	mov fp2, eax
	.if fp2 == 0
		invoke MessageBox, NULL, offset file2error, offset errortitle, MB_OK + MB_ICONQUESTION
		MOV errorflag, 0
		JMP ENDFUNC
	.endif
	mov differ_num, 0
	mov index_line, 0
	mov esi, offset differs
	mov byte ptr[esi], 0

CMP0:
	inc index_line
	invoke ReadLine, fp1, offset buffer1
	mov lp1, eax
	invoke ReadLine, fp2, offset buffer2
	mov lp2, eax

CMP1:
	cmp lp1, 0
	jne CMP3
	cmp lp2, 0
	jne CMP2
	jmp ENDFUNC;都等于0 就return

CMP2:
	invoke sprintf, addr buffer_differ, offset DiffContent, index_line
	invoke strcat, offset differs, addr buffer_differ
	inc differ_num
	jmp CMP0

CMP3:
	cmp lp2,0
	jne CMP4

	invoke sprintf, addr buffer_differ, offset DiffContent, index_line
	invoke strcat, offset differs, addr buffer_differ
	inc differ_num
	jmp CMP0

CMP4:
	;都不等于0时，使用strcmp函数对文件进行对比
	invoke strcmp, offset buffer1, offset buffer2
	cmp eax, 0
	je CMP0
	invoke sprintf, addr buffer_differ, offset DiffContent, index_line
	invoke strcat, offset differs, addr buffer_differ
	inc differ_num
	jmp CMP0

ENDFUNC:
	ret 
CompareFile endp

BrowseForFile  proc uses ebx lpFilePath: ptr byte
    LOCAL pidl:DWORD
    LOCAL bri:BROWSEINFO

    mov ebx, lpFilePath
    
    mov	bri.hwndOwner, 0
    mov bri.pidlRoot, 0
    mov bri.pszDisplayName, ebx
    mov eax, offset Selecttips
    mov bri.lpszTitle, eax
    mov bri.ulFlags, BIF_BROWSEINCLUDEFILES ; 显示文件
    mov bri.lpfn, 0
    mov bri.lParam, 0
    mov bri.iImage, 0
    INVOKE SHBrowseForFolder, addr bri
    .if !eax
        jmp	ENDFUNC
    .endif
    
    mov pidl, eax
    INVOKE SHGetPathFromIDList, pidl, ebx  ; 得到完整文件名
    INVOKE CoTaskMemFree, pidl
ENDFUNC:
    ret
BrowseForFile endp

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
			invoke CreateWindowEx, NULL, offset static, offset tips, WS_CHILD or WS_VISIBLE, 5, 25, 350, 20, hWnd, 1, H_app, NULL 
			invoke CreateWindowEx, NULL, OFFSET button, OFFSET start, WS_CHILD OR  WS_VISIBLE,	120, 200, 150, 25, hWnd, 2, H_app, NULL
			invoke CreateWindowEx, NULL, offset button, offset choosefile, WS_CHILD OR  WS_VISIBLE, 3, 70, 70, 35, hWnd, 3, H_app, NULL
			invoke CreateWindowEx, NULL, OFFSET edit, NULL, WS_CHILD OR  WS_VISIBLE OR WS_BORDER OR	ES_LEFT	OR ES_AUTOHSCROLL, 75, 70, 300, 35, hWnd, 4, H_app, NULL
			mov H_edit1, eax
			invoke CreateWindowEx, NULL, offset button, offset choosefile, WS_CHILD OR  WS_VISIBLE, 3, 140, 70, 35, hWnd, 5, H_app, NULL
			invoke CreateWindowEx, NULL, OFFSET edit, NULL, WS_CHILD OR  WS_VISIBLE	OR WS_BORDER OR	ES_LEFT	OR ES_AUTOHSCROLL, 75, 140, 300, 35, hWnd, 6, H_app, NULL 
			mov H_edit2, eax		
		.ELSEIF	eax == WM_COMMAND
			mov eax,wParam
			.IF eax == 2
				invoke GetWindowText,H_edit1,offset file1_path,512
				invoke GetWindowText,H_edit2,offset file2_path,512
				invoke CompareFile, offset file1_path, offset file2_path
				.IF	differ_num == 0
					.IF errorflag == 1
						invoke MessageBox, hWnd, offset SameContent, offset Anstitle, MB_OK + MB_ICONQUESTION
					.ENDIF
				.ELSE
					invoke MessageBox, hWnd, offset differs, offset Anstitle, MB_OK + MB_ICONQUESTION
				.ENDIF
			.ELSEIF eax == 3
				invoke  BrowseForFile, offset file1_path
				invoke SetDlgItemText, hWnd, 4, offset file1_path
			.ELSEIF eax == 5
				invoke  BrowseForFile, offset file2_path
				invoke SetDlgItemText, hWnd, 6, offset file2_path
			.ENDIF
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
		invoke GetModuleHandle, NULL
		mov H_app,eax
		invoke RtlZeroMemory, addr structWndClass, sizeof structWndClass
		invoke LoadCursor, 0, IDC_ARROW
		mov structWndClass.hCursor, eax
		push H_app
		pop structWndClass.hInstance

		mov structWndClass.cbSize, sizeof WNDCLASSEX
		mov structWndClass.style, CS_HREDRAW or CS_VREDRAW
		mov structWndClass.lpfnWndProc, offset _WinMain
		mov structWndClass.hbrBackground, COLOR_WINDOW + 1
		mov structWndClass.lpszClassName, offset winClassName
		invoke RegisterClassEx, addr structWndClass
		invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset winClassName, offset winCaptionName, WS_OVERLAPPEDWINDOW, 200, 250, 400, 300, NULL, NULL, H_app, NULL
		mov H_win, eax
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