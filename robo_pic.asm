;******************************************************
;Projeto Robô PIC - Robô controlado por um PIC16F84A
;Márcio José Soares - 10/09/2003
;
;I/O's usadas
;RB4 - relé liga/desliga motor 1
;RB5 - relé liga/desliga motor 2
;RB6 - relé de inversão 1
;RB7 - relé de inversão 2. Necessário o uso de ambos para inverter os motores
;
;RA2 - chave "bumper" 1
;RA3 - chave "bumper" 2
;
;Clock - 4 MHz
;
;últimas alterações
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
picres	equ	0x00		;endereço de reset
picint	equ	0x04		;endereço de interrupção

CHAVE1	equ	0x02		;chave 1, pino 1, bit 2 porta A
CHAVE2	equ	0x03		;chave 2, pino 2, bit 3 porta A
RL1	equ	0x04		;rele 1, pino 10, bit 4 porta B
RL2	equ	0x05		;rele 2, pino 11, bit 5 porta B
RL3	equ	0x06		;rele 3, pino 12, bit 6 porta B
LED	equ	0x07		;rele 4, pino 13, bit 7 porta B

CHAVES	equ	PORTA		;porta onde estão as chaves
RELES	equ	PORTB		;porta onde estão os reles

;
;**************************************************************
;variáveis
;**************************************************************
;

	org	picram		;define local para criar variáveis

T1	res	1		;variável para temporização
T2	res	1		;variável para temporização
T3	res	1		;variável para temporização
T4	res	1		;variável para temporização

;
;
;**************************************************************
;define memoria de programa e vetor de reset
;**************************************************************
;

	org	picres		;reset
	goto	inicio		;desvia do endereço 0x04 - interrupção

;
;
;**************************************************************
;endereço e rotina de interrupção
;**************************************************************
;
	org	picint		;toda interrupção aponta para este endereço

	retfie			;retorno de interrupção

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
	movwf	TRISA			;e o restante como saída

	movlw	0x00			;ajusta todos bits em B como saida
	movwf	TRISB

	bcf	STATUS,RP0		;volta ao banco 0... (padrão do reset)

	movlw	0x0			;zera relés
	movwf	RELES			;robô parado

	call	a_frente		;move robô a frente

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
;subrotinas para movimentar o robô
;**************************************************************
;

lado1:
	call	para_robo		;para robô
	call	tempo			;aguarda tempo
	call	a_re			;movimenta para a ré
	call	tempo			;aguarda tempo
	call	para_robo		;para robô
	bsf	RELES,RL2		;liga rele 1, sentido invertido
	call	tempo			;aguarda final do movimento
	call	a_frente		;volta movimentar a frente
	goto	loop

lado2:
	call	para_robo		;para robô
	call	tempo			;aguarda tempo
	call	a_re			;movimenta para a ré
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
	bsf	RELES,RL2		;liga rele 2. Robô em movimento
	return

a_re:
	bsf	RELES,RL3		;liga rele 3
;	bsf	RELES,RL4		;liga rele 4. Sentido dos motores invertido
	bsf	RELES,RL1		;liga rele 1
	bsf	RELES,RL2		;liga rele 2. Robô em movimento
	return
aled
  	bsf	RELES,LED
;	call tempo
	bcf	RELES,LED
	retum

;
;**************************************************************
;subrotina de temporização
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



