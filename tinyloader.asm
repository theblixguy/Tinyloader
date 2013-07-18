; tinyloader.asm
;
; ------------------------------------------------------
; This bootloader operates in real addressing mode, which 
; is also known as 16-bit. It's a really simply bootloader 
; and outputs a message in the end.
; ------------------------------------------------------
;
; Author: Suyash Srijan
; suyashsrijan@outlook.com
;

bits 16 ; 16 because this bootloader operates in 16-bit
org 0x7C00 ; Tell the assembler to load the bootloader at address 0x7C00 

    jmp main ; Jump to entry point, known as main() 

msgHi db "Hi!", 0x0 ; Say Hi to the user
msg db "You're now in real mode :) ", 0x0 ; Tell him we are in 16-bit mode

; This will print characters on the fucking screen 
printaline:
    lodsb ; Load the damn string 
    cmp al, 0 ; Compare al with 0 
    jz done ; Get the fuck out if zero
    mov ah, 0x0e ; Not zero so lets tell the BIOS that we want to put a char on the fucking screen
    int 10h  ; BIOS interrupt call
    jmp printaline ; Do I really need to tell you what this does?
	               ; Hint: The answer starts with l and ends with p. If you said loop then you win a gold star!   	
    done:
    call printanewline ; Call printanewline() to print a new line

; This will hang your fucking machine 
hangmachine:
    cli ; Disable interrupts
    hlt ; Halt the CPU
    jmp hangmachine ; Loop, just in case a Non-Maskable Interrupt wakes up the processor

; Bootloader's entry point
main:
   cli ; Disable the fucking interrupts
   mov ax,cs ; Copy the value of cs register to ax register         
   mov ds,ax ; Copy the value of ax register to ds register
   mov es,ax ; Copy the value of ax register to es register              
   mov ss,ax ; Copy the value of ax register to ss register               
   sti ; Enable the fucking interrupts 
   mov si, msgHi ; Copy the Hello message to source index register
   call printaline ; Call printaline() to print the Hello Message
   mov si, msg ; Copy the 16-bit mode message to source index register 
   call printaline ; Call printaline() to print the 16-bit mode message

   call hangmachine ; Call hangmachine to halt

   times 510 - ($-$$) db 0 ; Since the bootloader should be 512 bytes in size, we fill the rest of the memory with fucking zeroes ($ - $$ = length of our code)
   dw 0xAA55 ; Tell the BIOS that this is a valid bootloader by setting the word AA55h at offset 510h