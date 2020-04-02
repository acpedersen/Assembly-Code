;64-bit "CmdArgs" in Linux NASM
%include "Macros_CPsub64.inc"
%include "CPsub64.inc"

global  main               ; global entry point export for ld

section .text
main:

    ;Compare arguments
    cmp    rdi, 02h
    jl     noArgs          ;If less than 2

    ;Write a message and write the argument count 
    mov    rdx, countmsg
    call   WriteString

    mov    rax, rdi
    call   WriteInt
    call   Crlf

    ;Write out message for args    
    call   Crlf
    mov    rdx, parammsg
    call   WriteString
    call   Crlf

    mov    r10, rsi
    mov    r9, rdi
    xor    r8, r8          ;index register

argJmp:
    mov    rdx, [r10+r8]      ;Calculate effective address
    call   WriteString
    call   StrLength          ;input rdx, outputs to rax

    mov    rdx, spacemsg
    call   WriteString        ;takes rdx
    call   WriteInt           ;takes rax register
    call   Crlf
 
    ;end condition code
    add    r8, 8
    dec    r9

    jnz    argJmp
    jmp    myExit

    ;Write out message for no args
noArgs:
    mov    rdx, infomsg
    call   WriteString
    call   Crlf
    jmp    myExit



myExit:
    Exit                   ;exit the program

section .data
countmsg db  'The count of cmdline arguments is ',00h   ;message and null
parammsg db  'Arguments:',00h
infomsg  db  'There are no arguments to read.',00h             ;end message and null
spacemsg db  ' ',00h
