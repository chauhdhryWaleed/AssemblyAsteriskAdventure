; display a tick count on the top right of screen
[org 0x0100]
jmp start

score:dw 0
oldkb: dd 0
oldkb1: dd 0
direction: dw 1
position: dw 322
count: dw 0
string: db 'SCORE:'
stringL: dw 6
string1: db 'YOU DIED :('
string1L: db 11
mapcheck: dw 0  ;1 if green 2 if red
; subroutine to print a number at top left of screen
; takes the number to be printed as its parameter
clrscr:

pusha 

mov ax,0xb800
mov es,ax
mov di,0
mov cx,2000
mov ax,0x0720
rep stosw

popa
ret




map:
pusha


mov ax,0xb800
mov es,ax

mov di,160
mov cx,1920
mov ax,0x2020
rep stosw
mov cx,80
mov di,160     
mov ax,0x4020    
cld
rep stosw


mov cx,24
mov di,318
mov ax,0x4020

j:
mov [es:di],ax
add di,160
loop j
mov cx,24
mov di,160
l:
mov [es:di],ax
add di,160
loop l
mov cx,80
mov di,3840
rep stosw

mov di,1002
mov cx,40
rep stosw


mov di,2922
mov cx,40
rep stosw

mov di,1304
mov cx,9
f:
mov word[es:di],ax
add di,160
loop f

mov di,1418
mov cx,9

g:
mov word[es:di],ax
add di,160
loop g

popa
ret

printstr:

push bp
mov bp,sp
push es
push ax
push bx
push si  
push di
mov ax,0xb800
mov es,ax
mov si,[bp+6]
mov cx,[bp+4]
mov ah,0x07
mov di,140
cld

k:
lodsb
stosw
loop k
pop di
pop si
pop bx
pop ax
pop es
pop bp
ret 4

printstr1:

push bp
mov bp,sp
push es
push ax
push bx
push si  
push di
mov ax,0xb800
mov es,ax
mov si,[bp+6]]
mov cx,[bp+4]
mov ah,0x07
mov di,1986
cld

k1:
lodsb
stosw
loop k1
pop di
pop si
pop bx
pop ax
pop es
pop bp
ret 4

printstr2:

push bp
mov bp,sp
push es
push ax
push bx
push si  
push di
mov ax,0xb800
mov es,ax
mov si,[bp+6]
mov cx,11
mov ah,0x07
mov di,1666
cld

k2:
lodsb
stosw
loop k2
pop di
pop si
pop bx
pop ax
pop es
pop bp
ret 4
checkmovement:

push bp
mov bp,sp
push ax
push es
push di
mov ax,0xb800
mov es,ax

mov di,[bp+4]

cmp word[es:di],0x2020
je green
cmp word[es:di],0x4020
je red

cmp word[es:di],0x0720
je white


green:
mov word[mapcheck],1
jmp end1
red:
mov word[mapcheck],2
jmp end1


white: 
mov word[mapcheck],0



end1:
pop di
pop es
pop ax
pop bp
ret 2



movement:

pusha

mov ax,0xb800
mov es,ax



mov di,[position]

mov ax,0x072a

moveright:

cmp word[direction],1
jne moveleft

mov word[es:di],0x0720
add word[position],2
add di,2
push di
call checkmovement
mov word[es:di],ax
cmp word[mapcheck],2
je go


cmp word[mapcheck],0
je go


inc word [score]; increment tick count
go:push word [score]
call printnum

jmp return



moveleft:
cmp word[direction],2
jne moveup

mov word[es:di],0x0720
sub word[position],2
sub di,2
push di
call checkmovement
mov word[es:di],ax
cmp word[mapcheck],2
je go1
cmp word[mapcheck],0
je go1




inc word [score]; increment tick count
go1:push word [score]
call printnum

jmp return



moveup:
cmp word[direction],3
jne movedown
mov word [es:di],0x0720
sub word[position],160
sub di,160
push di
call checkmovement
mov word[es:di],ax
cmp word[mapcheck],2
je go2

cmp word[mapcheck],0
je go2



inc word [score]; increment tick count
go2:push word [score]
call printnum
jmp return

movedown:
cmp word[direction],4
jne return


mov word[es:di],0x0720
add word[position],160

add di,160
push di
call checkmovement
mov word[es:di],ax
cmp word[mapcheck],2
je go3
cmp word[mapcheck],0
je go3


inc word [score]; increment tick count
go3:push word [score]
call printnum


return:
popa
ret

printnum:

 push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base

mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit1: mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigit1 ; if no divide it again
mov di, 154 ; point di to 70th column
nextpos1: pop dx ; remove a digit from the stack
mov dh, 0x07 ; use normal attribute
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextpos1 ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 2

printnumend:

 push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base

mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigit ; if no divide it again
mov di, 2000 ; point di to 70th column
nextpos: pop dx ; remove a digit from the stack
mov dh, 0x07 ; use normal attribute
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextpos ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 2
; timer interrupt service routine

kbisr: push ax
in al, 0x60 ; read char from keyboard port
cmp al, 0x4d ; has the right direction key pressed
jne nextcmp
cmp word [direction], 1; is the flag already set
je exit ; leave the ISR
mov word [direction], 1; is the flag already set

jmp exit ; leave the ISR



nextcmp: cmp al, 0x4b ; has the left shift released
jne nextcmp1 ; no, chain to old ISR
cmp word[direction],2
je exit
mov word [direction], 2; reset flag to stop printing
jmp exit ; leave the interrupt routine

nextcmp1: 
cmp al,0x48 ;has up key pressed
jne nextcmp2
cmp word [direction],3
je exit
mov word [direction], 3
jmp exit

nextcmp2:

cmp al,0x50
jne nomatch
cmp word[direction],4
je exit
mov word [direction],4
jmp exit
nomatch: pop ax

jmp far [cs:oldkb] ; call original IS
exit: mov al, 0x20
out 0x20, al ; send EOI to PIC
pop ax
iret ; return from interrupt

timer: push ax
mov ax,0xb800
mov es,ax




add word[count],1
cmp word[count],18

jne end
mov word[count],0

call movement ; print tick count


end:
mov al, 0x20
out 0x20, al ; end of interrupt
pop ax
iret ; return from interrupt

start:
call clrscr
push word string
push word[stringL]
call printstr
call map
 xor ax, ax
mov es, ax ; point es to IVT base
mov ax,[es:9*4]
mov [oldkb],ax
mov ax,[es:9*4+2]
mov [oldkb+2],ax
mov ax,[es:8*4]
mov [oldkb1],ax
mov ax,[es:8*4+2]
mov [oldkb1+2],ax

cli ; disable interrupts
mov word[es:9*4],kbisr
mov word[es:9*4+2],cs
mov word [es:8*4], timer; store offset at n*4
mov word[es:8*4+2], cs ; store segment at n*4+2
sti ; enable interrupts
again:
cmp word[mapcheck],2
je endgame
jmp again
endgame:

call clrscr
push word string1
push word[string1L]
call printstr2
push word string
push word[stringL]
call printstr1
push word[score]

call printnumend
xor ax,ax
mov es,ax

mov ax,[oldkb]
mov word[es:9*4],ax
mov ax,[oldkb+2]
mov word[es:9*4+2],ax
mov ax,[oldkb1]
mov word [es:8*4], ax; store offset at n*4
mov ax,[oldkb1+2]
mov word[es:8*4+2], ax ; store segment at n*4+2
mov dx, start ; end of resident portion
add dx, 15 ; round up to next para
mov cl, 4
shr dx, cl ; number of paras
mov ax, 0x3100 ; terminate and stay resident
int 0x21