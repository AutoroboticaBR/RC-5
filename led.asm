;Revista Mecatronica Fácil 
;programa LED.ASM pisca led 
;com PIC16F84A Mareio Soares
;************************************************

	list P=16F84	;listagem
	radix dec		;valores decimal
	include <P16F84.INC>	;inclue arquivo

;*************************************************
;* Variáveis necessárias para o programa
;*************************************************
 
PICRES	equ	0x00	;vetor de reset	   
CHAR	equ	0x01	;var caracter	   
TEMP	equ	0x02	;var de uso geral	   
Tl		equ	0x03	;var para timer	   
T2		equ	0x04	;var para o timer
LED		equ 0x05	   

;******************************************************	 
;*define memória de programa e vetor de reset
;***************************************************
		org  PICRES  ;reset
meureset			 ;cria label meureset
		goto inicio  ;desvia end 0x04 -int

;**************************************************
;*endereço e rotina de interrupção
;**************************************************
		org  4  ;toda int aponta p/ aqui
				;não há ints, retorno apenas 
		retfie   ;retorno de interrupção

;*************************************************
;inicio do programa
;************************************************* 
inicio:
		movlw  0x00		;ajuste  bit INTCON  
		movwf  INTCON	;INTCON com O 
						;desabilita as int
		clrf	PORTA	;limpo registro do
		clrf	PORTB	;limpo registro do port B

		bsf	STATUS,RPO	;seleciona banco
		movlw	0x00 	;ajusta os bits
		movwf	TRISA	;A como saida
		movlw	0x00	;ajusta os bits
		movwf	TRISB 	;B como saida ;volta ao banco 
		bcf	STATUS,RPO 	;volta ao banco 0 (padrão do reset)
;*************************************************** 
;subrotina pisca led
;***************************************************
piscaled:
		 bsf PORTA,LED 	;acende o led
		call tempo		;aguarda tempo
		 bcf PORTA,LED 	;apaga led
		call tempo		;aguarda tempo
		goto piscaled 	;volta para fazer 
 						;infinitamente

;***************************************************
;subrotina para temporizar, sem o uso do
;temporizador interno
;**************************************************
 
tempo:					;aguarda	l segundo no total
		movlw 255		;carrega W com 255
		movwf T1		;carrega Tl com W
car_l:		
		movlw 255		;carrega W com 255
		movwf T2			;carrega T2 com 255
 
dec_l:
		decfsz T2,l		;decrementa T2
		goto  dec_l  	;255 x Tl vezes 
		decfsz Tl,l		;decrementa Tl
 		goto car_l 		;volta a carregar
 		retlw  0x00		;rétorna O em W
;*****************************************************
;* fim do programa
;*****************************************************
END
