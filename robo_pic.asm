;******************************************************
;Projeto Rob� PIC - Rob� controlado por um PIC16F84A
;M�rcio Jos� Soares - 10/09/2003
;
;I/O's usadas
;RB4 - rel� liga/desliga motor 1
;RB5 - rel� liga/desliga motor 2
;RB6 - rel� de invers�o 1
;RB7 - rel� de invers�o 2. Necess�rio o uso de ambos para inverter os motores
;
;RA2 - chave "bumper" 1
;RA3 - chave "bumper" 2
;
;Clock - 4 MHz
;
;�ltimas altera��es
;
;******************************************************

	list p=16F84		;listagem
	radix dec		;padrao->valores decimal se nao informado outro
	include <P16F84A.INC>	;inclue arquivo

	__CONFIG _CP_OFF & _PWRTE_OFF &  _WDT_OFF & _XT_OSC  ;configura bits

;
;**************************************************************
;constantes
;**************************************************************
;
picram	equ	0x0C		;inicio da RAM
picres	equ	0x00		;endere�o de reset
picint	equ	0x04		;endere�o de interrup��o

CHAVE1	equ	0x02		;chave 1, pino 1, bit 2 porta A
CHAVE2	equ	0x03		;chave 2, pino 2, bit 3 porta A
RL1	equ	0x04		;rele 1, pino 10, bit 4 porta B
RL2	equ	0x05		;rele 2, pino 11, bit 5 porta B
RL3	equ	0x06		;rele 3, pino 12, bit 6 porta B
LED	equ	0x07		;rele 4, pino 13, bit 7 porta B

CHAVES	equ	PORTA		;porta onde est�o as chaves
RELES	equ	PORTB		;porta onde est�o os reles

;
;**************************************************************
;vari�veis
;**************************************************************
;

	org	picram		;define local para criar vari�veis

T1	res	1		;vari�vel para temporiza��o
T2	res	1		;vari�vel para temporiza��o
T3	res	1		;vari�vel para temporiza��o
T4	res	1		;vari�vel para temporiza��o

;
;
;**************************************************************
;define memoria de programa e vetor de reset
;**************************************************************
;

	org	picres		;reset
	goto	inicio		;desvia do endere�o 0x04 - interrup��o

;
;
;**************************************************************
;endere�o e rotina de interrup��o
;**************************************************************
;
	org	picint		;toda interrup��o aponta para este endere�o

	retfie			;retorno de interrup��o

;
;
;**************************************************************
;inicia ambiemte - PIC
;**************************************************************
;

inicio:
	movlw	0x00			;ajuste para os bits INTCON
	movwf	INTCON

	bsf	STATUS,RP0		;seleciona banco 1 para options e tris

	movlw	0x0C			;ajusta os bits em A, 2 e 3 como entrada
	movwf	TRISA			;e o restante como sa�da

	movlw	0x00			;ajusta todos bits em B como saida
	movwf	TRISB

	bcf	STATUS,RP0		;volta ao banco 0... (padr�o do reset)

	movlw	0x0			;zera rel�s
	movwf	RELES			;rob� parado

	call	a_frente		;move rob� a frente

;
;**************************************************************
;programa e rotina principal
;**************************************************************
;


loop:
	btfss	CHAVES,CHAVE1		;testa chave 1
	goto	aled			;acionada, realiza desvio
	btfss	CHAVES,CHAVE2		;testa chave 2
	goto	lado2			;acionada, realiza desvio
	goto	loop			;faz eternamente

;
;**************************************************************
;subrotinas para movimentar o rob�
;**************************************************************
;

lado1:
	call	para_robo		;para rob�
	call	tempo			;aguarda tempo
	call	a_re			;movimenta para a r�
	call	tempo			;aguarda tempo
	call	para_robo		;para rob�
	bsf	RELES,RL2		;liga rele 1, sentido invertido
	call	tempo			;aguarda final do movimento
	call	a_frente		;volta movimentar a frente
	goto	loop

lado2:
	call	para_robo		;para rob�
	call	tempo			;aguarda tempo
	call	a_re			;movimenta para a r�
	call	tempo			;aguarda tempo
	call	para_robo
	bsf	RELES,RL1		;liga rele 2, sentido invertido
	call	tempo			;aguarda final do movimento
	call	a_frente		;volta movimentar a frente
	goto	loop

para_robo:                
	bcf	RELES,RL1		;desliga rele 1
	bcf	RELES,RL2		;desliga rele 2
	return

a_frente:
	bcf	RELES,RL3		;desliga rele 3
;	bcf	RELES,RL4		;desliga rele 4. Sentido dos motores normal
	bsf	RELES,RL1		;liga rele 1
	bsf	RELES,RL2		;liga rele 2. Rob� em movimento
	return

a_re:
	bsf	RELES,RL3		;liga rele 3
;	bsf	RELES,RL4		;liga rele 4. Sentido dos motores invertido
	bsf	RELES,RL1		;liga rele 1
	bsf	RELES,RL2		;liga rele 2. Rob� em movimento
	return
aled
  	bsf	RELES,LED
;	call tempo
	bcf	RELES,LED
	retum

;
;**************************************************************
;subrotina de temporiza��o
;**************************************************************
;
;aguarda 1 segundo com clock de 4MHz
	
tempo:
	movlw	0x06			;carrega W com 6
	movwf	T3			;carrega T3 com 6
	movlw	0x01			;carrega T4 com 1
	movwf	T4
	
car:
        movlw   0xff                    ;carrega W com 255
	movwf	T1			;carrega T1 com W
	btfsc	T4,0			;testa bit 0 de T4
	decfsz	T3,F			;decrementa T3
	goto car_1
	return

car_1:
        movlw   0xFF                    ;carrega W com 255
	movwf	T2			;carrega T2 com 255
dec_1:
	decfsz T2,1			;decrementa T2
	goto	dec_1			;255 x T1 vezes
	decfsz T1,1			;decrementa T1
	goto car_1			;volta a carregar T2
	btfsc	T4,0			;testa bit 0 de T4
	goto	car			;retorna 0 em W
	return

;****************************************************************
; fim do programa
;****************************************************************
	end



