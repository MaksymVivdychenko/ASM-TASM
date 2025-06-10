.model SMALL
.STACK 10h
.DATA

    horizontal_lines db 0Dh, 0Ah,'--------------------------------------$'
    enter_msg db 'This program will work with arrays, choose your option',0Dh,0Ah, '$'
    option_1_msg db '1 => work with one-dimensional array',0Dh,0Ah, '$'
    option_2_msg db '2 => exit program',0Dh,0Ah, '$'
    new_line db 0Dh,0Ah, '$'
    option_msg db 'Choose your option:$'
    continue_msg_array db 0Dh,0Ah,'Press anything to continue...$'

    ;One dimensional array options

    array_msg db 'Array: $'
    sum_array_smg db 'The sum of array: $'

    enter_1d_array_msg db 'Enter the size of array[1;10]:$'

    option1_1d_array_msg db '1 => find sum of array',0Dh,0Ah, '$'
    option2_1d_array_msg db '2 => return to main',0Dh,0Ah, '$'

    ;errors
    out_of_range_error_msg db 0Dh, 0Ah,'Error: out of range',0Dh, 0Ah, '$'
    error_msg db 0Dh, 0Ah,'Error: invalid input',0Dh, 0Ah, '$'
    size_error_msg db 0Dh, 0Ah,'Error: invalid size',0Dh, 0Ah, '$'
    option_error_msg db 'Error: invalid option$'

    input_1d_array_msg db 'Enter number$'
    pre_input_1d_array_msg db 0Ah, 0Dh,'Enter number in range[-999;999]:$'
    array dw 25 dup(2)
    array_size dw 0
    

    ;counters
    si_counter dw 0

    is_array_input db 0

    array_counter dw 0
    array_number db 0
    ;counters

    save_num dw 0

    ;for scan values
    enterData db 5, ?, 5 dup("?")
    accumulator dw 0
    is_neg db 0
    is_not_valid db 0
    ;for scan values

    option db 2, ?, 2 dup("?")


    max_range dw 0
    min_range dw 0

    array_loop_counter dw 0

.CODE
find_sum_of_array macro array_macro, array_size_macro, array_byte_in_value
    LOCAL find_sum_loop
    mov cx, array_size_macro
    mov si, 0
    xor ax, ax
    
        find_sum_loop:
        
            add ax, array_macro[si]
            add si, array_byte_in_value

        loop find_sum_loop

    mov save_num, ax

    mov dx, offset new_line
    mov ah, 09h
    int 21h
    
    mov dx, offset sum_array_smg
    int 21h

    mov ax, save_num
    call parse_print_num

endm find_sum_of_array

START:
    mov ax, @DATA
    mov ds, ax

    program_loop:
        mov ax, 0003h
        int 10h

        call enter_msg_print
        mov dx , offset option
        mov ah , 0Ah
        int 21h

        mov dx, offset new_line
        mov ah, 09h
        int 21h

        cmp option+2, '1'
        je one_dimensional_array

        cmp option+2, '2'
        je exit_program

        jmp invalid_option

        invalid_option:
            mov dx, offset option_error_msg
            mov ah, 09h
            int 21h

            mov dx, offset continue_msg_array
            int 21h

            mov ah, 08h
            int 21h

            jmp program_loop

        one_dimensional_array:
            call array_1d_logic
            jmp program_loop
        
    exit_program:
    mov ax, 4C00h
    int 21h

enter_msg_print proc 
        mov ah, 09h
    mov dx, offset enter_msg
    int 21h

    mov dx, offset option_1_msg
    int 21h

    mov dx, offset option_2_msg
    int 21h

    mov dx, offset option_msg
    int 21h
    ret
    endp enter_msg_print

enter_msg_array_1d proc

    mov ah, 09h
    mov dx, offset new_line
    int 21h

    mov ah, 09h
    mov dx, offset option1_1d_array_msg
    int 21h

    mov dx, offset option2_1d_array_msg
    int 21h

    mov dx, offset option_msg
    int 21h
    ret

    endp enter_msg_array_1d

scan_1d_array proc 
    array_size_loop:
            mov min_range, 1
            mov max_range, 10

            mov dx, offset enter_1d_array_msg
            call scan_single_value

            after_size_input:
            mov array_size, ax
            mov cx, ax
            mov array_number, '1'
            mov si_counter, 0

            mov ah, 09h
            mov dx, offset pre_input_1d_array_msg
            int 21h

            array_input_loop:
                mov dx, offset new_line
                mov ah, 09h
                int 21h

                mov dx, offset input_1d_array_msg
                mov ah, 09h
                int 21h

                mov dl, array_number
                mov ah, 02h
                int 21h

                mov dl, ':'
                int 21h

                mov dl, ' '
                int 21h

                mov array_counter, cx
                call scan_parse
                mov cx, array_counter

                cmp is_not_valid, 1
                je array_input_loop

                mov si, si_counter
                mov array[si], ax

                add si_counter, 2
                add array_number, 1
            loop array_input_loop
    mov is_array_input, 1
    ret
endp scan_1d_array    

print_1d_array proc
    mov dx, offset new_line
    mov ah, 09h
    int 21h

    mov dx, offset array_msg
    int 21h

    mov cx, array_size
    mov si, 0

    print_array_loop:
        mov ax, array[si]
        
        mov array_counter, cx

        call parse_print_num
        mov cx, array_counter
        add si, 2

        mov dl, ' '
        mov ah, 02h
        int 21h
        loop print_array_loop

    ret
endp print_1d_array

array_1d_logic proc

    cmp is_array_input, 1
    je after_input

    call scan_1d_array

    after_input:

    mov ax, 0003h
    int 10h  
    
    mov dx, offset horizontal_lines
    mov ah, 09h
    int 21h

    call print_1d_array

    mov dx, offset horizontal_lines
    mov ah, 09h
    int 21h

    call enter_msg_array_1d
    mov dx, offset option
    mov ah, 0Ah
    int 21h

    cmp option+2, '1'
    je find_sum_of_array_jump

    cmp option+2, '2'
    je end_1d_array

    
    mov dx, offset error_msg
    mov ah, 09h
    int 21h
    jmp array_1d_logic

    find_sum_of_array_jump:
        find_sum_of_array array, array_size, 2
        jmp continue_jump

        continue_jump:
        mov dx, offset continue_msg_array
        mov ah, 09h
        int 21h

        mov ah, 08h
        int 21h
        jmp array_1d_logic

    end_1d_array:
        mov dx, offset new_line
        mov ah, 09h
        int 21h
        mov is_array_input, 0
        ret

endp array_1d_logic

scan_single_value proc 
    input_value_loop:
        push dx
        mov dx, offset new_line
        mov ah, 09h
        int 21h

        pop dx
        int 21h

        call scan_parse
        cmp is_not_valid, 1
        je input_value_loop

        cmp ax, min_range
        jl input_value_loop


        cmp ax, max_range
        jg invalid_size_error_scan
        
        jmp end_scan_single_value
        invalid_size_error_scan:
            push dx 
            mov dx, offset out_of_range_error_msg
            mov ah, 09h
            int 21h
            pop dx
            jmp input_value_loop
        
        end_scan_single_value:
            ret
endp scan_single_value

parse_print_num proc
    mov cx, 0

    cmp ax, 0
    jge pre_convert_loop
    mov save_num, ax
    mov dl, '-'
    mov ah, 02
    int 21h

    mov ax, save_num
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

scan_parse proc
        mov accumulator, 0 
        mov is_not_valid, 0
        mov is_neg, 0
        push dx
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

            cmp enterData+1, 3
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
            add accumulator, ax
            mov ax, bx
            mov bx, 10
            mul bx
            mov bx, ax
            dec si
        loop parse_loop
        
        mov ax, accumulator
        cmp is_neg, 1
        jne end_scan_parse
        neg ax

        end_scan_parse:
        pop dx
        ret
        endp scan_parse

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
END START