    ; вызов процедур из пзу
    ; описание некоторых процедур - http://zxpress.ru/article.php?id=8953
    ; https://zxpress.ru/book_articles.php?id=1876 
    ; http://zxpress.ru/article.php?id=10668
    
    ; указываем ассемблеру, что целевая платформа - spectrum128(pentagon)
    device zxspectrum128
    
    ; адрес на который компилировать
    org #6100
    
begin_file:

    ; устанавливаем дно стека
    ld sp,#6100

    ; очистка экрана
    call #0d6b

    ; устанавливаем поток вывода в 2 - основной экран
    ld a,2; a - поток
    call #1601

    ; печатаем приветствие
    ld de,str; de - строка для печати
    ld bc,6; bc - количество символов в строке
    call #203c

    ; перенос строки
    ld a,13
    rst #10

loop:
    ; помещаем число в стек калькулятора
    ld bc,(num); bc - число
    call #2d2b
    ; выводим число из стека калькулятора на экран
    call #2de3

    ; перенос строки
    ld a,13
    rst #10

    ; увеличиваем num
    ld hl,(num)
    inc hl
    ld (num),hl
 
    jr loop

str defb "hello!"
num dw 0
    
end_file:
    ; выводим размер банарника
    display "code size: ", /d, end_file - begin_file
    
    ; сохраняем бинарник
    ;       имя на диске  имя в zx     начало      длина
    savehob "syscall.$C", "syscall.C", begin_file, end_file - begin_file

    ; сохраняем метки
    labelslist "user.l"
