;64-bit "Arithmetic" in Linux NASM
%include "Macros_CPsub64.inc"
%include "CPsub64.inc"

global  main                  ; global entry point export for ld

section .text
main:

;Get operand1
    call   opRetrieve
    cmp    r8, 1h
    je     myExit
    cmp    r8, 2h
    je     ErrorOperand
    mov    [operand1], rax    ;[operand1] is the effective memory location



;get operater
    mov    rdx, promptop2msg
    call   WriteString
    call   Crlf

    mov    rdx, ipbuffer      ;Get a string from the console
    mov    rcx, ipbuflen
    call   ReadString

    mov    rdx, [ipbuffer]    ;limits to the first 8 bytes of ipbuffer
    mov    [operator], dl     ;Move just the low order bits of rdx/ rdx > edx > dx=dh & dl 



;get operand2
    call   opRetrieve
    cmp    r8, 1h
    je     myExit
    cmp    r8, 2h
    je     ErrorOperand
    mov    [operand2], rax    ;[operand1] is the effective memory location



;Determine which calc
    mov    dl, [operator]
    cmp    dl, '+'
    je     Addition

    cmp    dl, '-'
    je     Subtraction

    cmp    dl, '*'
    je     Multiplication

    cmp    dl, '/'
    je     Division

    jmp    ErrorOperator



;Calculations
Addition:
    mov    rax, [operand1]
    add    rax, [operand2]

    mov    [result], rax

    jmp    Result

Subtraction:
    mov    rax, [operand1]
    sub    rax, [operand2]

    mov    [result], rax

    jmp    Result

Multiplication:
    mov    eax, [operand1]
    xor    rdx, rdx                         ;Keeps the register clean for placing the result
    imul   DWORD [operand2]                 ;mul/imul always works on the rax register as the first operand

    mov    [result], eax                    ;High order bits
    mov    [result + 4], edx                ;Low order bits

    jmp    Result

Division:
    mov    eax, DWORD [operand1]
    mov    edx, DWORD [operand1 + 4]
    idiv   DWORD [operand2]

    movsx  rax, eax                         ;The division leaves a signed DWORD that needs to be
    movsx  rdx, edx                         ;upscaled to a QWORD with no sign change

    mov    [result], rax
    mov    [remainder], rdx

    jmp    Result



;Show Result and Remainder
Result:
    mov    rdx, resultmsg
    call   WriteString
    call   Crlf

    mov    rax, [result]
    call   WriteInt
    call   Crlf

    mov    rax, [remainder] 
    cmp    rax, 0h
    jne    Remainder

    jmp    main

Remainder:
    mov    rdx, remaindermsg
    call   WriteString
    call   Crlf
    
    call   WriteInt
    call   Crlf
   
    xor    rax, rax
    mov    [remainder], rax
 
    jmp    main


opRetrieve:
    xor    r8, r8

    mov    rdx, promptopmsg   ;Write out prompt msg
    call   WriteString
    call   Crlf

    mov    rdx, ipbuffer      ;Get a string from the console
    mov    rcx, ipbuflen
    call   ReadString

;Compare the operand to the quit character
    mov    rax, [ipbuffer]    ;Convert the string to integer
    cmp    al, 'q'
    je     opRetErr

;Convert to an integer
    mov    rdx, ipbuffer      ;Convert the string to integer
    mov    rcx, rax
    call   ParseInteger64

    cmp    rax, 0
    je     opParseErr

    ret

opRetErr:
    mov    r8, 1h
    ret

opParseErr:
    mov    r8, 2h
    ret



;Error handling
ErrorOperand:
    mov    rdx, error2msg
    call   WriteString
    call   Crlf

    jmp    main

ErrorOperator:
    mov    rdx, errormsg
    call   WriteString
    call   Crlf

    jmp    main



    ;Debugging Code
;    call   DumpRegs         ;Look at all registers
;    mov    rsi, ipbuffer    ;Replace ipbuffer with data to check
;    mov    rbx, 2
;    call   DumpMem

myExit:
    Exit                   ;exit the program


section .data
;Messages
promptopmsg  db   'Input a operand or q to exit: ', 00h
promptop2msg db   'Input a operater: ', 00h
errormsg     db   'Invalid operater.', 00h
error2msg    db   'Operand input is invalid.', 00h
resultmsg    db   'Result is: ', 00h
remaindermsg db   'Remainder is: ', 00h

;Stored Data
operand1     dq 0h ;Place to store the value until used
operand2     dq 0h
operator     db 0h ;Arithmetic operator
result       dq 0h ;Used to keep results for writing
remainder    dq 0h

;Buffer
ipbuffer     times   255 db ' '
ipbuflen     equ     $-ipbuffer
