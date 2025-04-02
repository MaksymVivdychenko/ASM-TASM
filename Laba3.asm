.model SMALL
.STACK 10h
.DATA
    ;Вивід функції
    enter_msg db 'This program find the result of function:',0Dh,0Ah, '$'
    vertical_slash db   '        |',0Dh, 0Ah, '$'
    horizontal_lines db '--------------------------------------', 0Dh, 0Ah, '$'
    first_line_func  db '        ( 8x^2 + 36/x, if x > 0', 0Dh, 0Ah, '$'
    second_line_func db '   Z = < (1+x)/(1-x), if -5 <= x <= 0', 0Dh, 0Ah, '$'
    third_line_func  db '        ( 10x^2, if x < -5', 0Dh, 0Ah,  '$'
    ;Вивід функції

    overflow_msg db 0Dh,0Ah,'this value cought overflow, please choose the smaller one', 0Dh, 0Ah, '$'
    number_msg db 'Enter the x[-99;99]:$'
    enterData db 4, ?, 4 dup("?")
    result_msg db 0Dh, 0Ah,'Z = $'
    new_line db 0Dh, 0Ah, '$'
    continue_msg db 'Do you want to continue? (y/n)',0Dh, 0Ah, '$'
    error_msg db 0Dh, 0Ah,'Error: invalid input',0Dh, 0Ah, '$'
    out_of_range_error_msg db 0Dh, 0Ah,'Error: out of range',0Dh, 0Ah, '$'

    continue_input db 2, ?, 2 dup("?")
    x dw 0
    accumulator dw 0
    numerator dw 0
    denumerator dw 0
    
    of_flag db 0

    is_not_valid db 0
    is_neg db 0
    is_not_int db 0 

    counter_for_print db 0
.CODE
START:
    mov ax, @DATA
    mov ds, ax

    call enter_msg_print
    
    program_loop:
        call clear_values

        call scan_parse
        
        cmp is_not_valid, 1
        je is_continue

        cmp x, 0
        jg first_equation

        cmp x, -5
        jl  third_equation

        jmp second_equation

        first_equation:
            call first_equation_proc
            cmp of_flag, 1
            je is_continue
            jmp print_result_main


        third_equation:
            call third_equation_proc
            cmp of_flag, 1
            je is_continue
            jmp print_result_main
        
        second_equation:
            call second_equation_proc
            jmp print_result_main

        print_result_main:
        call print_result

        is_continue:
        mov ah, 9
        mov dx, offset continue_msg
        int 21h

        mov dx, offset continue_input
        mov ah, 0Ah
        int 21h
        cmp continue_input+2, 'y'
    je program_loop

    mov ax, 4C00h
    int 21h

clear_values proc 
    mov of_flag, 0
    mov x, 0
    mov accumulator, 0
    mov is_not_valid, 0
    mov is_neg, 0
    mov is_not_int, 0
    mov numerator, 0
    mov denumerator, 0
    ret
endp clear_values

enter_msg_print proc 
        mov ah, 09h
    mov dx, offset enter_msg
    int 21h

    mov dx, offset horizontal_lines
    int 21h

    mov dx, offset first_line_func
    int 21h

    mov dx, offset vertical_slash
    int 21h

    mov dx, offset second_line_func
    int 21h

    mov dx, offset vertical_slash
    int 21h

    mov dx, offset third_line_func
    int 21h

    mov dx, offset horizontal_lines
    int 21h

    ret
    endp enter_msg_print

scan_parse proc
        mov dx, offset number_msg
        mov ah, 09h
        int 21h
        
        mov dx, offset enterData
        mov ah, 0Ah
        int 21h

        mov al, enterData+2
        cmp al, '-'
        je is_negative
        jne is_positive

        is_positive:
            call digit_validation
            mov cl, enterData+1                 
            mov si, offset enterData+1 
            jmp valid_check

        is_negative:
            mov is_neg, 1
            call digit_validation
            mov cl, enterData+1                  
            mov si, offset enterData+2 
            dec cl
        
        valid_check:
            cmp is_not_valid, 1
            je end_scan_parse

            cmp is_neg, 1  
            je before_parse_loop

            cmp enterData+1, 2
            jg check_zero
            jmp before_parse_loop
            
            check_zero:
                mov al, enterData+2
                cmp al, '0'
                je before_parse_loop

                out_of_range_error:
                    mov is_not_valid, 1
                    mov ah, 09h
                    mov dx, offset out_of_range_error_msg
                    int 21h
                    jmp end_scan_parse

        before_parse_loop:   
            add si, cx   
            mov ax, 0 
            mov bx, 1

        parse_loop:
            mov ah, 0
            mov al, [si]
            sub ax, '0'
            mul bx
            add x, ax
            mov ax, bx
            mov bx, 10
            mul bx
            mov bx, ax
            dec si
        loop parse_loop
        
        cmp is_neg, 1
        jne end_scan_parse
        mov ax, x
        neg ax
        mov x, ax

        end_scan_parse:
        ret
        endp scan_parse

print_result proc

    mov ah, 9
    mov dx, offset result_msg
    int 21h

    cmp accumulator, 0
    jne accumulator_not_zero

    accumulator_zero:
        cmp is_not_int, 1
        je print_remainder
        mov dl, '0'
        mov ah, 02
        int 21h
        jmp print_result_end

    accumulator_not_zero:
    mov ax, accumulator
    call parse_print_num

    
    cmp is_not_int, 1
    jne print_result_end

    print_remainder:
    cmp numerator, 0
    jg print_remainder_positive
    mov dl, '-'
    mov ah, 02
    int 21h

    mov ax, numerator
    neg ax
    mov numerator, ax
    
    print_remainder_positive:
    mov dx,'('
    mov ah, 02
    int 21h
    
    mov ax, numerator
    call parse_print_num

    mov dx, '/'
    mov ah, 02
    int 21h

    mov ax, denumerator
    call parse_print_num

    mov dx, ')'
    mov ah, 02
    int 21h

    print_result_end:
    mov dx, offset new_line
    mov ah, 9
    int 21h

    endp print_result

digit_validation proc
        cmp is_neg, 1
        je neg_validation
        jne pos_validation

        pos_validation:
            mov si, offset enterData+2
            mov cl, enterData+1
            jmp validation_loop
        
        neg_validation:
            mov si, offset enterData+3
            mov cl, enterData+1
            dec cl
            jmp validation_loop
        
        
        validation_loop:
            mov al, [si]
            cmp al, '0'
            jl error
            cmp al, '9'
            jg error
            inc si
        loop validation_loop
        ret

        error:
            mov ah, 09h
            mov dx, offset error_msg
            int 21h

            mov is_not_valid, 1
            ret
    endp digit_validation

first_equation_proc proc

    mov dx, 0

    mov ax, x
    mov bx, x
    imul bx
    jo first_equation_overflow

    mov bx, 8
    imul bx
    jo first_equation_overflow

    mov accumulator, ax

    mov ax, 36
    mov bx, x
    idiv bx
    add accumulator, ax

    cmp dx, 0
    je end_first_equation

    mov numerator, dx
    mov ax, x
    mov denumerator, ax
    mov is_not_int, 1
    

    end_first_equation:
    ret

    first_equation_overflow: 
        call overflow_error
        ret
endp first_equation_proc

third_equation_proc proc
    mov dx, 0
    mov ax, x
    mov bx, x
    imul bx
    jo third_equation_overflow

    mov bx, 10
    imul bx
    jo third_equation_overflow
    mov accumulator, ax
    ret

    third_equation_overflow:
        call overflow_error
        ret
endp third_equation_proc

second_equation_proc proc
    mov dx, 0

    mov ax, x
    inc ax

    CWD

    mov bx, x
    
    neg bx
    
    inc bx

    idiv bx
    mov accumulator, ax

    cmp dx, 0
    je end_func

    mov is_not_int, 1

    mov ax, x
    inc ax
    mov numerator, ax 
    sub ax, 2
    neg ax
    mov denumerator, ax

    end_func:
        ret
endp second_equation_proc

parse_print_num proc
    mov cx, 0

    cmp ax, 0
    jg pre_convert_loop
    mov dl, '-'
    mov ah, 02
    int 21h

    neg ax

    pre_convert_loop:
    mov bx, 10  

    convert_loop:
        xor dx, dx
        div bx
        add dl, '0'
        push dx
        inc cx
        cmp ax, 0
        jne convert_loop

    print_loop:
            pop dx
            mov ah, 02h
            int 21h
    loop print_loop
    ret
endp parse_print_num

overflow_error proc
    mov dx, offset overflow_msg+2
    mov ah, 09h
    int 21h
    mov of_flag, 1

    mov dx, offset new_line
    mov ah, 09h
    int 21h
    ret
endp overflow_error
END START