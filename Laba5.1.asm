.MODEL SMALL
.STACK 5h
.DATA

    start_msg db 'This program will multiply your number by 4',0Dh, 0Ah, '$'
    number_msg db 'Enter the number[-9999;9999]:$'
    enterData db 6, ?, 6 dup("?")
    result_msg db 0Dh, 0Ah,'Your number = $'
    new_line db 0Dh, 0Ah, '$'
    continue_msg db 'Do you want to continue? (y/n)',0Dh, 0Ah, '$'
    error_msg db 0Dh, 0Ah,'Error: invalid input',0Dh, 0Ah, '$'
    out_of_range_error_msg db 0Dh, 0Ah,'Error: out of range',0Dh, 0Ah, '$'

    continue_input db 2, ?, 2 dup("?")
    number dw 0
    
    is_not_valid db 0
    is_neg db 0

.CODE
    print_number_macro Macro a, is_neg_int
        LOCAL convert, convert_loop, print_loop, end_print
        mov ax, a
        cmp ax,0
        jne convert

        mov ah, 02h
        mov dl, '0'
        int 21h

        jmp end_print

        convert:
            mov cx,0
            mov bx, 10  

            convert_loop:
                xor dx, dx
                div bx
                add dl, '0'
                push dx
                inc cx
                cmp ax, 0
                jne convert_loop
                
            cmp is_neg_int, 1
            jne print_loop
            
            mov ah, 02h
            mov dl, '-'
            int 21h

            print_loop:
                pop dx
                mov ah, 02h
                int 21h
            loop print_loop
        end_print:

    mov dx, offset new_line
    mov ah, 09h
    int 21h
    endm
START:
    MOV ax, @DATA
    MOV ds, ax

    mov ah, 9
    mov dx, offset start_msg
    int 21h

    program_loop:
    mov number, 0
    mov is_neg, 0
    mov is_not_valid, 0

    call scan_parse

    cmp is_not_valid, 1
    je is_continue
    
    mov ah, 9
    mov dx, offset result_msg
    int 21h

    mov ax, number
    mov bx, 4
    mul bx

    print_number_macro ax, is_neg


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

            cmp enterData+1, 4
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
            add number, ax
            mov ax, bx
            mov bx, 10
            mul bx
            mov bx, ax
            dec si
        loop parse_loop

        end_scan_parse:
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