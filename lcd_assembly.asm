Org 0000h
RS Equ P1.3
E Equ P1.2
; R/W* is hardwired to 0V, therefore it is always in write mode
; ---------------------------------- Main -------------------------------------
Clr RS ; RS=0 - Instruction register is selected.
; Stores instruction codes, e.g., clear display...
; Function set
Call FuncSet
; Display on/off control
Call DispCon
; Entry mode set (4-bit mode)
Call EntryMode
; Send data
SetB RS ; RS=1 - Data register is selected.
; Send data to data register to be displayed.
Back:
Clr A
Next:
Mov DPTR, #LUT1
Movc A, @A+DPTR
Jz Next
Call SendChar
Inc DPTR
Jmp Back
Call CursorPos SetB RS ; Put cursor onto the next line
; RS=1 - Data register is selected.
Again:
Clr A
Mov DPTR, #LUT2
Movc A, @A+DPTR
Jz EndHere
Call SendChar
Inc DPTR
Jmp Again
EndHere:
Jmp $
; -------------------------------- Subroutines --------------------------------
; ------------------------- Function set --------------------------------------
FuncSet:
Clr P1.7
Clr P1.6
SetB P1.5 ; bit 5=1
Clr P1.4 Call Pulse
Call Delay
Call Pulse
; (DB4) DL=0 - puts LCD module into 4-bit mode
; wait for BF to clear
SetB P1.7
Clr P1.6
Clr P1.5
Clr P1.4 Call Pulse
Call Delay
Ret
; P1.7=1 (N) - 2 lines
; --------------------- Display on/off control -------------------------------
DispCon:
Clr P1.7
Clr P1.6
Clr P1.5
Clr P1.4 Call Pulse
; high nibble set (0H - hex)
SetB P1.7
SetB P1.6
SetB P1.5 ; Cursor ON
SetB P1.4
Call Pulse
; Sets entire display ON, Cursor blinking ON
Call Delay
Ret
; ---------------------------- Cursor position --------------------------------
CursorPos:
Clr RS
; wait for BF to clear
SetB P1.7
SetB P1.6
Clr P1.5
; Sets the DDRAM address
; Address starts here - 40H
Clr P1.4 ; high nibble
Call Pulse
Clr P1.7
Clr P1.6
Clr P1.5
Clr P1.4 ; low nibble
Call Pulse
Call Delay ; wait for BF to clear
Ret
; ------------------ Entry mode set (4-bit mode) ------------------------------
EntryMode:
Clr P1.7
Clr P1.6
Clr P1.5
Clr P1.4
Call Pulse
Clr P1.7
SetB P1.6
SetB P1.5
Clr P1.4 ; '0110'
Call Pulse
Call Delay Ret
; wait for BF to clear
; ------------------------------- Pulse ---------------------------------------
Pulse:
SetB E ; P1.2 is connected to 'E' pin of LCD module
; negative edge on E
Clr E
Ret
; ---------------------------- Send character ---------------------------------
SendChar:
Mov C, ACC.7
Mov P1.7, C
Mov C, ACC.6
Mov P1.6, C
Mov C, ACC.5
Mov P1.5, C
Mov C, ACC.4
Mov P1.4, C Call Pulse
; high nibble
Mov C, ACC.3
Mov P1.7, C
Mov C, ACC.2
Mov P1.6, C
Mov C, ACC.1
Mov P1.5, C
Mov C, ACC.0
Mov P1.4, C Call Pulse
Call Delay Mov R1, #55h
Ret
; low nibble
; wait for BF to clear
; ------------------------------- Delay ---------------------------------------
Delay:
Mov R0, #50
Djnz R0, $
Ret
; ------------------------- Look-Up Table (LUT) -------------------------------
Org 0200h
LUT1:
LUT2:
DB 'N', 'O', 'T', 'I', 'C', 'E', ' ', 'B', 'O', 'A', 'R', 'D', 0
DB 'P', 'B', 'L', ' ', 'P', 'R', 'O', 'J', 'E', 'C', 'T', 0
; -----------------------------------------------------------------------------
Stop:
Jmp $
End