PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

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
	jsr lcdinit



main:
	ldx #$0
loop$
	lda data,x
	bne end$
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
	sta PORTB
	lda #0
	sta PORTA
	lda #E
	sta PORTA
	lda #0
	sta PORTA
	rts

senddata:
	sta PORTB
	lda #RS
	sta PORTA
	lda #(E | RS)
	sta PORTA
	lda #RS
	sta PORTA
	rts

waitBusy:
	pha
	lda #%00000000  ; Port B is input
	sta DDRB
lcdbusy:
	lda #RW
	sta PORTA
	lda #(RW | E)
	sta PORTA
	lda PORTB
	and #%10000000
	bne lcdbusy
	
	lda #RW
	sta PORTA
	lda #%11111111  ; Port B is output
	sta DDRB
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
print:


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
	.ascii "hello\n"
vactors:
	.org $fffc
	.word reset ;reset vector
	.org $fffe
	.word irq ;IRQ vector
