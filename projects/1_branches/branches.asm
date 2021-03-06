    ; указываем ассемблеру, что целевая платформа - spectrum128(pentagon)
    device zxspectrum128
    
    ; адрес на который компилировать
    org #6100
    
begin_file:
    ; разрешаем прерывания
    ei
    
    ; устанавливаем дно стека
    ld sp,#6100

    ; сравниваем 100 с N
    ld a,100
    cp 100

    ; переход, если больше
    jp c,.more

    ; переход если равно
    jp z,.zero

    ; меньше
    ; синий бордюр 
    ld a,1
    out (#fe),a
    di:halt

.more:
    ; красный бордюр 
    ld a,2
    out (#fe),a
    di:halt

.zero:
    ; белый бордюр 
    ld a,7
    out (#fe),a
    di:halt
    
end_file:
    ; выводим размер банарника
    display "code size: ", /d, end_file - begin_file
    
    ; сохраняем sna(снапшот состояния) файл
    savesna "branches.sna", begin_file
    
    ; сохраняем метки
    labelslist "user.l"
