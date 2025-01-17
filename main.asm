PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
VIAIRQ = $600E
VIAAUX = $600B
VIACONT = $600C

E  = %10000000
RW = %01000000
RS = %00100000
DISPLAYMASK =  %11100000

SETMODE   = %00111000
DISPLAYON = %00001111
CLEAR     = %00000001
	.org $8000
reset:
	sei ;disable interrupts
	ldx #$ff
	txs ; setup stack
	lda #$ff 
	sta DDRB ;set output mode on PORTB
	lda #$ff 
	sta DDRA ;set output mode on PORTA
	lda #%11001100
	sta VIACONT ;set controll reg
	lda #%00000000
	sta VIAAUX ;set aux controll reg
	lda #%10000000
	sta VIAIRQ ;disable all irq
	cli
	jsr lcdinit

main:
	jsr lcdClear
	ldx #$0
loop$
	lda data,x
	cmp #'\0'
	beq end$
	jsr senddata
	jsr waitBusy
	inx
	jmp loop$
end$
	lda #0
	jmp end

end:
	cmp #0
	beq good$
good$
	lda #%00000001
	jmp endif$
bad$
	lda #%00000010
endif$
	sta PORTA
:	jmp :-

sendinst:
	pha
	phx
	sta PORTB
	lda PORTA
	and #^DISPLAYMASK
	tax
	stx PORTA
	ora #E
	sta PORTA
	stx PORTA
	plx
	pla
	rts

senddata:
	pha
	phx
	sta PORTB
	lda PORTA
	and #^DISPLAYMASK
	ora #RS
	tax
	sta PORTA
	ora #E
	sta PORTA
	txa
	sta PORTA
	plx
	pla
	rts

waitBusy:
	pha
	phx
	lda #%00000000  ; Port B is input
	sta DDRB
	lda PORTA
	and #^DISPLAYMASK
	ora #RW
	tax ;storeing the non tick state of port a in x
lcdbusy:
	stx PORTA
	txa  ;looping can make a other data so this is necessary
	ora #E
	sta PORTA
	lda PORTB
	and #%10000000
	bne lcdbusy ;loop until busy bit not set
	
	stx PORTA 
	lda #%11111111  ; Port B is output
	sta DDRB
	plx
	pla
	rts

lcdinit:
	pha
	lda #SETMODE ;set display data length, line number, font size
	jsr sendinst
	lda #255
	jsr sleep ; BF can't be checked before this instruction
	lda #SETMODE ;the doc whant it twice
	jsr sendinst
	lda #255
	jsr sleep ; BF can't be checked before this instruction

	lda #DISPLAYON ; Display on; cursor on; blink off
	jsr sendinst
	lda #255
	jsr sleep ; BF can't be checked before this instruction


	lda #CLEAR ; Clear display
	jsr sendinst
	jsr waitBusy
	
	lda #%00000110 ; Increment and shift cursor; don't shift display
	jsr sendinst
	jsr waitBusy

	lda #%00011100 ;Set cursor moving and display shift
	jsr sendinst
	jsr waitBusy

	pla
	rts

lcdClear:
	pha
	lda #CLEAR ; Clear display
	jsr sendinst
	jsr waitBusy
	pla
	rts

sleep:
	sbc #1
	cmp #0
	bne sleep
	rts

longsleep:
	pha
	lda #$ff
	jsr sleep
	pla
	sbc #1
	cmp #0
	bne longsleep
	rts
	

irq:
	rti ;if interrupt happen return from it

data:
	.ascii "2025_01_09\0"
vactors:
	.org $fffc
	.word reset ;reset vector
	.org $fffe
	.word irq ;IRQ vector
