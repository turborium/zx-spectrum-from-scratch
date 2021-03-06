    ; указываем ассемблеру, что целевая платформа - spectrum128(pentagon)
    device zxspectrum128
    
    ; адрес на который компилировать
    org #6100
    
begin_file:
    ; устанавливаем дно стека
    ld sp,#6100

    ; разрешаем прерывания
    ei

    ; заполняем экран шахматкой
    call draw_chess

    ; очищаем атрибуты
    ld a,0
    call clear_attr


    ; рисуем лесенку из атрибутов
    ld d,0
    ld e,0
    ld b,24
.loop:
    ld a,e
    inc a
    call draw_attr_mega_fast
    
    inc d
    inc e

    djnz .loop

    di:halt
    ret


; Процедура заливки экрана шахматкой 
; испорченные регистры: af,hl,de,bc
draw_chess:
    ;  шахматка
    ld a,#55
    ld hl,#4000
    ld de,#4000+1
    ld b,192/8
.cloop:
    push bc
    cpl
    ld bc,32*8
    ld (hl),a
    ldir
    pop bc
    djnz .cloop
    ret

; Процедура очистки атрибутов 
; a - цвет атрибутов экрана
; испорченные регистры: af,hl,de,bc
clear_attr:
    ; заполняем атрибуты
    ld hl,#5800
    ld de,#5800 + 1
    ld bc,768 - 1
    ld (hl),a
    ldir
    ret

; Процедура рисования атрибута по координатам
; d - x
; e - y
; a - color
; испорченные регистры: af,hl
; 131t
draw_attr_simple:
    push af
    ; e * 32 -> hl
    ld l,e
    ld h,0; 0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ; l + d -> l
    ld a,l
    add d
    ld l,a
    ; add attr
    ld a,h
    add #58
    ld h,a
    pop af
    ld (hl),a
    ret

; Процедура рисования атрибута по координатам
; d - x
; e - y
; a - color
; испорченные регистры: af,hl
; 127t
draw_attr:
    push af
    ; e * 32 -> hl
    ld a,(#58 << 3) & #ff
    or e
    ld l,a
    ld h,#58 >> 5; 0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ; l + d -> l
    ld a,l
    add d
    ld l,a
    ; add attr
    pop af
    ld (hl),a
    ret

; Процедура рисования атрибута по координатам
; d - x
; e - y
; a - color
; испорченные регистры: af,hl
; 122t
draw_attr_fast:
    ld (.color+1),a
    ; e * 32 -> hl
    ld a,(#58 << 3) & #ff
    or e
    ld l,a
    ld h,#58 >> 5; 0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ; l + d -> l
    ld a,l
    add d
    ld l,a
    ; add attr
.color:
    ld (hl),#00
    ret

; Процедура рисования атрибута по координатам
; d - x
; e - y
; a - color
; испорченные регистры: af,af',hl
; 106t
draw_attr_mega_fast:
    ex af,af
    ; e * 32 -> hl
    ld a,(#58 << 3) & #ff
    or e
    ld l,a
    ld h,#58 >> 5; 0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ; l + d -> l
    ld a,l
    add d
    ld l,a
    ; add attr
    ex af,af
    ld (hl),a
    ret

; Процедура рисования атрибута по координатам
; h - x
; l - y
; a - color
; испорченные регистры: af,hl
; 128t
draw_attr_classic:
    push af
    ld a,h; x -> a
    ld h,l; y -> l
    ld l,0; [y][0]->hl
    and a; clear c
    ; [0,0,0,y,y,y,y,y][0,0,0,0,0,0,0,0]->[0,0,0,0,0,0,y,y][y,y,y,0,0,0,0,0]
    rr h: rr l; hl[>>]
    rr h: rr l; hl[>>]
    rr h: rr l; hl[>>]
    ; [0,0,0,0,0,0,y,y][y,y,y,0,0,0,0,0]->[0,0,0,0,0,0,y,y][y,y,y,x,x,x,x,x] 
    add l
    ld l,a
    ; add attr addr
    ld a,h
    or #58
    ld h,a
    pop af
    ld (hl),a
    ret
    
end_file:
    ; выводим размер банарника
    display "code size: ", /d, end_file - begin_file
    
    ; сохраняем sna(снапшот состояния) файл
    savesna "attr.sna", begin_file
    
    ; сохраняем метки
    labelslist "user.l"
