    ; шаблон проекта
    ; чтобы создать новый:
    ; 1) сделать копию этой папки, и назвать ее <имя проекта>
    ; 2) переименовать этот файл в <имя пректа>
    ; 3) изменить строчку <savesna "template.sna", begin_file>, изменить template на <имя проекта>
    ; 4) изменить <set name=template> в run.bat, изменить template на <имя проекта> 

    ; указываем ассемблеру, что целевая платформа - spectrum128(pentagon)
    device zxspectrum128
    
    ; адрес на который компилировать
    org #6100
    
begin_file:
    ; запрещаем прерывания
    di
    
    ; устанавливаем дно стека
    ld sp,#6100

loop:
    ; синий бордюр 
    ld a,1
    out (#fe),a

    nop:nop:nop ; nop:nop:nop занимает столько же тактов, что и jr n (12)
    
    ; красный бордюр 
    ld a,2
    out (#fe),a
    
    jr loop
    
end_file:
    ; выводим размер банарника
    display "code size: ", /d, end_file - begin_file
    
    ; сохраняем sna(снапшот состояния) файл
    savesna "template.sna", begin_file
    
    ; сохраняем метки
    labelslist "user.l"
