;64-bit "CmdArgs" in Linux NASM
%include "Macros_CPsub64.inc"
%include "CPsub64.inc"

global  main               ; global entry point export for ld

section .text
main:

    ;Test arguments for exactly 2
    cmp    rdi, 03h
    jne    invArgs         ;If args are not 3

    ;get addresses
    mov    rdx, [rsi+8]
    mov    rcx, ipfile
    call   getAddress
    mov    rdx, [rsi+16]
    mov    rcx, opfile
    call   getAddress
    
    ;Open the files
 ;ipfile
    mov    rdi, ipfile
    mov    rsi, 0h
    mov    rdx, 0h

    ;Open the file
    call   FileOpen        ;reserve the file

    ;Jump if the file does not exist
    cmp    rax, 0h
    jl     noFile
    
    mov    [ipfilehandle], rax  ;Set the file handle

 ;opfile
    mov    rdi, opfile
    mov    rsi, 0102o      ;set to write
    mov    rdx, 0755o      ;set access permissions

    ;Open the file
    call   FileOpen        ;reserve the file
    
    mov    [opfilehandle], rax  ;Set the file handle


    jmp   recordRead



;Function to get repeat files
getAddress:;Takes rdx and rcx registers
    call   StrLength       ;Find the length of arg2

    ;Move the exact character length from arg2 to myfile
    mov    r8, rdx         ;Source address for move
    mov    r9, rcx         ;Target address for move
    mov    r10, rax        ;Source length
    call   Mvcl            ;Move the characters of length

    mov    byte [r9+r10], 0h ;move NULL over CR

    ret



recordRead:
    ;Clear the buffer for subsequent lengths
    mov    rax, ipbuffer
    mov    rcx, ipbuflen
    call   ClearBuffer

    mov    rdi, [ipfilehandle]
    mov    rdx, ipbuffer
    call   FileRead
   
    ;See if end of file
    cmp    rax, 0
    je     endFile

    mov    [reclen], rax       ;capture record length

    ;Write line record
    mov    rdx, ipbuffer
    call   WriteString
    call   Crlf

    ;Copy to the opfile
    mov    r8, ipbuffer        ;Address of buffer
    add    r8, [reclen]        ;Plus reclen
    dec    r8                  ;Minus 1
    mov    byte [r8], 0Ah       ;Place LF character


    mov    rdi, [opfilehandle] ;tell OS of file handle
    mov    rdx, ipbuffer       ;address buffer
    mov    rcx, [reclen]
    call   FileWrite           ;go write output record

    jmp    recordRead



endFile:
    mov    rdx, endfilemsg
    call   WriteString
    call   Crlf

    ;Close the file based on the handle
    mov    rdi, [ipfilehandle]
    call   FileClose

    mov    rdi, [opfilehandle]
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

ipfile          times 255 db 00h                               ;Name of File
ipfilehandle    dq  0h                                         ;File handle
opfile          times 255 db 00h                               ;Name of File
opfilehandle    dq  0h                                         ;File handle

ipbuffer       times 255 db 00h
ipbuflen       equ $-ipbuffer

reclen         dq   0h
