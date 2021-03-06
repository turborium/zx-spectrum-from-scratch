    ; указываем ассемблеру, что целевая платформа - spectrum128(pentagon)
    device zxspectrum128
    
sin_table equ #8000
sin_table2 equ #8100

    ; адрес на который компилировать
    org #6100
    
begin_file:
    ; устанавливаем дно стека
    ld sp,#6100

    ; разрешаем прерывания
    ei

    ; генерируем таблицу синусов амплитодой в +/-11
    ld d,11
    ld ix,sin_table
    call gen_sin

    ; генерируем таблицу синусов амплитодой в +/-15
    ld d,15
    ld ix,sin_table2
    call gen_sin

    ; рисуем шахматку
    call draw_chess

    ; очищаем атрибуты
    xor a
    call clear_attr

    ; главный цикл
.loop:
    ; ждем следующий кадр
    halt

    ; белый бордюр
    ld a,7
    out (#fe),a

    ; очищаем экран (затемняем)
    ld hl,#5800
    ld b,48
.clear
    dup 16
    srl (hl)
    inc hl
    edup
    djnz .clear

    ; синий бордюр
    ld a,1
    out (#fe),a

    ; загружаем и увеличиваем переменную time_b в b
    ld a,(.time_b)
    ld b,a
    add 2
    ld (.time_b),a

    ; загружаем и увеличиваем переменную time_c в c
    ld a,(.time_c)
    ld c,a
    add 3
    ld (.time_c),a

    exx
    ; количество отрисовываемых атрибутов (итераций цикла)
    ld b,10
    
    ; цикл отрисовки
.draw_loop:
    exx

    ; меняем эффект
    ; 1 эффект:
    /*
    inc b
    inc c
    inc c
    */
    ; 2 эффект:
    ld a,b
    add 127
    ld b,a
    ; 3 эффект:
    /*
    inc b
    inc c
    */

    ; d = sin(b) + 32/2
    ld h,high sin_table2
    ld l,b
    ld a,(hl)
    add 32/2
    ld d,a

    ; c = sin(b) + 24/2
    ld h,high sin_table
    ld l,c
    ld a,(hl)
    add 24/2
    ld e,a

    ; рисуем белую точку (атрибут)
    ld a,127
    call draw_attr_fast

    exx
    djnz .draw_loop
    ; конец цикла

    ; черный бордюр
    ld a,0
    out (#fe),a

    jp .loop

.time_b db 0
.time_c db 0


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

    ; ix - table, align 256
    ; d - amp
gen_sin:
    ld e,#bc
    ld hl,0    ;K*SIN
.loop:
    ld (ix),d
    ld a,d
    rla
    sbc a,a
    ld b,a
    ld c,d
    adc hl,bc ;tweaking
    rr c
    rrca
    rr c
    add hl,bc
    ex de,hl
    ld b,d
    ld a,e
    dup 3
    sra b
    rra
    edup
    ld c,a
    sbc hl,bc
    ex de,hl
    inc ixl
    jr nz,.loop
    ret
    
end_file:
    ; выводим размер банарника
    display "code size: ", /d, end_file - begin_file
    
    ; сохраняем sna(снапшот состояния) файл
    savesna "attr_sin.sna", begin_file
    
    ; сохраняем метки
    labelslist "user.l"
