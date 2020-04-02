;64-bit "CmdArgs" in Linux NASM
%include "Macros_CPsub64.inc"
%include "CPsub64.inc"

global  main               ; global entry point export for ld

section .text
main:

    ;Test arguments for exactly 2
    cmp    rdi, 02h
    jne    invArgs         ;If args are not 2


getFile:
    mov    rdx, [rsi+8]
    call   StrLength       ;Find the length of arg2

    ;Move the exact character length from arg2 to myfile
    mov    r8, [rsi+8]    ;Source address for move
    mov    r9, myfile      ;Target address for move
    mov    r10, rax        ;Source length
    call   Mvcl            ;Move the characters of length

    mov    byte [r9+r10], 0h ;move NULL over CR

    ;Open the file
    mov    rsi, 0          ;set to read-only
    mov    rdi, myfile     ;set the address to open
    call   FileOpen        ;reserve the file

    ;Jump if the file does not exist
    cmp    rax, 0h
    jl     noFile

    mov    [myfilehandle], rax  ;Set the file handle


recordRead:
    ;Clear the buffer for subsequent lengths
    mov    rax, ipbuffer
    mov    rcx, ipbuflen
    call   ClearBuffer

    mov    rdi, [myfilehandle]
    mov    rdx, ipbuffer
    call   FileRead
   
    ;See if end of file
    cmp    rax, 0
    je     endFile

    ;Write line record
    mov    rdx, ipbuffer
    call   WriteString
    call   Crlf

    jmp    recordRead



endFile:
    mov    rdx, endfilemsg
    call   WriteString
    call   Crlf

;Close the file based on the handle
    mov    rdi, [myfilehandle]
    call   FileClose

    jmp myExit



;Write out message for no args
invArgs:
    mov    rdx, invargmsg
    call   WriteString
    call   Crlf
    jmp    myExit

noFile:
    mov    rdx, nofilemsg
    call   WriteString
    call   Crlf
    jmp    myExit



myExit:
    Exit                   ;exit the program

section .data
endfilemsg     db  'End of file detected',00h
invargmsg      db  'Invalid number of args detected.',00h     ;invalid args message and null
nofilemsg      db  'File does not exist.',00h                 ;No file found  message and null
spacemsg       db  ' ',00h

myfile         times 255 db 00h                               ;Name of File
myfilehandle   dq  0h                                         ;File handle

ipbuffer       times 255 db 00h
ipbuflen       equ $-ipbuffer
