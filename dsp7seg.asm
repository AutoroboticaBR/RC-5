;******************************************************************
;* Programa para teste e uso de displays 7 segmentos no PIC 16F84A
;* dsp7seg.ASM
;* Marcio Soares - 01/09/2003
;******************************************************************
;
;Controla 2 displays diretamente: Displays ligados a porta B, 
;controle dos displays na porta A (catodos) 
;
;
;Freqüência de operacao 4MHz
;
;*******************************************************************
;últimas alterações
;
;01/09/2003 - inserido contador através da INT em RB0
;17/09/2003 - alterado rotinas de temporização p/ maior precisão

	list	p=16F84
	list	n=0
	include <P16F84A.INC>
	__CONFIG _CP_OFF & _PWRTE_OFF &  _WDT_OFF & _XT_OSC  ;configura bits
		

;*****************************************************************
; Diretrizes de pré-compilação

#DEFINE	bank1	bsf     STATUS,RP0      ;seleciona banco 1
#DEFINE bank0	bcf	STATUS,RP0	;volta para banco 0

;*****************************************************************
; Constantes

PICRES	equ	0x00		;vetor de reset
PICINT	equ	0x04		;vector de interrupção
PICRAM	equ	0x20		;vector de ram

DISPLAY equ	0x06		;display na porta B
C_DSP	equ	0x05		;controle do display na porta A

DISP1   equ	0x01		;pino 17, bit 1 porta A
DISP2   equ	0x00		;pino 18, bit 0 porta A

BEEP	equ	0x02		;pino 1, bit 2 porta A

	org	PICRAM		;inicio da RAM

W2	res	1		;backup para W
STATUS2 res	1		;backup para STATUS
PCLATH2	res	1		;backup para PCLATH

VAR1	res	1		;guarda dado do primeiro display
VAR2	res	1		;guarda dado do segundo display
VAR_AUX res	1		;variável auxiliar p/ conversão

SEG	res	1		;variável p/ segundos
MIN	res	1		;variável p/ minutos

T1	res	1		;variável para temporizador
T2	res	1		;variável para temporizador
T3	res	1		;variável para temporizador
T4	res	1		;variável para temporizador

BZZ1	res	1		;variável auxiliar 1 p/ buzzer
BZZ2	res	1		;variável auxiliar 2 p/ buzzer

;*****************************************************************
; Reset e vetor de int

	org 	PICRES
	goto	config_pic

	org	PICINT
	goto	IntVector

;****************************************************************
; configura pic

config_pic:
	
	bank1	
	movlw	0x00
	movwf	TRISA		;PORTA eh saida

	movlw	0x01		;PORTB 0 é entrada
	movwf	TRISB		;PORTB 1 a 7 é saída	
	bank0

	bsf	INTCON,INTE	;Habilita int em RB0

	bank1	
	bsf	OPTION_REG,INTEDG ;interrupçao na transiçao 1->0
	bank0

	bsf	INTCON,GIE	;habilita interrupçoes (Global)

;****************************************************************
; programa principal
	
inicio:
	
	movlw	0x00
	movwf	DISPLAY		;limpa display

	movlw	0x00		;coloca valores nas variáveis
	movwf	VAR1

	movlw	0x00
	movwf	VAR2
	
	clrf	SEG		;zera variáveis
	clrf	MIN
	clrf	BZZ2

aqui_sempre:
	btfsc	BZZ2,0		;testa p/ saber se toca beep
	goto	buzzer		;toca beep
	call	mostra_disp	;mostra valores no display
	goto	aqui_sempre	;mantem processamento preso. Aguarda INT sempre

;*****************************************************************
; subrotinas de interrupçoes
; salve o contexto geral se necessario (registros W e STATUS)

IntVector:
	movwf	W2		;salva W
	swapf	STATUS,W
	clrf	STATUS
	movwf	STATUS2		;salva STATUS
	movf	PCLATH,W
	movwf	PCLATH2		;salva PCLATH

IntRB0:
	btfss INTCON,INTF	;interrupção em RB0?
	goto	OutraInt	;não, então checa outra
	bcf	INTCON,GIE	;desabilita INTs
	bcf	INTCON,INTF	;limpa registro de interrupção
	call	Conta		;conta int
	goto	IntEnd		;fim das interrupções

OutraInt:
	goto	$

IntEnd:
	movf	PCLATH2,W	;
	movwf	PCLATH		;restaura PCLATH

	swapf	STATUS2,W
	movwf	STATUS		;restaura STATUS

	swapf	W2,F		;
	swapf	W2,W		;restaura W

	bsf	INTCON,GIE	;habilita INTs
	retfie			;retorna da INT

;****************************************************************
; subrotina - mostra display

mostra_disp:

	movf	VAR1,W		;pega valor display 1
	movwf	VAR_AUX		;salva na variável auxiliar
	call	prep_ret	;prepara valor de retorno
	movwf	DISPLAY		;coloca valor no display

	nop			;perde 3 ciclos
	nop
	nop

	bsf	C_DSP,DISP1	;ativa catodo do display
	call	_30ms		;temporiza 30 ms
	bcf	C_DSP,DISP1	;desliga catodo 

	movf	VAR2,W		;pega valor display 2
	movwf	VAR_AUX		;salva na variável auxiliar
	call	prep_ret	;prepara valor de retorno
	movwf	DISPLAY		;coloca valor no display

	nop			;perde 3 ciclos
	nop
	nop

	bsf	C_DSP,DISP2	;ativa catodo do display
	call	_30ms		;temporiza 30 ms
	bcf	C_DSP,DISP2	;desliga catodo 

	return			;volta

;****************************************************************
; subrotina - prepara retorno do display
;
; Entrada - valor decimal
; Saida   - valor adaptado para 7 segmento

prep_ret:
	MOVF	VAR_AUX,W	;coloca variavel auxiliar em W
	addwf	PCL,F		;soma W a PCL
	retlw	B'01111110'	; 00 no display
	retlw	B'00001100'	; 01 no display
	retlw	B'10110110'	; 02 no display
	retlw	B'10011110'	; 03 no display
	retlw	B'11001100'	; 04 no display
	retlw	B'11011010'	; 05 no display
	retlw	B'11111010'	; 06 no display
	retlw	B'00001110'	; 07 no display
	retlw	B'11111110'	; 08 no display
	retlw	B'11011110'	; 09 no display

	retlw	0x00		; erro retorna 0
	retlw	0x00		; erro retorna 0
	retlw	0x00		; erro retorna 0
	retlw	0x00		; erro retorna 0
	retlw	0x00		; erro retorna 0
	retlw	0x00		; erro retorna 0
	
	clrf	VAR_AUX		; apenas previne erro de desvio no PCL
	return

;*********************************************************
; Conta - conta numero de ints
;
; Preparada para contar segundos
; conta de 0000 a 9999 segundos
;*********************************************************

Conta:
	incf	SEG,F		;incrementa segundo
	movf	SEG,W		;move segundo para W
	xorlw	0x3C		;compara com 60
	btfss	STATUS,Z	;
	goto	fimconta	;menor, apenas volta
	movlw	0x00		;zera SEG
	movwf	SEG

	incf	VAR1,F		;incrementa 1º display
	movf	VAR1,W		;
	xorlw	0x0A		;compara com 10
	btfss	STATUS,Z
	goto	fimconta
	
	movlw	0x00		;zera VAR1
	movwf	VAR1

	incf	VAR2,F		;incrementa 2º display
	movf	VAR2,W		;
	xorlw	0x06		;compara com 6
	btfss	STATUS,Z
	goto	fimconta

	movlw	0x00		;zera todas VAR
	movwf	VAR1
	movwf	VAR2

 	bcf	INTCON,GIE	;desabilita INTs
				;para voltar a contar, so resetando
	movlw	0x01		
	movwf	BZZ2		;final da contagem, toca beep
	
fimconta:
	return			;volta

;*********************************************************
; rotina de alarme
;*********************************************************
buzzer:
	movlw	0x32		;carrega com 50
	movwf	BZZ1		;variavel auxiliar de toque
bz1:
	bsf	PORTA,BEEP	;liga beep
	call	_10ms		;aguarda 1ms
	bcf	PORTA,BEEP	;desliga beep
	call	_10ms
	call	_10ms
	decfsz	BZZ1,F		;decrementa
	goto	bz1
	call	_200ms		;aguarda 400ms (quase 1/2 segundo)
	call	_200ms		;aguarda 400ms (quase 1/2 segundo)
	goto 	buzzer


;*********************************************************
; rotinas de temporização
;*********************************************************

_10ms:  
	movlw	.248			; seta numero de repetições 
        movwf	T1 
P0:
	nop				; perde 1 ciclo
        decfsz	T1, F			; tempo igual a zero?
        goto	P0			; não, faz novamente
P1:	goto	P2			; perde 2 ciclos
P2:	nop				; perde +1 ciclo
        return				; fim.


_30ms:
        movlw   0x03                    ;carrega W com 3
	movwf	T2			;carrega T2 com W
_30_1:
	call	_10ms			;chama _10ms 3x
	decfsz	T2,F
	goto	_30_1
	return

_200ms:
        movlw   0x14                    ;carrega W com 20
	movwf	T2			;carrega T2 com W
_200_1:
	call	_10ms			;chama _10ms 20x
	decfsz	T2,F
	goto	_200_1
	return


;****************************************************************
; fim do programa

	end

