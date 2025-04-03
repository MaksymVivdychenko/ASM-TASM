.model SMALL
.STACK 10h
.DATA

    horizontal_lines db 0Dh, 0Ah,'--------------------------------------$'
    enter_msg db 'This program will work with arrays, choose your option',0Dh,0Ah, '$'
    option_1_msg db '1 => work with one-dimensional array',0Dh,0Ah, '$'
    option_2_msg db '2 => work with two-dimensional array',0Dh,0Ah, '$'
    option_3_msg db '3 => exit program',0Dh,0Ah, '$'
    new_line db 0Dh,0Ah, '$'
    option_msg db 'Choose your option:$'
    continue_msg_array db 0Dh,0Ah,'Press anything to continue...$'

    ;One dimensional array options

    array_msg db 'Array: $'
    sum_array_smg db 'The sum of array: $'

    biggest_value_msg db 0Dh,0Ah,'The biggest value in array:$'
    smallest_value_msg db 0Dh,0Ah,'The smallest value in array:$'

    enter_1d_array_msg db 'Enter the size of array[1;10]:$'



    option1_1d_array_msg db '1 => find sum of array',0Dh,0Ah, '$'
    option2_1d_array_msg db '2 => find the biggest value',0Dh,0Ah, '$'
    option3_1d_array_msg db '3 => find the smallest value',0Dh,0Ah, '$'
    option4_1d_array_msg db '4 => sort array',0Dh,0Ah, '$'
    option6_1d_array_msg db '5 => return to main',0Dh,0Ah, '$'

    out_of_range_error_msg db 0Dh, 0Ah,'Error: out of range',0Dh, 0Ah, '$'
    error_msg db 0Dh, 0Ah,'Error: invalid input',0Dh, 0Ah, '$'
    size_error_msg db 0Dh, 0Ah,'Error: invalid size',0Dh, 0Ah, '$'
    option_error_msg db 'Error: invalid option$'


    ;Two dimensional array options
    enter_2d_array_rows_msg db 'Enter the count of rows in array[1;5]:$'
    enter_2d_array_columns_msg db 'Enter the count of columns in array[1;5]:$'
    option1_2d_array_msg db '1 => find all coordinates of value in array',0Dh,0Ah, '$'
    option2_2d_array_msg db '2 => return to main',0Dh,0Ah, '$'
    coordinates_value_msg db 'The coordinates of value in array:$'

    find_coordinates_2d_msg db 'Enter value:$'

    input_1d_array_msg db 'Enter number$'
    pre_input_1d_array_msg db 0Ah, 0Dh,'Enter number in range[-999;999]:$'
    array dw 25 dup(2)
    array_size dw 0
    

    si_counter dw 0

    sort_outer_counter dw 0
    sort_inner_counter dw 0


    is_array_input db 0

    array_counter dw 0
    array_number db 0

    save_num dw 0

    matrix  dw 25 dup(3)

    matrix_rows dw 0
    matrix_columns dw 0

    enterData db 5, ?, 5 dup("?")
    accumulator dw 0
    is_neg db 0
    is_not_valid db 0

    option db 2, ?, 2 dup("?")
    continue_msg db 'Do you want to continue? (y/n)',0Dh, 0Ah, '$'
    continue_input db 2, ?, 2 dup("?")


    max_range dw 0
    min_range dw 0

    array_loop_counter dw 0
    array_2d_row_counter_print db 0
    array_2d_column_counter_print db 0

.CODE
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
        je two_dimensional_array

        cmp option+2, '3'
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
            

        
        two_dimensional_array:
            call array_2d_logic
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

    mov dx, offset option_3_msg
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

    mov dx, offset option3_1d_array_msg
    int 21h

    mov dx, offset option4_1d_array_msg
    int 21h

    mov dx, offset option6_1d_array_msg
    int 21h

    mov dx, offset option_msg
    int 21h
    ret

    endp enter_msg_array_1d

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

scan_1d_array proc 
    array_size_loop:
                mov dx, offset enter_1d_array_msg
                mov ah, 09h
                int 21h

                call scan_parse
                cmp is_not_valid, 1
                je array_size_loop

                cmp ax, 1
                jl invalid_size_error


                cmp ax, 10
                jg invalid_size_error
                
                jmp after_size_input
                invalid_size_error:
                    mov dx, offset size_error_msg
                    mov ah, 09h
                    int 21h
                    jmp array_size_loop

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

find_sum_of_array proc
    mov cx, array_size
    mov si, 0
    xor ax, ax
    
        find_sum_loop:
        
            add ax, array[si]
            add si, 2

        loop find_sum_loop

            mov save_num, ax

            mov dx, offset new_line
            mov ah, 09h
            int 21h
            
            mov dx, offset sum_array_smg
            int 21h

            mov ax, save_num
            call parse_print_num
            ret

endp find_sum_of_array

find_biggest_value proc
    mov cx , array_size
    dec cx
    mov si, 0

    mov ax, array[si]
    add si, 2
    array_loop:
        cmp ax, array[si]
        jge skip

        mov ax, array[si]

        skip:
        add si, 2
    loop array_loop
    ret
endp find_biggest_value

find_smallest_value proc
    mov cx , array_size
    dec cx
    mov si, 0

    mov ax, array[si]
    add si, 2
    array_loop_smallest:
        cmp ax, array[si]
        jle skip_smallest

        mov ax, array[si]

        skip_smallest:
        add si, 2
    loop array_loop_smallest
    ret
endp find_smallest_value

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
    je find_biggest_value_jump

    cmp option+2, '3'
    je find_smallest_value_jump

    cmp option+2, '4'
    je sort_1d_array_jump

    cmp option+2, '5'
    je end_1d_array

    
    mov dx, offset error_msg
    mov ah, 09h
    int 21h
    jmp array_1d_logic

    find_sum_of_array_jump:
        call find_sum_of_array
        jmp continue_jump

    find_biggest_value_jump:
        call find_biggest_value
        mov save_num, ax

        mov dx, offset biggest_value_msg
        mov ah, 09h
        int 21h

        mov ax, save_num

        call parse_print_num
        jmp continue_jump

    sort_1d_array_jump:
        call sort_1d_array
        jmp array_1d_logic

    find_smallest_value_jump:
        call find_smallest_value
        mov save_num, ax

        mov dx, offset smallest_value_msg
        mov ah, 09h
        int 21h

        mov ax, save_num

        call parse_print_num
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

sort_1d_array proc 
    cmp array_size, 1
    jle end_sort_func

    mov cx, array_size
    dec cx
    mov sort_outer_counter, 0
    outer_loop:
        mov si, 0
        mov sort_inner_counter, 0
        inner_loop:
            mov ax, array[si]
            mov bx, array[si+2]
            cmp ax, bx
            jl end_inner_loop

            mov array[si], bx
            mov array[si+2], ax

            end_inner_loop:
                add si, 2
                add sort_inner_counter, 1

                cmp sort_inner_counter, cx
                jl inner_loop

        add sort_outer_counter, 1
        cmp sort_outer_counter, cx
        jl outer_loop

    end_sort_func:
    ret
endp sort_1d_array

;2d array functions
scan_2d_array proc 
    array_rows:
        mov min_range, 1
        mov max_range, 5
        mov dx, offset enter_2d_array_rows_msg
        call scan_single_value
    mov matrix_rows, ax
    
    array_columns:
        mov min_range, 1
        mov max_range, 5
        mov dx, offset enter_2d_array_columns_msg
        call scan_single_value

    mov matrix_columns, ax
    mov ax, matrix_rows
    mul matrix_columns

    mov array_size, ax

    after_size_input_2d:
            mov array_size, ax
            mov cx, ax

            mov array_loop_counter, 0
            mov si, 0
            mov si_counter, 0

            mov ah, 09h
            mov dx, offset pre_input_1d_array_msg
            int 21h

            array_input_loop_2d:
                mov dx, offset new_line
                mov ah, 09h
                int 21h

                mov dx, offset input_1d_array_msg
                mov ah, 09h
                int 21h
                
                mov dl, '['
                mov ah, 02h
                int 21h

                mov ax, array_loop_counter
                mov bx, matrix_columns

                xor dx, dx
                div bx

                mov array_2d_row_counter_print, al
                mov array_2d_column_counter_print, dl

                mov dl, array_2d_row_counter_print
                add dl, '0'
                mov ah, 02h
                int 21h

                mov dl, ']'
                int 21h

                mov dl, '['
                int 21h

                mov dl, array_2d_column_counter_print
                add dl, '0'
                mov ah, 02h
                int 21h

                mov dl, ']'
                int 21h

                mov dl, ':'
                int 21h

                mov array_counter, cx
                call scan_parse
                mov cx, array_counter

                cmp is_not_valid, 1
                je array_input_loop_2d

                mov si, si_counter
                mov array[si], ax

                add si_counter, 2
                add array_loop_counter, 1
            loop array_input_loop_2d
    ret
endp scan_2d_array

print_2d_array proc
    mov si, 0
    mov cx, array_size

    mov dx, offset new_line
    mov ah, 09h
    int 21h

    mov array_loop_counter, 0

    print_2d_loop:
        new_line_checker:
        mov dx, 0
        mov ax, array_loop_counter
        div matrix_columns

        cmp dx, 0
        jne continue_print_2d_loop
        
        mov dx, offset new_line
        mov ah, 09h
        int 21h

        continue_print_2d_loop:
            mov ax, array[si]
            mov array_counter, cx
            call parse_print_num
            mov cx, array_counter
            
            mov dl, ' '
            mov ah, 02h
            int 21h

            mov dl, ' '
            mov ah, 02h
            int 21h

        add array_loop_counter, 1
        add si,2
    loop print_2d_loop

    mov dx, offset new_line
    mov ah, 09h 
    int 21h
    ret
endp print_2d_array
array_2d_logic proc 
    cmp is_array_input, 1
    je after_input_2d

    call scan_2d_array
    mov is_array_input, 1

    after_input_2d:

    mov ax, 0003h
    int 10h  
    
    mov dx, offset horizontal_lines
    mov ah, 09h
    int 21h

    call print_2d_array

    mov dx, offset horizontal_lines
    mov ah, 09h
    int 21h
    
    call enter_msg_array_2d

    mov dx, offset option_msg
    mov ah, 09h
    int 21h

    mov dx, offset option
    mov ah, 0Ah
    int 21h

    cmp option+2, '1'
    je find_coordinates_for_value
    
    cmp option+2, '2'
    je return_to_main_jump

    mov dx, offset error_msg
    mov ah, 09h
    int 21h
    jmp array_2d_logic

    continue_jump_2d:
    mov dx, offset continue_msg_array
    mov ah, 09h
    int 21h

    mov ah, 08h
    int 21h
    jmp array_2d_logic
    
    find_coordinates_for_value:
        call find_coordinates_2d
        jmp continue_jump_2d

    return_to_main_jump:
        mov is_array_input, 0
        ret
endp array_2d_logic

enter_msg_array_2d proc

    mov dx, offset new_line
    mov ah, 09h
    int 21h

    mov dx, offset option1_2d_array_msg
    int 21h

    mov dx, offset option2_2d_array_msg
    int 21h 
ret
endp enter_msg_array_2d

find_coordinates_2d proc
    mov min_range, -999
    mov max_range, 999

    mov dx, offset find_coordinates_2d_msg
    call scan_single_value

    push ax

    mov dx, offset new_line
    mov ah, 09h
    int 21h

    mov dx, offset coordinates_value_msg
    mov ah, 09h
    int 21h

    pop ax

    mov cx, array_size
    mov array_loop_counter, 0
    mov si, 0


    find_coordinates_loop:
        cmp array[si], ax
        je print_coordinates
        jne end_find_coordinates_loop

        print_coordinates:
            push ax

            mov dl, ' '
            mov ah, 02h
            int 21h

            mov dl, '['
            mov ah, 02h
            int 21h

            mov ax, array_loop_counter
            mov bx, matrix_columns

            xor dx, dx
            div bx

            mov array_2d_row_counter_print, al
            mov array_2d_column_counter_print, dl

            mov dl, array_2d_row_counter_print
            add dl, '0'
            mov ah, 02h
            int 21h

            mov dl, ']'
            int 21h

            mov dl, '['
            int 21h

            mov dl, array_2d_column_counter_print
            add dl, '0'
            mov ah, 02h
            int 21h

            mov dl, ']'
            int 21h

            pop ax

    end_find_coordinates_loop:
        add array_loop_counter, 1
        add si, 2
        loop find_coordinates_loop   
ret
endp find_coordinates_2d

;Additional functions
; dx - string
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
END START