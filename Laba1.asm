STSEG SEGMENT PARA STACK "STACK" ; Виділення пам'яті в стекові
    DB 64
STSEG ends 

DSEG SEGMENT PARA PUBLIC "DATA" ; Створення змінних
    SOURCE DB 10, 20, 30, 40
    DEST DB 4 DUP("?")
DSEG ends

CSEG SEGMENT PARA PUBLIC "CODE"
    MAIN PROC FAR
        ASSUME CS: CSEG, DS: DSEG, SS: STSEG
        PUSH DS
        MOV AX, 0
        PUSH AX
        MOV AX, DSEG
        MOV DS, AX

        MOV DEST, 0
        MOV DEST+1, 0
        MOV DEST+2, 0
        MOV DEST+3, 0

        MOV AL, SOURCE +3
        MOV DEST, AL

        MOV AL, SOURCE +2
        MOV DEST + 1, AL

        MOV AL, SOURCE +1
        MOV DEST + 2, AL

        MOV AL, SOURCE
        MOV DEST + 3, AL
    RET 
    MAIN ENDP
CSEG ends
END MAIN