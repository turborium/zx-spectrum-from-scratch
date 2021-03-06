    ; указываем ассемблеру, что целевая платформа - spectrum128(pentagon)
    device zxspectrum128
    
disp equ #4000; 6144 (#1800)
attr equ #5800; 768 (#300)     
    
    ;define USE_DOWN_HL
    
    ; адрес на который компилировать
    org #6100
    
begin_file:
    ; устанавливаем дно стека
    ld sp,#6100

    ; разрешаем прерывания
    ei

    ; черный бордюр 
    xor a
    out (#fe),a    
    
    ; заполняем атрибуты
    ; ink - white
    ; paper - black
    ; bright - 1
    ld a,#47
    ; заполняем атрибуты значением регистра A
    ld hl,attr
    ld de,attr + 1
    ld bc,768 - 1
    ; копируем A в байт по адресу HL
    ld (hl),a
    ; инструкция ldir копирует BC байтов
    ; из источника(HL) в назначение(DE).
    ; благодаря тому что источник и назначеме пересекаются
    ; мы заполняем attr значением в регистре A
    ldir
    
    ; очищаем экран
    xor a
    ld hl,disp
    ld de,disp + 1
    ld bc,6144 - 1
    ld (hl),a
    ldir
    
    ; fill screen
    ld c,#55
    ld hl,disp
.loop:
    ld (hl),c
    inc hl

    ;halt

    ld a,#58
    cp h
    jp nz,.loop

    ; fill attr
    ld c,0
    ld hl,attr
.loop_attr:
    ld (hl),c
    inc hl
    inc c

    halt

    ld a,#5B; attr: #5800..#5B00-1
    cp h
    jp nz,.loop_attr

    di:halt
    ret
    
end_file:
    ; выводим размер банарника
    display "code size: ", /d, end_file - begin_file

    ; сохраняем sna(снапшот состояния) файл
    savesna "scr_fill.sna", begin_file
    
    ; сохраняем метки
    labelslist "user.l"
