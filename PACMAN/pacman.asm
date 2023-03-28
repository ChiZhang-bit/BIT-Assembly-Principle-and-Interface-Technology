.386
.model flat,stdcall
option casemap:none

include define.inc

.code											
writeStrWithSP proc									
	Call WriteString
	Call Crlf
	ret
writeStrWithSP endp

valuesToDrawBoard PROC
	mov dx, 0
	Call Gotoxy
	mov eax, 9			
	Call SetTextColor
	mov edx, offset row-164							
ret
valuesToDrawBoard ENDP

drawStringBoard proc							
	Call valuesToDrawBoard
	mov ecx, 93									
	printMap:
		add edx, 164								
		Call writeStrWithSP							
	loop printMap
	doneWithMap:
	ret
drawStringBoard endp

bl2esi proc										
cmpx:
	cmp bl,0
	je endseek
	inc esi									
	inc edi
	dec bl									
	jmp cmpx
endseek:	
	ret
bl2esi endp

lookForSpace PROC
	Call bl2esi									
	cmp BYTE PTR [esi], ' ' 
	;cmp BYTE PTR [EDI], ' '
	ret 
lookForSpace ENDP

xCordOfPacCleanup PROC
	movzx ebx, pacx								
	;add bl, bl									
	ret
xCordOfPacCleanup ENDP

addTen PROC
	add totalScore, 10							
	mov BYTE PTR [esi], ' '						
	mov BYTE PTR [edi], ' '
	ret
addTen ENDP

removePellet proc								
gameChanger:								
	Call xCordOfPacCleanup
	
	mov esi, offset row-164
	mov edi, offset boardArray-164
	mov edx, 164
	movzx eax, pacy
	imul edx, eax
	add esi,edx 
	add edi,edx
	Call lookForSpace
	je kdone
	Call addTen

kdone:
	ret
removePellet endp

PacPellet proc
	mov eax, 10
	Call SetTextColor
	mov dh, 1
	mov dl, 60
	Call Gotoxy
	mov eax, 4
	Call SetTextColor
	mov dh, 42								
	mov dl, 76
	mov eax, totalScore
	Call Gotoxy
	mov edx, offset outputScore					;打印分数
	Call WriteString
	mov dh, 42
	mov dl, 85
	Call Gotoxy
	Call WriteDec
	ret
PacPellet endp

Lives proc
	Call yellowText
	mov dh, 43
	mov dl, 80
	Call Gotoxy
	mov eax, 0
	mov al, totalLives
	Call WriteDec
	mov edx, offset outputLives
	Call WriteString
	ret
Lives endp

Tests proc
	Call yellowText
	mov dh, 46
	mov dl, 80
	Call Gotoxy
	mov eax, 0
	mov al, distance
	Call WriteDec
	ret
Tests endp

;移动鬼的位置
moveGhosts proc
	.if pausetime > 0
		jmp movedone
	.endif
	cmp ghos1dir, 1								
	jne ghos1dir2
	dec ghos1y									
	jmp ghos2
ghos1dir2:
	cmp ghos1dir, 2								
	jne ghos1dir3
	inc ghos1x									
	inc ghos1x									
	jmp ghos2
ghos1dir3:
	cmp ghos1dir, 3								
	jne ghos1dir4
	inc ghos1y									
	jmp ghos2
ghos1dir4:									
	dec ghos1x									
	dec ghos1x									
ghos2:
	cmp ghos2dir, 1								
	jne ghos2dir2
	dec ghos2y									
	jmp ghos3
ghos2dir2:
	cmp ghos2dir, 2							
	jne ghos2dir3
	inc ghos2x								
	inc ghos2x								
	jmp ghos3
ghos2dir3:
	cmp ghos2dir, 3							
	jne ghos2dir4
	inc ghos2y								
	jmp ghos3
ghos2dir4:									
	dec ghos2x								
	dec ghos2x								
ghos3:
	cmp ghos3dir, 1							
	jne ghos3dir2
	dec ghos3y								
	jmp ghos4
ghos3dir2:
	cmp ghos3dir, 2							
	jne ghos3dir3
	inc ghos3x								
	inc ghos3x								
	jmp ghos4
ghos3dir3:
	cmp ghos3dir, 3							
	jne ghos3dir4
	inc ghos3y								
	jmp ghos4
ghos3dir4:									
	dec ghos3x								
	dec ghos3x								
ghos4:
	cmp ghos4dir, 1								
	jne ghos4dir2
	dec ghos4y									
	jmp endingThis
ghos4dir2:
	cmp ghos4dir, 2								
	jne ghos4dir3
	inc ghos4x									
	inc ghos4x									
	jmp endingThis
ghos4dir3:
	cmp ghos4dir, 3								
	jne ghos4dir4
	inc ghos4y									
	jmp endingThis
ghos4dir4:									
	dec ghos4x									
	dec ghos4x									
endingThis:		
	call teleporter						
movedone:	
	ret
moveGhosts endp

;特殊位置的传送
teleporter proc
teleport1west:			
	cmp ghos1x, 0								
	jne teleport1east							
	mov ghos1x, 160								
	mov ghos1dir, 4								
teleport1east:
	cmp ghos1x, 162
	jne teleport2west
	mov ghos1x, 2								
	mov ghos1dir, 2								
teleport2west:
	cmp ghos2x, 0
	jne teleport2east
	mov ghos2x, 160								
	mov ghos2dir, 4								
teleport2east:
	cmp ghos2x, 162
	jne teleport3west
	mov ghos2x, 2								
	mov ghos2dir, 2								
teleport3west:
	cmp ghos3x, 0
	jne teleport3east
	mov ghos3x, 160								
	mov ghos3dir, 4								
teleport3east:
	cmp ghos3x, 162
	jne teleport4west
	mov ghos3x, 2								
	mov ghos3dir, 2								
teleport4west:
	cmp ghos4x, 0
	jne teleport4east
	mov ghos4x, 160								
	mov ghos4dir, 4								
teleport4east:
	cmp ghos4x, 162
	jne allDone
	mov ghos4x, 2								
	mov ghos4dir, 2								
allDone:
	ret
teleporter endp

; ah：ghost's location; 检测与鬼的位置是否重合
ghostsVsPacman proc uses eax
	mov ah, ghos1x								
	cmp pacx, ah
	je pacmanY1									
pacmanX2:	
	mov ah, ghos2x								
	cmp pacx, ah
	je pacmanY2									
pacmanX3:	
	mov ah, ghos3x								
	cmp pacx, ah
	je pacmanY3									
pacmanX4:	
	mov ah, ghos4x								
	cmp pacx, ah
	je pacmanY4
	jmp noDice
pacmanY1:	
	mov ah, ghos1y							
	cmp pacy, ah
	je DeadMan								
	jmp pacmanX2								
pacmanY2:	
	mov ah, ghos2y
	cmp pacy, ah							
	je DeadMan								
	jmp pacmanX3								
pacmanY3:	
	mov ah, ghos3y
	cmp pacy, ah						
	je DeadMan								
	jmp pacmanX4							
pacmanY4:	
	mov ah, ghos4y
	cmp pacy, ah							
	je DeadMan								
	jmp noDice								
DeadMan:	
	Call caughtInTheAct
noDice:		
	ret
ghostsVsPacman endp

;死亡则减少一次生命，重置地图
caughtInTheAct proc
	dec totalLives					
	Call resetUnits								
	Call Lives									
	ret
caughtInTheAct endp

;重置人和鬼的位置
resetUnits proc
	mov dh, 78									
	mov dl, 71							
	Call Gotoxy 
	mov pacx, dh								
	mov pacy, dl
	mov pacdir, 2							
	mov dh, 72									
	mov dl, 36
	Call Gotoxy
	mov ghos1x, dh								
	mov ghos1y, dl								
	mov ghos1dir, 1								
	mov dh, 78								
	mov dl, 36
	Call Gotoxy
	mov ghos2x, dh								
	mov ghos2y, dl								
	mov ghos2dir, 1								
	mov dh, 84									
	mov dl, 36
	Call Gotoxy
	mov ghos3x, dh								
	mov ghos3y, dl								
	mov ghos3dir, 1								
	mov dh, 90									
	mov dl, 36
	Call Gotoxy
	mov ghos4x, dh							
	mov ghos4y, dl							
	mov ghos4dir, 1							
	Call directGhosts
	ret
resetUnits endp

;判断可以往哪个方向移动
discardWallDirs proc uses ecx edx				
north:
	cmp dl, 3									
	je ni									
	mov bh, ch
	mov bl, cl
	dec bl									
	Call charAtXY							
	cmp al, '#'							
	jne nl									
ni:									
	mov northlegal, 0							
	jmp east										
nl:										
	mov northlegal, 1					
east:
	cmp dl, 4									
	je ei									
	mov bh, ch
	mov bl, cl
	inc bh									
	inc bh
	Call charAtXY							
	cmp al, '#'								
	jne el									
ei:										
	mov eastlegal, 0						
	jmp south										
el:										
	mov eastlegal, 1					
south:
	cmp dl, 1									
	je sil										
	mov bh, ch
	mov bl, cl
	inc bl									
	Call charAtXY							
	cmp al, '#'							
	jne sl									
sil:									
	mov southlegal, 0						
	jmp west									
sl:										
	mov southlegal, 1						
west:
	cmp dl, 2								
	je wi									
	mov bh, ch
	mov bl, cl
	dec bh									
	dec bh
	Call charAtXY						
	cmp al, '#'					
	jne wl									
wi:							
	mov westlegal, 0					
	jmp endchecks										
wl:									
	mov westlegal, 1				
	endchecks:
	ret
discardWallDirs endp

;cx:ghost's location; dx: pacman's location; 分别计算向各个方向走的距离
calculateDistance proc 																	
edist:
	cmp eastlegal, 1
	jne sdist								
	mov bl, ch								
	inc bl										
	inc bl
	mov al, dh									
	Call absoluteDistance						
	mov bh, 2
	div bh
	mov eastdist, al						
	mov bl, cl									
	mov al, dl								
	Call absoluteDistance					
	add eastdist, al						
sdist:
	cmp southlegal, 1
	jne wdist								
	mov bl, ch								
	mov al, dh								
	Call absoluteDistance					
	mov bh, 2
	div bh
	mov southdist, al							
	mov bl, cl								
	inc bl									
	mov al, dl								
	Call absoluteDistance					
	add southdist, al					
wdist:
	cmp westlegal, 1
	jne ndist								
	mov bl, ch								
	dec bl							
	dec bl
	mov al, dh						
	Call absoluteDistance			
	mov bh, 2
	div bh
	mov westdist, al				
	mov bl, cl						
	mov al, dl						
	Call absoluteDistance			
	add westdist, al				
ndist:
	cmp northlegal, 1
	jne endcalcin					
	mov northdist, 0
	mov al, ch							
	mov bl, dh						
	Call absoluteDistance			
	mov bh, 2
	div bh
	mov northdist, al				
	mov bl, cl								
	dec bl								
	mov al, dl						
	Call absoluteDistance			
	add northdist, al			
	endcalcin:
	ret
calculateDistance endp

;
chooseGhostDir proc					
checknorth:
	cmp northlegal, 1
	jne checkwest				
	;mov eax, 1					
	mov bl, northdist			
	cmp bl, westdist			
	jna cmpn2s
	.if westlegal == 1
		mov northlegal, 0
	.endif
cmpn2s:
	cmp bl, southdist						
	jna cmpn2e
	.if southlegal == 1
		mov northlegal, 0
	.endif
cmpn2e:
	cmp bl, eastdist						
	jna checkwest
	.if eastlegal == 1
		mov northlegal, 0
	.endif

checkwest:
	cmp westlegal, 1
	jne checksouth								
	;mov eax, 4								
	mov bl, westdist						
	cmp bl, northdist					
	jna cmpw2s
	.if northlegal == 1
		mov westlegal, 0
	.endif
cmpw2s:
	cmp bl, southdist					
	jna cmpw2e
	.if southlegal == 1
		mov westlegal, 0
	.endif
cmpw2e:
	cmp bl, eastdist					
	jna checksouth
	.if eastlegal == 1
		mov westlegal, 0
	.endif

checksouth:
	cmp southlegal, 1
	jne checkeast							
	;mov eax, 3									
	mov bl, southdist							
	cmp bl, northdist							
	jna cmps2w
	.if northlegal == 1
		mov southlegal, 0
	.endif
cmps2w:
	cmp bl, westdist
	jna cmps2e
	.if westlegal == 1
		mov southlegal, 0
	.endif
cmps2e:
	cmp bl, eastdist
	jna checkeast
	.if eastlegal == 1
		mov southlegal, 0
	.endif

checkeast:;
	cmp eastlegal, 1
	jne choose							
	;mov eax, 3									
	mov bl, eastdist							
	cmp bl, northdist							
	jna cmpe2w
	.if northlegal == 1
		mov eastlegal, 0
	.endif
cmpe2w:
	cmp bl, westdist
	jna cmpe2s
	.if westlegal == 1
		mov eastlegal, 0
	.endif
cmpe2s:
	cmp bl, southdist
	jna choose
	.if southlegal == 1
		mov eastlegal, 0
	.endif

choose:
	mov dircount, 0
	mov esi, offset dirchoose
	.if northlegal == 1
		mov byte ptr[esi], 1
		inc esi
		inc dircount
	.endif
	.if eastlegal == 1
		mov byte ptr[esi], 2
		inc esi
		inc dircount
	.endif
	.if southlegal == 1
		mov byte ptr[esi], 3
		inc esi
		inc dircount
	.endif
	.if westlegal == 1
		mov byte ptr[esi], 4
		inc esi
		inc dircount
	.endif
	mov ax, framecount
	div dircount
	movzx edi, ah
	mov esi, offset dirchoose
	add esi, edi
	movzx eax, byte ptr[esi]
	ret
chooseGhostDir endp

chooseGhostDirReverse proc
checknorth:
	cmp northlegal, 1
	jne checkwest							
	mov eax, 1								
	mov bl, northdist						
	cmp bl, westdist					
	jl cmpn2s
	mov westlegal, 0
cmpn2s:
	cmp bl, southdist						
	jl cmpn2e
	mov southlegal, 0
cmpn2e:
	cmp bl, eastdist						
	jl checkwest
	mov eastlegal, 0
checkwest:
	cmp westlegal, 1
	jne checksouth							
	mov eax, 4							
	mov bl, westdist					
	cmp bl, southdist					
	jl cmpw2e
	mov southlegal, 0
cmpw2e:
	cmp bl, eastdist						
	jl checksouth
	mov eastlegal, 0
checksouth:
	cmp southlegal, 1
	jne checkeast							
	mov eax, 3							
	mov bl, southdist						
	cmp bl, eastdist					
	jl checkeast
	mov eastlegal, 0
checkeast:
	cmp eastlegal, 1
	jne returndir
	mov eax, 2								
	returndir:		
	ret
chooseGhostDirReverse endp

acquireG2Target proc							
	cmp pacdir, 1							
	jne eastcheck
	mov al, pacx								
	mov ghos2targx, al						
	mov al, pacy
	.if al < 13
		mov al, 1
	.else 
		sub al, 12
	.endif
	mov ghos2targy, al						
	jmp targetacquired
eastcheck:		
	cmp pacdir, 2						
	jne southcheck
	mov al, pacx
	.if al > 136
		mov al, 160
	.else 
		add al, 24
	.endif						
	mov ghos2targx, al					
	mov al, pacy
	mov ghos2targy, al						
	jmp targetacquired
southcheck:	
	cmp pacdir, 3							
	jne westcheck
	mov al, pacx						
	mov ghos2targx, al						
	mov al, pacy
	.if al > 80
		mov al, 93
	.else 
		add al, 12
	.endif
	mov ghos2targy, al						
	jmp targetacquired									
westcheck:		
	mov al, pacx				
	.if al < 26
		mov al, 2
	.else 
		sub al, 24
	.endif
	mov ghos2targx, al			
	mov al, pacy
	mov ghos2targy, al			
	targetacquired:
	ret
acquireG2Target endp
	
acquireG3Target proc uses edx			
	cmp pacdir, 1						
	jne eastcheck
	mov al, pacx								
	mov ghos3targx, al						
	mov al, pacy
	sub al, 6
	mov ghos3targy, al						
	jmp targetacquired
eastcheck:		
	cmp pacdir, 2							
	jne southcheck
	mov al, pacx	
	add al, 12							
	mov ghos3targx, al						
	mov al, pacy
	mov ghos3targy, al						
	jmp targetacquired
southcheck:		
	cmp pacdir, 3						
	jne westcheck
	mov al, pacx						
	mov ghos3targx, al						
	mov al, pacy
	add al, 6
	mov ghos3targy, al						
	jmp targetacquired
westcheck:	
	mov al, pacx						
	sub al, 12
	mov ghos3targx, al					
	mov al, pacy
	mov ghos3targy, al					
targetacquired:		
	mov dh, ghos3targx					
	mov dl, ghos3targy
	mov bl, ghos1x
	mov al, ghos3targx
	Call absoluteDistance				
	add eax, eax
	cmp dh, ghos1x					
	jge l2r
r2l:	
	
	sub ghos3targx, al								
	jmp ycheck
l2r:	
	add ghos3targx, al						
ycheck:
	mov bl, ghos1y
	mov al, ghos3targy
	Call absoluteDistance						
	cmp dl, ghos1y							
	jl d2u
u2d:	
	add ghos3targy, al							
	jmp noseriouslytargetacquired
d2u:	
	sub ghos3targy, al					  
noseriouslytargetacquired:
	ret
acquireG3Target endp

acquireG4Target proc							
	mov bl, ghos4x								
	mov al, pacx								
	Call absoluteDistance						
	mov dl, al									
	mov bl, ghos4y								
	mov al, pacy								
	Call absoluteDistance						
	mov dh, al
	add dl, dh 
	
	
	cmp dl, 24									
	jnbe seeker
	sub dl, dh

	
	;dl:abs(x,x), dh:abs(y,y)
	mov bl, ghos4y
	cmp bl, pacy
	jnbe setghos4y1
	sub bl, dh
	mov ghos4targy, bl
	
	mov bl, ghos4x
	cmp bl, pacx
	
	jnbe setghost4x1
	sub bl, dl
	mov ghos4targx, bl
setghos4y1:
	add bl, dh
	mov ghos4targy, bl
setghost4x1:
	add bl, dl
	mov ghos4targx, bl

	jmp targetacquired
seeker:											
	mov al, pacx
	mov ghos4targx, al
	mov al, pacy
	mov ghos4targy, al
targetacquired:
	ret
acquireG4Target endp

chooseGhost1Dir proc

	;sti
	invoke GetTickCount
getrandom1:
	and eax, 03h
	inc al
	cmp al, 1
	jnz cmpeast1
	cmp northlegal, 1
	jnz getrandom1
	mov al, 1
	jmp end1
cmpeast1:
	cmp al, 2
	jnz cmpsouth1
	cmp eastlegal, 1
	jnz getrandom1
	mov al,2
	jmp end1
cmpsouth1:
	cmp al, 3
	jnz cmpwest1
	cmp southlegal, 1
	jnz getrandom1
	mov al, 3
	jmp end1
cmpwest1:
	cmp al, 4
	jnz end1
	cmp westlegal, 1
	jnz getrandom1
	mov al, 4
	jmp end1
end1:
	ret
chooseGhost1Dir endp

calculateDistanceG4FromPacman proc
	mov bl, ghos4x								
	mov al, pacx								
	Call absoluteDistance						
	mov dl, al									
	mov bl, ghos4y								
	mov al, pacy								
	Call absoluteDistance						
	mov dh, al
	add dl, dh 
	ret
calculateDistanceG4FromPacman endp


; cx:ghost's location; dl:ghost's dir
directGhosts proc														
	mov ch, ghos1x								
	mov cl, ghos1y
	mov dl, ghos1dir
	Call discardWallDirs						
	mov ch, ghos1x
	mov cl, ghos1y
	mov dh, pacx
	mov dl, pacy
	Call calculateDistance						
	Call chooseGhostDir							
	;Call chooseGhost1Dir
	mov ghos1dir, al
	
	mov ch, ghos2x								
	mov cl, ghos2y
	mov dl, ghos2dir
	Call discardWallDirs						
	Call acquireG2Target
	mov ch, ghos2x
	mov cl, ghos2y
	mov dh, ghos2targx
	mov dl, ghos2targy
	Call calculateDistance						
	Call chooseGhostDir							
	mov ghos2dir, al
	
	mov ch, ghos3x								
	mov cl, ghos3y
	mov dl, ghos3dir
	Call discardWallDirs						
	Call acquireG3Target
	mov ch, ghos3x
	mov cl, ghos3y
	mov dh, ghos3targx
	mov dl, ghos3targy
	Call calculateDistance						
	Call chooseGhostDir						
	mov ghos3dir, al
	
	mov ch, ghos4x								
	mov cl, ghos4y
	mov dl, ghos4dir
	Call discardWallDirs						
	;Call acquireG4Target
	mov ch, ghos4x
	mov cl, ghos4y
	;mov dh, ghos4targx
	;mov dl, ghos4targy
	mov dh, pacx
	mov dl, pacy
	Call calculateDistance
	Call calculateDistanceG4FromPacman 
	.if dl < 24
		Call chooseGhostDirReverse
	.else
		Call chooseGhostDir							
	.endif
	;Call chooseGhost4Dir
	mov ghos4dir, al
	ret
directGhosts endp

directGhostsReverse proc
	mov ch, ghos1x								
	mov cl, ghos1y
	mov dl, ghos1dir
	Call discardWallDirs
	mov ch, ghos1x
	mov cl, ghos1y
	mov dh, pacx
	mov dl, pacy
	Call calculateDistance
	Call chooseGhostDirReverse							
	mov ghos1dir, al

	mov ch, ghos2x								
	mov cl, ghos2y
	mov dl, ghos2dir
	Call discardWallDirs
	mov ch, ghos2x
	mov cl, ghos2y
	mov dh, pacx
	mov dl, pacy
	Call calculateDistance
	Call chooseGhostDirReverse							
	mov ghos2dir, al

	mov ch, ghos3x								
	mov cl, ghos3y
	mov dl, ghos3dir
	Call discardWallDirs
	mov ch, ghos3x
	mov cl, ghos3y
	mov dh, pacx
	mov dl, pacy
	Call calculateDistance
	Call chooseGhostDirReverse							
	mov ghos3dir, al

	mov ch, ghos4x								
	mov cl, ghos4y
	mov dl, ghos4dir
	Call discardWallDirs
	mov ch, ghos4x
	mov cl, ghos4y
	mov dh, pacx
	mov dl, pacy
	Call calculateDistance
	Call chooseGhostDirReverse							
	mov ghos4dir, al

	ret
directGhostsReverse endp


tempPathfind proc								
	cmp northlegal, 1
	jne g1wgo
	mov ghos1dir, 1
	jmp g1done
	g1wgo:
	cmp westlegal, 1
	jne g1sgo
	mov ghos1dir, 4
	jmp g1done
	g1sgo:
	cmp southlegal, 1
	jne g1ego
	mov ghos1dir, 3
	jmp g1done
	g1ego:
	mov ghos1dir, 2
	g1done:
	ret
tempPathfind endp

;bx：当前位置 X Y, al 返回该位置的符号
charAtXY proc uses ebx ecx 				
	cmp bl, 3								
	jg botcomp
	mov al, '#'								
	jmp alldone
botcomp:
	cmp bl, 91							
	jl okfine
	mov al, '#'									
	jmp alldone
okfine:	
	movzx ecx, bh							
	;add ecx, ecx
addy:	
	dec bl									
	cmp bl, 0
	je returnchar								
	add ecx, 164							
	jmp addy
returnchar:
	mov al, BYTE PTR boardArray[ecx]		
alldone:
	ret
charAtXY endp

;画出鬼和人
drawUnits proc

	Call yellowText
	mov bl, pacx							
	mov dh, pacy					
	call writePacman
	
	mov eax, 12								
	Call SetTextColor
	mov bl, ghos1x								
	;add bl, bl							
	mov dh, ghos1y						
	Call writeGhost
	
	mov eax, 13							
	Call SetTextColor
	mov bl, ghos2x					
	;add bl, bl						
	mov dh, ghos2y					
	Call writeGhost
	
	mov eax, 11								
	Call SetTextColor
	mov bl, ghos3x						
	;add bl, bl							
	mov dh, ghos3y					
	Call writeGhost
	
	mov eax, 14							
	Call SetTextColor
	mov bl, ghos4x						
	;add bl, bl							
	mov dh, ghos4y						
	Call writeGhost
	ret
drawUnits endp

writePacman PROC
	dec dh
	mov dl, bl
	dec dh
	sub dl,2
	mov bx,dx
	call Gotoxy
	mov ax, framecount
	mov dl, 2
	div dl
	
	.if ah == 1
	    mov edx, pacChar
		call WriteString
		
		inc bh
		mov dx, bx
		call Gotoxy
		mov edx, pacChar
		add edx,6
		call WriteString
		
		inc bh
		mov dx, bx
		call Gotoxy
		mov edx, pacChar
		add edx,12
		call WriteString


	.else 
		mov edx, offset pacmanShutShape
		call WriteString
		
		inc bh
		mov dx, bx
		call Gotoxy
		mov edx, offset pacmanShutShape+6
		call WriteString
		
		inc bh
		mov dx, bx
		call Gotoxy
		mov edx, offset pacmanShutShape+12
		call WriteString
	.endif
	
	ret
writePacman ENDP

writeGhost PROC
	dec dh									
	mov dl, bl								
	dec dh
	sub dl,2
	mov ax, dx
	
	Call Gotoxy
	mov edx, offset ghosta
	call WriteString

	inc ah
	mov dx, ax
	Call Gotoxy
	mov edx, offset ghostb
	call WriteString

	inc ah
	mov dx, ax
	Call Gotoxy
	mov edx, offset ghostc
	call WriteString

ret
writeGhost ENDP

;eax存储距离绝对值
absoluteDistance proc							
	cmp al, bl								
	jb yolo									
	sub al, bl								
	movzx eax, al
	jmp returndist
	yolo:									
	sub bl, al								
	movzx eax, bl							
	returndist:
	ret
absoluteDistance endp

gameOver proc
	Call Clrscr								
	mov dh, 12
	mov dl, 34
	Call Gotoxy
	mov edx, offset thatsAllSheWrote
	Call WriteString
	mov dh, 14
	mov dl, 28
	Call Gotoxy
	mov edx, offset result
	Call WriteString
	mov eax, totalScore
	Call WriteDec
	Call Crlf
	mov eax, 1000						
	call Delay
	ret
gameOver endp

text PROC							
		Call SetTextColor
		mov al, bl
		Call WriteChar
ret
text ENDP

yellowText PROC							;SetTextToYellow
	mov eax, 14					
	Call SetTextColor					
	ret
yellowText ENDP

redText PROC							;Dark red text.
	mov eax, 4					
	Call text
	Call yellowText
	ret
redText ENDP

greenText PROC							;Bright green text.
	mov eax, 10						
	Call text
	Call yellowText
	ret
greenText ENDP
blueText PROC							;Purplish text.
	mov eax, 13						
	Call text
	Call yellowText
	ret
blueText ENDP
lightBlueText PROC						;light Blueish text.
	mov eax, 9						
	Call text
	Call yellowText
	ret
lightBlueText ENDP
eyesAndPointsColor PROC					;Will set eyes color to white.
	Call whiteText				
	mov al, bl
	Call WriteChar
	ret
eyesAndPointsColor ENDP

cmpEyes PROC							;Will save lines of code, and cmp character to ascii value of "O"
	mov al, bl						
	cmp AL, 4Fh
ret
cmpEyes ENDP

pacManWord PROC							;Will print the word PACMAN to screen
	Call yellowText					
	mov ecx, 13							
	mov edx, OFFSET pac-138			
printPacLoop:
	add edx, 139
	Call writeStrWithSP
	loop printPacLoop

	mov ecx, 17
print14to30:
	mov esi, -1
	add edx, 139
begin1:	
	inc esi
	.if esi == 139
		dec	ecx
		jmp loop1
	.endif
	.if esi < 52
		mov eax, 14
		call SetTextColor
		mov al, byte ptr[edx+esi]
		call WriteChar
	.elseif byte ptr[edx+esi] == '0'
		mov eax, 15
		call SetTextColor
		mov al, byte ptr[edx+esi]
		call WriteChar
	.elseif byte ptr[edx+esi] == '1'
		mov eax, 0
		call SetTextColor
		mov al, byte ptr[edx+esi]
		call WriteChar
	.elseif esi >= 52
		.if esi < 100
			mov eax, 4
			call SetTextColor
			mov al, byte ptr[edx + esi]
			call WriteChar
		.else
			mov eax, 3
			call SetTextColor
			mov al, byte ptr[edx + esi]
			call WriteChar
		.endif
	.endif
	jmp begin1
loop1:
	.if ecx != 0
		call Crlf
		jmp print14to30
	.endif
	;add edx, 139
	call Crlf

	mov ecx, 19
print31to49:
	mov esi, -1
	add edx, 139
begin2:	
	inc esi
	.if esi == 139
		dec	ecx
		jmp loop2
	.endif
	.if esi < 52
		mov eax, 14
		call SetTextColor
		mov al, byte ptr[edx+esi]
		call WriteChar
	.elseif byte ptr[edx+esi] == '0'
		mov eax, 15
		call SetTextColor
		mov al, byte ptr[edx+esi]
		call WriteChar
	.elseif byte ptr[edx+esi] == '1'
		mov eax, 0
		call SetTextColor
		mov al, byte ptr[edx+esi]
		call WriteChar
	.elseif esi >= 52
		.if esi < 100
			mov eax, 13
			call SetTextColor
			mov al, byte ptr[edx + esi]
			call WriteChar
		.else
			mov eax, 10
			call SetTextColor
			mov al, byte ptr[edx + esi]
			call WriteChar
		.endif
	.endif
	jmp begin2
loop2:
	.if ecx != 0
		call Crlf
		jmp print31to49
	.endif
	call Crlf

	mov ecx, 7
	mov eax, 15
	call SetTextColor
loop3:
	add edx, 139
	Call writeStrWithSP
	loop loop3

	call Crlf

pacManWord ENDP



whiteText PROC									
	mov eax, 15
	Call SetTextColor
ret
whiteText ENDP


splashScreen PROC							
	Call Crlf								
	mov edx, OFFSET createdBy				
	Call WriteString
	Call Crlf	
	;Call Crlf
	Call pacManWord							
	Call Crlf							
ret 
splashScreen ENDP


;控制操作		1
;			4	3	2
pacManControls PROC						
	Call ReadKey								
	mov BH, pacx
	mov BL, pacy
	;向下走，记方向为 3
	.IF AL == 's' || AL == 'S'
		inc BL							
		Call charAtXY					
		mov pacdir, 3
		mov pacChar, offset pacmanEatShape+36
		.IF AL != '#'				
			
			inc pacy				
			call ghostsVsPacman
			.if al == 'O'
				add bufftime, 50
			.endif

			.if al == 'T'
				add pausetime, 60
			.endif

			.if al == 'X'
				inc totalLives
			.endif
		.ENDIF
	;向上走，记方向为 1
	.ELSEIF AL == 'w' || AL == 'W'
		dec BL							
		Call charAtXY						
		mov pacdir, 1
		mov pacChar, offset pacmanEatShape
		.IF AL != '#'						
			dec pacy
			call ghostsVsPacman
			.if al == 'O'
				add bufftime, 50
			.endif

			.if al == 'T'
				add pausetime, 60
			.endif

			.if al == 'X'
				inc totalLives
			.endif
		.ENDIF
	;向右走，计方向为 2
	.ELSEIF AL == 'd' || AL == 'D'
		inc BH							
		inc BH							
		Call charAtXY						
		mov pacdir, 2
		mov pacChar, offset pacmanEatShape+18
		.IF AL != '#' || pacx == 27						
			inc pacx
			inc pacx
			call ghostsVsPacman		
			.if al == 'O'
				add bufftime, 50
			.endif
			
			.if al == 'T'
				add pausetime, 60
			.endif

			.if al == 'X'
				inc totalLives
			.endif
		.ENDIF
	;向左走，记方向为 4
	.ELSEIF AL == 'a' || AL == 'A'
		dec BH							
		dec BH							
		Call charAtXY		
		mov pacdir, 4	
		mov pacChar, offset pacmanEatShape+54			
		.IF AL != '#'				
			dec pacx
			dec pacx
			call ghostsVsPacman	
			.if al == 'O'
				add bufftime, 50
			.endif

			.if al == 'T'
				add pausetime, 60
			.endif

			.if al == 'X'
				inc totalLives
			.endif
		.ENDIF
	.ENDIF
	cmp pacx, 0						
	je teleportPacMan1
	cmp pacx, 162						
	je teleportPacMan2
	jmp nothingHere
teleportPacMan1:
	mov pacx, 160						
	jmp nothingHere
teleportPacMan2:
	mov pacx, 2							
nothingHere:
	ret
pacManControls ENDP

youWon proc
	call Clrscr						
	mov dh, 12
	mov dl, 34
	call Gotoxy
	mov edx, offset chickenDinner
	call WriteString
	mov dh, 14
	mov dl, 32
	call Gotoxy
	mov edx, offset outputScore
	call WriteString
	mov eax, totalScore
	call WriteDec
	call Crlf
	mov eax, 1000						
	call Delay
	exit
youWon endp

main PROC
	Call splashScreen					
	mov pacChar, offset pacmanEatShape+18
	tryAgain:
		Call ReadChar					
		.IF al != 0						
			Call Clrscr ;清空控制台窗口
			jmp drawFrame
		.ELSE
			jmp tryAgain
		.ENDIF	
	drawFrame:
		
		.if bufftime > 0
			dec bufftime
		.endif

		.if pausetime > 0
			dec pausetime
		.endif

		inc framecount
		.if framecount > 100
			mov framecount, 0
		.endif
		;控制pacman的移动，并进行第一轮碰撞检测（进行第一轮碰撞检测是为了防止对冲而穿过的情况）
		Call pacManControls						 
		;绘制游戏地图
		Call drawStringBoard					
		;按照设定的方位移动鬼的位置
		Call moveGhosts

		;第二轮碰撞检测
		Call ghostsVsPacman
		
		.if bufftime > 0
			;决定下一次向哪个方向移动
			Call directGhostsReverse
		.else 
			call directGhosts
		.endif

		;绘出 ghost 和 pacman 的位置
		Call drawUnits						
		;除去被吃掉的点
		Call removePellet					
		
		Call PacPellet
		;显示当前剩余生命条数
		Call Lives
		Call Crlf
		mov eax, 117						
		Call Delay
		cmp totalLives, 0					
			jl donions
		cmp totalScore, 2460			
			jl drawFrame
			jge winner
	winner:
		mov eax, 200
		call Delay
		call youWon
	donions:
		mov eax, 200
		Call Delay
		Call gameOver
	exit
main ENDP
END main