;*****************************************************************************
;UNIVERSIDAD DEL VALLE
;LABORATORIO 6
;RODRIGO GARCÍA 19085
;***************************************************************************** 
    ; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR


; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

#include "p16f887.inc"

; CONFIG1
; __config 0xE0D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

 #DEFINE    TRANS_DISP1	PORTD, .0
 #DEFINE    TRANS_DISP2	PORTD, .1
 #DEFINE    TRANS_DISP3	PORTD, .2
 #DEFINE    TRANS_DISP4	PORTD, .3 
 
    
  GPR	UDATA
  ADC1	    	RES 1
  ADC2	        RES 1			
  SHOW_DISP1	RES 1
  SHOW_DISP2	RES 1
  SHOW_DISP3	RES 1
  SHOW_DISP4	RES 1	
  DISP1		    RES 1
  DISP2		    RES 1	
  DISP3		    RES 1
  DISP4		    RES 1	
  DELAY_5MS	    RES 1		
  PZ		    RES 1

    RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    SETUP                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED
;**********************************INTERRUPTS***********************************
;ISR_VEC CODE 0X004

;******************************************************************************    
        
MAIN_PROG CODE                      ; let linker place main program

SETUP
    CALL CONFIG_IO
    CALL CONFIG_TXRX
    CALL CONFIG_ADC
    CALL CONFIG_DISPLAY

    CLRF PZ
    BSF	 PZ, 0
    
    BANKSEL	DELAY_5MS
    CLRF	DELAY_5MS
    MOVLW	.1                   ;ASIGNO 1 PARA REALIZAR 1 INTERRUPCIONES HASTA LLEGAR A 5MS
    MOVWF	DELAY_5MS
    
 GOTO LOOP
 
LOOP
    CALL    POT1
    CALL    DELAY10US    
    CALL    POT2
    CALL    SELE 
    CALL    DISPLAY1     
        
    GOTO LOOP                          ; loop forever

;*********************************CONFIG GENERALES*****************************
CONFIG_IO
    BCF STATUS, 5
    BCF STATUS, 6
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC
    CLRF PORTD
    CLRF PORTE
    
    BANKSEL TRISA        ;INDICO LAS ENTRADAS Y SALIDAS PARA LOS PUERTOS A USAR
    CLRF    TRISA
    COMF    TRISA
    CLRF   TRISB
    CLRF   TRISC
    CLRF   TRISD
    
    BANKSEL ANSEL
    CLRF    ANSEL
    COMF    ANSEL    

    RETURN

CONFIG_OSCCON    
    BANKSEL	OSCCON
    MOVLW	B'01100001'
    MOVWF	OSCCON
    BSF		INTCON, T0IE
    BCF		INTCON, T0IF
    BSF		INTCON, GIE
    RETURN
    
DELAY10US
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    RETURN
;*****************************CONFIG ENVIO Y RECIBIR************

CONFIG_TXRX
    BANKSEL TXSTA
    BCF	    TXSTA, SYNC
    BSF	    TXSTA, BRGH
    BANKSEL BAUDCTL
    BSF	    BAUDCTL, BRG16
    BANKSEL SPBRG
    MOVLW   .25
    MOVWF   SPBRG
    CLRF    SPBRGH
    BANKSEL RCSTA
    BSF	    RCSTA, SPEN
    BCF	    RCSTA, RX9
    BSF	    RCSTA, CREN
    BANKSEL TXSTA
    BSF	    TXSTA, TXEN
    BANKSEL PORTA
    RETURN

;****************************ADC***********************************************
CONFIG_ADC
    BANKSEL ADCON1
    MOVLW   B'00000000'
    MOVWF   ADCON1
    BANKSEL ADCON0
    MOVLW   B'01000101'
    MOVWF   ADCON0
    RETURN
     
CONFIG_ADC2
    BANKSEL ADCON1
    MOVLW   B'00000000'
    MOVWF   ADCON1
    BANKSEL ADCON0
    MOVLW   B'01001001'
    MOVWF   ADCON0
    RETURN
;********POTENCIOMETROS CONFIG****        
POT1:
    CALL    CONFIG_ADC
    BANKSEL PORTA
    CALL    DELAY10US
    BSF	    ADCON0, GO
    BTFSC   ADCON0, GO
    GOTO    $-1
    MOVF    ADRESH, W
    MOVWF   ADC1
    MOVWF   SHOW_DISP1
    MOVWF   SHOW_DISP2          
RETURN
        
POT2:
    CALL    CONFIG_ADC2
    BANKSEL PORTA
    CALL    DELAY10US
    BSF	    ADCON0, GO
    BTFSC   ADCON0, GO
    GOTO    $-1
    MOVF    ADRESH, W
    MOVWF   ADC2
    MOVWF   SHOW_DISP3
    MOVWF   SHOW_DISP4
RETURN    
    
;****************************RUTINAS DE ENVIO**********************************     
ENVIO1:
    BCF	    PZ, 0
    BSF	    PZ, 1
    BTFSS   PIR1, TXIF
    MOVFW   ADC1
    MOVWF   TXREG
    RETURN
    
ENVIO2:
    BSF	    PZ, 0
    BCF	    PZ, 1
    BTFSS   PIR1, TXIF
    MOVFW   ADC2
    MOVWF   TXREG
    RETURN    
    
SELE:
    BTFSC   PZ, 0
    GOTO    ENVIO1
    BTFSC   PZ, 1
    GOTO    ENVIO2
    RETURN  
        
;***************************CONFIG DISPLAYS************************************    
CONFIG_DISPLAY
    BANKSEL	DISP1
    CLRF	DISP1
    BANKSEL	DISP2
    CLRF	DISP2
    BANKSEL	DISP3
    CLRF	DISP3
    BANKSEL	DISP4
    CLRF	DISP4
    
    CLRF	SHOW_DISP1		 
    CLRF	SHOW_DISP2	
    CLRF	SHOW_DISP3		 
    CLRF	SHOW_DISP4	    
    
    BCF		TRANS_DISP1
    BCF		TRANS_DISP2
    BCF		TRANS_DISP3
    BCF		TRANS_DISP4
    RETURN
    
TABLA7
     ANDLW   B'00001111'
     ADDWF   PCL, F
     RETLW   B'11000000' ;O
     RETLW   B'11111001' ;1
     RETLW   B'10100100' ;2
     RETLW   B'10110000' ;3
     RETLW   B'10011001' ;4
     RETLW   B'10010010' ;5
     RETLW   B'10000010' ;6
     RETLW   B'11111000' ;7
     RETLW   B'10000000' ;8
     RETLW   B'10011000' ;9
     RETLW   B'10001000' ;A
     RETLW   B'10000011' ;b
     RETLW   B'11000110' ;C
     RETLW   B'10100001' ;d
     RETLW   B'10000110' ;E
     RETLW   B'10001110' ;F    
     
DISPLAY1:
    MOVLW   .1
    MOVWF   DELAY_5MS
    BANKSEL PORTB
    CLRF    PORTB
    BSF	    TRANS_DISP1	
    BCF	    TRANS_DISP2
    BCF	    TRANS_DISP3
    BCF	    TRANS_DISP4    
    MOVF    SHOW_DISP1, 0
    CALL    TABLA7
    MOVWF   PORTB
    BSF	    DISP1, .0
    BCF	    DISP2, .0
    BCF	    DISP3, .0
    BCF	    DISP4, .0          
    
DISPLAY2:			    ;MISMA CONFIG DISP1
    MOVLW   .1
    MOVWF   DELAY_5MS
    BANKSEL PORTB
    CLRF    PORTB
    BCF	    TRANS_DISP1
    BSF	    TRANS_DISP2    
    BCF	    TRANS_DISP3
    BCF	    TRANS_DISP4
    SWAPF   SHOW_DISP2, W
    MOVWF    SHOW_DISP2
    CALL    TABLA7
    MOVWF   PORTB
    BCF	    DISP1, .0
    BSF	    DISP2, .0
    BCF	    DISP3, .0
    BCF	    DISP4, .0     	           
    ;GOTO    POP    
    
DISPLAY3:
    MOVLW   .1
    MOVWF   DELAY_5MS
    BANKSEL PORTB
    CLRF    PORTB
    BCF	    TRANS_DISP1	
    BCF	    TRANS_DISP2
    BSF	    TRANS_DISP3
    BCF	    TRANS_DISP4   
    MOVF    SHOW_DISP3, 0
    CALL    TABLA7
    MOVWF   PORTB  
    BCF	    DISP1, .0
    BCF	    DISP2, .0
    BSF	    DISP3, .0
    BCF	    DISP4, .0     
    ;GOTO    POP

DISPLAY4:				;MISMA CONFIG DISP1
    BANKSEL PORTB
    CLRF    PORTB
    BCF	    TRANS_DISP1	
    BCF	    TRANS_DISP2
    BCF	    TRANS_DISP3
    BSF	    TRANS_DISP4   
    SWAPF   SHOW_DISP4, W
    MOVWF    SHOW_DISP4
    CALL    TABLA7
    MOVWF   PORTB  
    BCF	    DISP1, .0
    BCF	    DISP2, .0
    BCF	    DISP3, .0
    BSF	    DISP4, .0  
    ;GOTO    POP    
RETURN
    
DISPLAY_VAR:
    BTFSS   DISP1, .0
    GOTO    DISPLAY1     
    BTFSS   DISP2, .0
    GOTO    DISPLAY2       
        
DISPLAY_TOG:   
    BTFSS   DISP3, .0    
    GOTO    DISPLAY3              
    BTFSS   DISP4, .0
    GOTO    DISPLAY4    
    
    END