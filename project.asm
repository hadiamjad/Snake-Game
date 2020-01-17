[org 0x100]
jmp start
snake_position: times 240 dw 0
snakesize: dw 20
Remaining_Seconds: dw 60
tickscount: dw 0
LivesRemaining: dw 'Lives Remaining: '
TimeRemaining: dw 'Time Remaining: '
Semicolon: dw ':'
fruit: db 'ABC'
fruitflag: db 0
deadfruitflag: db 0
tickcountfruit: dw 168
xcoord: db 0
ycoord: db 0
timer_x: dw 0
clock: dw 0
lives: dw 3
Remaining_Minutes: dw 3
speed: dw 18
snake_bite_itself: db 0
fruitcoord: dw 0
deadfruitcoord:dw 0
win: db 0
backstages: db 0
startit: db 0
string:db 'GAME-OVER!'
string2:db 'YOU WON!'
string3:db 'Press 1 to play easy stage,2 for medium stage and 3 for hard stage'
;;;;;;;;;;
printfruits:
pusha
push es

mov byte[fruitflag],1
mov bx,0xb800
mov es,bx
mov dx,0
mov ax,[cs:tickcountfruit]
mov bx,1920
div bx
mov ax,dx
shr ax,1
jc oddone
mov si,dx
cmp word[es:si],0x062d
je prt
cmp word[es:si],0x067c
je prt
cmp word[es:si],0x052a
je prt
mov word[es:si],0x8203
jmp end_p
prt:
add si,164
mov word[es:si],0x8203
jmp end_p
oddone:
add dx,1
mov si,dx
cmp word[es:si],0x062d
je prt2
cmp word[es:si],0x067c
je prt2
cmp word[es:si],0x052a
je prt2
mov word[es:si],0x8205
jmp end_p
prt2:
add si,164
mov word[es:si],0x8205
jmp end_p
end_p:
mov word[fruitcoord],si
pop es
popa
ret
;;;;;;;;;;
poisonousfruit:
pusha
push es
mov byte[deadfruitflag],1
mov bx,0xb800
mov es,bx
mov dx,0
add word[tickcountfruit],80
mov ax,[cs:tickcountfruit]
mov bx,1920
div bx
mov ax,dx
shr ax,1
jc oddone1
mov si,dx
cmp word[es:si],0x062d
je prt_1
cmp word[es:si],0x067c
je prt_1
mov word[es:si],0x8102
jmp end_p1
prt_1:
add si,164
mov word[es:si],0x8102
jmp end_p1
oddone1:
add dx,1
mov si,dx
cmp word[es:si],0x062d
je prt_2
cmp word[es:si],0x067c
je prt_2
mov word[es:si],0x8102
jmp end_p1
prt_2:
add si,164
mov word[es:si],0x8102
jmp end_p1
end_p1:
mov word[deadfruitcoord],si
pop es
popa
ret
;;;;;;;;;;
clrpoisonousfruit:
pusha
push es
mov byte[deadfruitflag],0
mov bx,0xb800
mov es,bx
mov si,word[deadfruitcoord]
mov word[es:si],0x0720
pop es
popa
ret
;;;;;;;;;;
clrfruit:
pusha
push es
mov byte[fruitflag],0
mov bx,0xb800
mov es,bx
mov si,word[fruitcoord]
mov word[es:si],0x0720
pop es
popa
ret
;;;;;;;;;;
produce_sound:
MOV     DX,200          ; Number of times to repeat whole routine.
MOV     BX,0xff           ; Frequency value.
MOV     AL, 10110110B   
OUT     43H, AL          ; Send it to the initializing port 43H Timer 2.
NEXT_FREQUENCY:          ; This is were we will jump back to 2000 times.
MOV     AX, BX           ; Move our Frequency value into AX.
OUT     42H, AL          ; Send LSB to port 42H.
MOV     AL, AH           ; Move MSB into AL 
OUT     42H, AL          ; Send MSB to port 42H.
 
IN      AL, 61H          ; Get current value of port 61H.
OR      AL, 00100111B    ; OR AL to this value, forcing first two bits high.
OUT     61H, AL          ; Copy it to port 61H of the PPI Chip
MOV     CX, 60         
DELAY_LOOP:              ; Here is where we loop back too.
LOOP    DELAY_LOOP       ; Jump repeatedly to DELAY_LOOP until CX = 0
INC     BX               ; Incrementing the value of BX lowers
DEC     DX               ; Decrement repeat routine count
CMP     DX, 0            ; Is DX (repeat count) = to 0
JNZ     NEXT_FREQUENCY   ; If not jump to NEXT_FREQUENCY
IN      AL,61H           ; Get current value of port 61H.
AND     AL,11111100B     ; AND AL to this value, forcing first two bits low.
OUT     61H,AL           ; Copy it to port 61H of the PPI Chip
ret
                   
;;;;;;;;;;
Did_snake_bite:
pusha
mov cx,word[snakesize]
sub cx,1
mov si,snake_position
mov di,word[snake_position]
add si,2

loopd:
cmp word[si],di
je setone
add si,2
dec cx
jnz loopd
jmp endd
setone:
mov byte[snake_bite_itself],1

endd:
popa
ret
;;;;;;;;;;
win_game:
pusha
push es
push bp
mov bx,0xb800
mov es,bx
mov si,0
mov cx,2000
loop_x:
mov word[es:si],0x1720
add si,2
dec cx
jnz loop_x
mov cx,8
mov si,1986
mov di,string2
mov bh,0xb4
loop_y:
mov bl,byte[di]
mov word[es:si],bx
inc di
add si,2
dec cx
jnz loop_y

pop bp
pop es
popa
ret
;;;;;;;;;
start_game:
pusha
push es
push bp
mov bx,0xb800
mov es,bx
mov si,0
mov cx,1920
loopx_:
mov word[es:si],0x1720
add si,2
dec cx
jnz loopx_
mov cx,66
mov si,2088
mov di,string3
mov bh,0xb4
loopy_:
mov bl,byte[di]
mov word[es:si],bx
inc di
add si,2
dec cx
jnz loopy_

pop bp
pop es
popa
ret
;;;;;;;;;
game_over:
pusha
push es
push bp
mov ah,2
mov dl,10
int 21h
mov bx,0xb800
mov es,bx
mov si,0
mov cx,2000
loopx:
mov word[es:si],0x1720
add si,2
dec cx
jnz loopx
mov cx,10
mov si,1986
mov di,string
mov bh,0xb4
loopy:
mov bl,byte[di]
mov word[es:si],bx
inc di
add si,2
dec cx
jnz loopy

pop bp
pop es
popa
ret
;;;;;;;;;;
background: ;background of screen.
pusha
push es
mov ax, 0xb800
mov es,ax
mov si,0
mov di,3680
mov cx, 1840
loop_b:
cmp word[es:si],0x8203
je skip
cmp word[es:si],0x8205
je skip
cmp word[es:si],0x8102
je skip
mov word[es:si],0x0720

skip:
add si,2
dec cx
jnz loop_b
mov cx,80
mov si,0
mov di,3680
loopb1:
mov word[es:si],0x062d
mov word[es:di],0x062d
add si,2
add di,2
dec cx
jnz loopb1
mov cx,24
mov si,0
mov di,158
loopb:
mov word[es:si],0x067c
mov word[es:di],0x067c
add si,160
add di,160
dec cx
jnz loopb

cmp byte[backstages],1
je medium
cmp byte[backstages],2
je hard
jmp end_b
medium:
mov cx,12
mov si,816
loop_b_1:
mov word[es:si],0x062d
add si,2
dec cx
jnz loop_b_1
mov cx,5
mov si,816
loop_b_1i:
mov word[es:si],0x067c
add si,160
dec cx
jnz loop_b_1i
mov cx,12
mov si,3080
loop_b_2:
mov word[es:si],0x062d
add si,2
dec cx
jnz loop_b_2
mov cx,5
mov si,3080
loop_b_2i:
mov word[es:si],0x067c
sub si,160
dec cx
jnz loop_b_2i
jmp end_b
hard:
mov cx,12
mov si,816
loop_c_1:
mov word[es:si],0x062d
add si,2
dec cx
jnz loop_c_1
mov cx,5
mov si,816
loop_c_1i:
mov word[es:si],0x067c
add si,160
dec cx
jnz loop_c_1i
mov cx,12
mov si,3080
loop_c_2:
mov word[es:si],0x062d
add si,2
dec cx
jnz loop_c_2
mov cx,5
mov si,3080
loop_c_2i:
mov word[es:si],0x067c
sub si,160
dec cx
jnz loop_c_2i
mov cx,12
mov si,466
loop_c_3:
mov word[es:si],0x062d
sub si,2
dec cx
jnz loop_c_3
mov cx,10
mov si,466
loop_c_3i:
mov word[es:si],0x067c
add si,160
dec cx
jnz loop_c_3i

end_b:
pop es
popa
ret
;;;;;;;;;;
printnum:    
push bp              
mov  bp, sp              
push es              
push ax              
push bx              
push cx              
push dx              
push di 
             
mov  ax, 0xb800              
mov  es, ax             ; point es to video base              
mov  ax, [bp+4]         ; load number in ax              
mov  bx, 10             ; use base 10 for division              
mov  cx, 0              ; initialize count of digits 
nextdigit:   
mov  dx, 0              ; zero upper half of dividend              
div  bx                 ; divide by 10              
add  dl, 0x30           ; convert digit into ascii value              
push dx                 ; save ascii value on stack              
inc  cx                 ; increment count of values               
cmp  ax, 0              ; is the quotient zero              
jnz  nextdigit          ; if no divide it again 
        
mov  di, [bp+6]            ; point di to parameter given in stack
cmp cx,1
jne nextpos
push 0
inc cx
nextpos:     
pop  dx                 ; remove a digit from the stack              
mov  dh, 0x07           ; use normal attribute              
mov [es:di], dx         ; print char on screen              
add  di, 2              ; move to next screen location              
loop nextpos            ; repeat for all digits on stack
             
pop  di              
pop  dx              
pop  cx              
pop  bx              
pop  ax              
pop  es              
pop  bp              
ret  4
;------------------------------------------------------
printInterface:
push bp
push ax
push bx
push cx
push dx
mov ax,[cs:tickcountfruit]
mov dx, 0
mov bx,18
div bx
cmp dx,0
jne print_lastrow
cmp word [cs:Remaining_Seconds],0
jne skip1
cmp word [cs:Remaining_Minutes],0
je print_lastrow
skip1:
dec word[cs:Remaining_Seconds]
cmp word[cs:Remaining_Seconds],0
jne print_lastrow
cmp word [cs:Remaining_Minutes],0
je print_lastrow
dec word[cs:Remaining_Minutes]
mov word[cs:Remaining_Seconds],60
print_lastrow:
mov ah,0
mov al,04
push ax
mov al,2
push ax
mov al,24
push ax
mov ax,17
push ax
mov bx,LivesRemaining
push bx
call print
Semicolonprint:
mov ah,0
mov al,04
push ax
mov ax,48
push ax
mov ax,24
push ax
mov ax,1
push ax
mov bx,Semicolon
push bx
call print

Timerprint:
mov ah,00
mov al,04
push ax
mov ax,30
push ax
mov ax,24
push ax
mov ax,16
push ax
mov bx,TimeRemaining
push bx
call print
mov ax,3874
push ax
mov ax,[cs:lives]
push ax
call printnum
mov ax,3932
push ax
mov ax, [cs:Remaining_Minutes]
push ax
call printnum
mov ax,3938
push ax
mov ax, [cs:Remaining_Seconds]
push ax
call printnum

pop dx
pop cx
pop bx
pop ax
pop bp
ret
;---------------------------------------------------
print:
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push di
push es
push ds
mov  ah, 0x13           ; service 13 - print string              
mov  al, 00             ; subservice 01 – update cursor              
mov  bh, 0              ; output on page 0              
mov  bl, [bp+12]              ; normal attrib     
mov dh,[bp+8]  ;y-coord
mov dl,[bp+10]   ;x-coord   
           
mov  cx, [bp+6]         ; length of string              
push cs                
pop  es                 ; segment of string
mov di,[bp+4]           
mov  bp,di       ; offset of string               
int  0x10               ; call BIOS video service
pop ds
pop es
pop di
pop dx
pop cx
pop bx
pop ax
pop bp
ret 10
;;;;;;;;;;;;
intialposition:  ;Brings back snake to its initial position that is middle of the screen.
pusha
push es
mov si,0
mov cx,[snakesize]
mov di,2158
loopi:
mov word[snake_position+si],di
add di,2
add si,2
dec cx
jnz loopi
pop es
popa
ret
;;;;;;;;;;;
shifting:    ;this function updates the previous coordinates before updating head.
pusha
mov cx,[snakesize]
sub cx,1
mov di,cx
shl di,1
mov si,di
sub si,2

loops:
mov ax,word[snake_position+si]
mov word[snake_position+di],ax
sub si,2
sub di,2
dec cx
jnz loops
popa
ret
;;;;;;;;;;;
print_snake: ; this function genrally prints the snake after positions are updated.
pusha
push es
call produce_sound
;call background
mov cx,word[snakesize]
sub cx,1
mov ax,0xb800
mov es,ax
mov si,snake_position
mov di,[si]
mov word[es:di],0x842a ; head printing.
add si,2
loop_p:
mov di,[si]
mov word[es:di],0x052a
add si,2
dec cx
jnz loop_p

pop es
popa
ret
;;;;;;;;;;;
compare_obstacle: ;this function searches for the wall and if head is hit by obstacle live is deducted.
pusha
push es
call background
mov ax,0xb800
mov es,ax
mov si,[snake_position]
cmp word[es:si],0x062d
jne nextcmp_c
dec word[lives]
call background
call intialposition
jmp endc
nextcmp_c:
cmp word[es:si],0x067c
jne nextcmp_c0
dec word[lives]
call background
call intialposition
jmp endc
nextcmp_c0:
call Did_snake_bite
cmp byte[snake_bite_itself],1
jne nextcmp_c1
mov byte[snake_bite_itself],0
dec word[lives]
call background
call intialposition
jmp endc
nextcmp_c1:
cmp word[es:si],0x8203
jne nextcmp_c1i
call increase_snakesize
mov byte[fruitflag],0
jmp endc
nextcmp_c1i:
cmp word[es:si],0x8205
jne nextcmp_c2
call increase_snakesize
mov byte[fruitflag],0
jmp endc
nextcmp_c2:
cmp word[es:si],0x8102
jne endc
dec word[lives]
call background
call intialposition
call clrpoisonousfruit

endc:
pop es
popa
ret
;;;;;;;;;;;
snake_movement:  ;this function continues the movement when no key is pressed.
pusha
push es
mov ax,0xb800
mov es,ax
mov si,[snake_position]
mov di,[snake_position+2]
cmp si,di
jg movedown_moveright
jl moveup_moveleft
movedown_moveright:
mov ax, si
mov bx,di
sub ax,bx
cmp ax,160
je move_down

call clrscr
call shifting
add word[snake_position],2
call compare_obstacle
cmp word[lives],0
je gameendt
call print_snake
jmp ends
move_down:
call clrscr
call shifting
add word[snake_position],160
call compare_obstacle
cmp word[lives],0
je gameendt
call print_snake
jmp ends

moveup_moveleft:
mov ax, si
mov bx,di
sub bx,ax
cmp bx,160
je move_up
call clrscr
call shifting
sub word[snake_position],2
call compare_obstacle
cmp byte[lives],0
je gameendt
call print_snake
jmp ends

move_up:
call clrscr
call shifting
sub word[snake_position],160
call compare_obstacle
cmp byte[lives],0
je gameendt
call print_snake
jmp ends

gameendt:
call game_over
pop es
popa
ret

ends:
pop es
popa
ret
;;;;;;;;;;;
clrscr:                 ; this subroutine clears the screen before printing previous position of snake.
pusha
push es
mov cx,word[snakesize]
sub cx,1
mov ax,0xb800
mov es,ax
mov si,snake_position
mov di,[si]
mov word[es:di],0x0720
add si,2
loop_c:
mov di,[si]
mov word[es:di],0x0720
add si,2
dec cx
jnz loop_c
pop es
popa
ret
;;;;;;;;;;;
increase_snakesize: ;this function increases the snake size.
pusha
call clrfruit
cmp word[snakesize],240
jne normal
mov byte[win],1
normal:
;call intialposition
mov cx,[snakesize]
dec cx
mov di,snake_position
loopis:
add di,2
dec cx
jnz loopis
mov si,di
sub si,2
mov ax,[si] ;second last snake positon.
mov bx,[di] ;last snake positon.
sub ax,bx
cmp ax,160
je moveup_decrement
cmp ax,2
je moveleft_decrement
mov ax,[si] ;second last snake positon.
mov bx,[di] ;last snake positon.
sub bx,ax
cmp bx,160
je movedown_increment
cmp bx,2
je moveright_increment

movedown_increment:
mov cx,4
mov si,[di]
add si,160
add di,2
loopis_1:
mov word[di],si
add di,2
add si,160
dec cx
jnz loopis_1
jmp end_i
moveright_increment:
mov cx,4
mov si,[di]
add si,2
add di,2
loopis_2:
mov word[di],si
add di,2
add si,2
dec cx
jnz loopis_2
jmp end_i
moveup_decrement:
mov cx,4
mov si,[di]
sub si,160
add di,2
loopis_3:
mov word[di],si
add di,2
sub si,160
dec cx
jnz loopis_3
jmp end_i

moveleft_decrement:
mov cx,4
mov si,[di]
sub si,2
add di,2
loopis_4:
mov word[di],si
add di,2
sub si,2
dec cx
jnz loopis_4
jmp end_i
end_i:
add word[snakesize],4
popa
ret
;;;;;;;;;;;
timer:
push ax
cmp byte[startit],1
je start_it
pop ax
mov al,0x20
out 0x20,al
iret
start_it:
inc word[tickscount]  ;for printing after second.
inc word[clock]    ;for speed increment after 20 seconds.
inc word[tickcountfruit] ;for fruit generation.
inc word[timer_x]
cmp byte[lives],0
je gameend
cmp word[timer_x],4320
je gameend
cmp byte[win],1
je gamewin
nextcheck_1;
cmp word[clock],360   ;check for 20 seconds
jne nextcheck1
cmp word[speed],2
je skipit
sub word[speed],2   ;speed increase by 2.
skipit:
mov word[clock],0   ;clock count again 0.
mov word[tickscount],0
nextcheck1:
mov ax,word[speed]   ;printing of snake.
cmp word[tickscount],ax  
jne nextcheck_c1
call snake_movement   ;moves snakes.
mov word[tickscount],0
nextcheck_c1:
cmp byte[cs:fruitflag],0    ;compare fruit flag.
jne nextcheck_c2
call printfruits
;mov word[tickscount],0
jmp endt
nextcheck_c2:
cmp byte[cs:deadfruitflag],0
jne endt
call poisonousfruit
jmp endt
gamewin:
call win_game
pop ax
mov al,0x20
out 0x20,al
iret
gameend:
mov byte[lives],0
call game_over
pop ax
mov al,0x20
out 0x20,al
iret
endt:
call printInterface
pop ax
mov al,0x20
out 0x20,al
iret
;;;;;;;;;;;
kbisr:
cmp byte[startit],1
je keychecks
in al,0x60
cmp al,0x02
je stage1
cmp al,0x03
je stage2
cmp al,0x04
je stage3
mov al,0x20
out 0x20,al
iret

stage1:
mov byte[startit],1
mov byte[backstages],0
call background
call intialposition
call print_snake
mov al,0x20
out 0x20,al
iret
stage2:
mov byte[startit],1
mov byte[backstages],1
call background
call intialposition
call print_snake
mov al,0x20
out 0x20,al
iret
stage3:
mov byte[startit],1
mov byte[backstages],2
call background
call intialposition
call print_snake
mov al,0x20
out 0x20,al
iret
keychecks:
in al,0x60
cmp al,30
jne nextcmp
call clrscr
call shifting
sub word[snake_position],2
call compare_obstacle
cmp byte[lives],0
je end_over
call print_snake
jmp endk
nextcmp:
cmp al,32
jne nextcmp2
call clrscr
call shifting
add word[snake_position],2
call compare_obstacle
cmp byte[lives],0
je end_over
call print_snake
jmp endk
nextcmp2:
cmp al,17
jne nextcmp3
call clrscr
call shifting
sub word[snake_position],160
call compare_obstacle
cmp byte[lives],0
je end_over
call print_snake
jmp endk
nextcmp3:
cmp al,31
jne endk
call clrscr
call shifting
add word[snake_position],160
call compare_obstacle
cmp byte[lives],0
je end_over
call print_snake
jmp endk

end_over:
call game_over
mov al,0x20
out 0x20,al
iret
endk:
mov al,0x20
out 0x20,al
iret
;;;;;;;;;;;
start:

xor ax,ax
mov es,ax
cli
mov word[es:8*4],timer
mov [es:8*4+2],cs
mov word[es:9*4],kbisr
mov [es:9*4+2],cs
sti
call start_game
l1: mov ah,0
 int 0x16
 jmp l1

mov ax,0x4c00
int 0x21