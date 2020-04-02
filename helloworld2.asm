;64-bit "Hello World!2" in Linux NASM
%include "Macros_CPsub64.inc"
%include "CPsub64.inc"

global  main               ; global entry point export for ld

section .text
main:
  
    mov    rdx, message    ;address the message
    call   WriteString     ;pre built method for writing to console
    Exit                   ;exit the program

section .data
message: db   0Dh,0Ah,'Hello, World!',0Dh,0Ah,0Dh,0Ah,'Good Bye World',0Dh,0Ah,0Dh,0Ah,'That',27h,'s All Folks',0Dh,0Ah,0Dh,0Ah,00h   ; message 
