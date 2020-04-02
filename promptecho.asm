;64-bit "PromptEcho" in Linux NASM
%include "Macros_CPsub64.inc"
%include "CPsub64.inc"

global  main               ; global entry point export for ld

section .text
main:
  
    mov    rdx, promptmsg  ;address the message
    call   WriteString     ;pre built method for writing to console
    call   Crlf            ;line feed
    

    ;Read from keyboard
    mov    rdx, ipbuffer
    mov    rcx, ipbuflen
    call   ReadString
    
    mov    rdx, endmsg     ;Writes out endmsg and ipbuffer
    call   WriteString
    mov    rdx, ipbuffer
    call   WriteString
    call   Crlf

    Exit                   ;exit the program

section .data
promptmsg:  db     'Enter Data: ',00h   ; message
endmsg:     db     'Data: ',00h
ipbuffer:   times  255 db " "	       ;input buffer
ipbuflen:   equ    $-ipbuffer
