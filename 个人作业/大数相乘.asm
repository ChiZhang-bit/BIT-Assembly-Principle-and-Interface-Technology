.386
.model flat, stdcall
option casemap : none

includelib msvcrt.lib

printf PROTO C : ptr sbyte, :VARARG
scanf PROTO C : ptr sbyte, :VARARG

.data	
negflag DWORD 0

string1 BYTE 200 DUP(0)
nums1 DWORD 200 DUP(0)
len1 DWORD 0

string2 BYTE 200 DUP(0)
nums2 DWORD 200 DUP(0)
len2 DWORD 0

stringans BYTE 400 DUP(0)
numans DWORD 400 DUP(0)
lennum DWORD 0

input BYTE "Please input two nums", 0AH, 0
huanhang BYTE 0AH, 0
endoutput BYTE "Finish!", 0AH, 0
neg_flag BYTE    "-", 0
scanfmsg_s BYTE	"%s", 0
printmsg_d BYTE "%d", 0

.CODE
;求长度的函数
strlen proc stdcall USES edi string : ptr byte
	mov ax, SEG strlen
	mov edi, string
	mov eax, 0
strlen_1:
	CMP byte ptr [edi], 0
	JZ strlen_2; 是0
	ADD edi, 1
	ADD eax, 1
	jmp strlen_1
strlen_2:
	RET
strlen ENDP

ProcessString proc stdcall USES edx ecx eax string: ptr BYTE, numbers: ptr DWORD, len:DWORD
	XOR  ah,ah

	MOV edx, string
	MOV ebx, numbers
	MOV ecx, len; //判断长度，逐步递减
	SUB ecx, 1

	JMP PS_2

PS_1:
	MOV AL, [edx][ecx]
	CMP AL, 2DH
	JZ PS_3
	SUB AL, 30H

	MOV [EBX], EAX
	ADD EBX, 4
	SUB ECX, 1

PS_2:
	CMP ecx, 0
	JNS PS_1
	RET

PS_3:
	ADD negflag, 1
	RET

ProcessString ENDP

Mult_num proc stdcall uses ecx edx ebx edi esi numbers1: ptr dword, length1: dword, numbers2: ptr dword, length2: dword, res: ptr dword
	MOV EDX, numbers1
	MOV EBX, numbers2
	MOV EAX, res
	MOV esi, 0
	JMP MUL_4

MUL_1:
	MOV EDI, 0
	JMP MUL_3

MUL_2:
	MOV ECX, [EDX + ESI * 4]
	IMUL ecx, [ebx + edi* 4]

	add edi,esi
	add [eax + edi * 4], ecx
    sub edi, esi
    inc edi

MUL_3:
	CMP EDI, length2
	JL MUL_2
	INC esi

MUL_4:
	CMP esi, length1
	JL MUL_1

	RET
Mult_num ENDP

numlen proc stdcall uses ebx edi ans: ptr dword
	mov ebx, ans
	mov edi, 200 - 1
NL_1:
	CMP DWORD PTR [EBX + EDI * 4], 0
	JNZ NL_2
	SUB EDI, 1
	JMP NL_1
NL_2:
	MOV EAX, EDI
	INC EAX
	RET
numlen endp

carry proc stdcall USES ebx edi edx res:ptr dword
    local Len

    invoke numlen, res
    mov Len, eax

    mov ebx, res
    mov edi, 0
C1:
    cmp edi, Len
    jnl  C2
    
    mov eax, [ebx + edi * 4]
    xor edx, edx
    mov ecx, 10
    div ecx
    ; eax中存放除法结果 ， edx中存放除法余数
    mov [ebx + edi * 4], edx
    add [ebx + edi * 4 + 4], eax

    inc edi
    jmp C1
C2:
    invoke numlen, res
    ret
carry endp

print PROC stdcall uses ebx edi edx ans:ptr dword, len: dword
	mov ebx, ans
	mov edi, len
	sub edi, 1
P1:
	cmp EDI, 0
	JNGE P2;EDI < 0
	invoke printf, offset printmsg_d, dword ptr [ebx + edi*4]
	SUB edi, 1
	jmp P1
P2:
	mov len1, eax
	INVOKE printf, offset huanhang
	RET
print endp

main PROC
	INVOKE printf, offset input
	INVOKE scanf, offset scanfmsg_s, offset string1
	INVOKE scanf, offset scanfmsg_s, offset string2

	INVOKE strlen, offset string1
	mov len1, eax

	INVOKE strlen, offset string2
	mov len2, eax

	INVOKE ProcessString, offset string1, offset nums1, len1
	INVOKE ProcessString, offset string2, offset nums2, len2

	INVOKE Mult_num, OFFSET nums1, len1, offset nums2, len2, offset numans
	INVOKE carry, offset numans
	MOV lennum, eax
	
	MOV edi, negflag
	CMP edi, 1
	JNZ M1

	invoke printf, offset neg_flag

M1:
	INVOKE print, offset numans, lennum

	INVOKE printf, offset endoutput
	RET
main endp

end main