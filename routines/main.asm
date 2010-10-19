	.include "routines/h/main.h"


.Section "Main Code"
HiromStart:
	sep #$20
	lda #RAM
	pha
	plb
	rep #$31
	lda.w #ZP
	tcd

	lda.w #STACK
	tcs

	jsr ClearRegisters

	sep #$20
	lda.b #0		;clear zero page
	ldy.w #kernelEnd-kernelStart
	ldx.w #ZP
	jsr ClearWRAM

	lda.b #0		;clear variable buffer
	ldy.w #VARS_end-VARS
	ldx.w #VARS
	jsr ClearWRAM
	jsr NmiInit
	jsr OopHandlerInit
	
	rep #$31
	NEW Script.CLS.PTR oopCreateNoPtr bootstrap.PTR
/*
	NEW Nmi.CLS.PTR oopCreateNoPtr
	NEW Rng.CLS.PTR $fff0	
	NEW Sa1Iface.CLS.PTR oopCreateNoPtr
	NEW Spc.CLS.PTR $fff4
	NEW Demo.CLS.PTR oopCreateNoPtr

	CALL Rng.RngKill.PTR $fff0
	CALL Spc.playSong.PTR $fff4 rez_bubbletoast2.PTR
*/	
;	cli	;and off we go...
	;brk 0
;main loop starts here:
CheckNextFrame:
	lda.w FrameCounter	;load current frame counter
	cmp.w LastFrame	;load last frame processed
	beq CheckNextFrame	;check until one frame advances
	sta.w LastFrame

	jsr OopHandler

	sep #$20
;	inc.w FixedColourB
	lda #$80
	sta.l $004201
	nop
	nop
	nop
	nop
	lda.l $002137
	lda.l $00213f			;reset $213d to low byte
	lda.l $00213d			;get current scanline
	sta.w CpuUsageScanline
	rep #$31
	bra CheckNextFrame


;empty routine
SubVoid:
	rts
.ends





.bank 0 slot 0
.org $7fc0
.section "sa1 memmap header hack" force
.db "BRKPOINT10           "
.db $23	;sa1 custom map
.db $34
.db $a	;rom
.db 6	;ram
.db 2
.db $33
.db 0
.ends

.bank 0 slot 0
.org $7fdc
.section "sa1 memmap header hack chsum" force
.dw 0
.dw $ffff
.ends



.bank 0 slot 0
.org $7fe4
;wla dx is unable to calculate the cpu vectors correctly, so this gruesome hack has to do
.section "native vector hack" force
.dw StopCop+LOROMOFFSET
.dw Stop+LOROMOFFSET
.dw EmptyHandler+LOROMOFFSET
.dw NmiHandler+LOROMOFFSET
.dw EmptyHandler+LOROMOFFSET
.dw IrqHookUp+LOROMOFFSET
.ends

.org $7ff4
.section "emu vector hack" force
.dw StopCop+LOROMOFFSET
.dw EmptyHandler+LOROMOFFSET
.dw EmptyHandler+LOROMOFFSET
.dw EmptyHandler+LOROMOFFSET
.dw Boot+LOROMOFFSET
.dw EmptyHandler+LOROMOFFSET
.ends

.bank 0 slot 0
.org 0
.section "IRQ Bootstrap" force

NmiHandler:
	jml NMI

EmptyHandler:
	rti

Stop:
	jml StopJmp
StopJmp:
	rep #$31
	pea E_Brk
	jsr PrintException
	stp

StopCop:
	jml StopCopJmp
StopCopJmp:
	rep #$31
	pea E_Cop
	jsr PrintException
	stp

Boot:
	SEI
	CLC
	XCE
	PHK
	PLB
	SEP #$20
	STZ $4200		;reg $4200  - disable timers, NMI,and auto-joyread
	lda #%00000001
	sta $420d		;set memory mode to fastrom
	jml HiromStart 		;lorom

IrqHookUp:
	jml IrqLoader
.ends




















