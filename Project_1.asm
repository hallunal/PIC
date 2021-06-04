;==========================================================
;==========================================================
LIST	P=16F628A
INCLUDE	"P16F628A.INC"
__CONFIG _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BODEN_OFF & _LVP_OFF & _DATA_CP_OFF & _CP_OFF
;==========================================================
;==========================================================
	CBLOCK	20h
SAYAC1,SAYAC2,TEMP,STATE			
	ENDC

	CLRF	PORTB		
	BCF		STATUS, 0	
	BANKSEL TRISB		
	CLRF	TRISB		
	MOVLW	h'07'		
	MOVWF	TRISA
	BANKSEL PORTB		
	MOVLW   h'07'		
	MOVWF	CMCON		

START
	CLRF	PORTB			
	BTFSC	PORTA,0			
	GOTO	SAGA_KAYDIR		
	BTFSC	PORTA,1			
	GOTO 	SOLA_KAYDIR		
	BTFSC	PORTA,2			
	GOTO 	SAGA_SOLA_KAYDIR_1	
	GOTO 	START

SAGA_KAYDIR
	MOVLW	h'80'
	MOVWF	PORTB
	GOTO 	saga_kay
SOLA_KAYDIR
	MOVLW	h'01'
	MOVWF	PORTB
	GOTO 	sola_kay

SAGA_SOLA_KAYDIR_1
	MOVLW	h'80'
	MOVWF	PORTB
    GOTO    SAG
	
SAGA_SOLA_KAYDIR_2
	MOVLW	h'01'
	MOVWF	PORTB
    GOTO    SOL
SAG 
	RRF		PORTB, F
	BTFSC 	PORTB,0
	GOTO    SAGA_SOLA_KAYDIR_2
	GOTO	CHECK_A0_A1_1
	CALL	GECIKME
	GOTO 	SAG 
    
SOL
	RLF	 	PORTB, F	
	BTFSC 	PORTB,7
	GOTO  	SAGA_SOLA_KAYDIR_1
	GOTO	CHECK_A0_A1_2
	CALL	GECIKME
	GOTO 	SOL
	


saga_kay	
	BTFSC	PORTB,0			
	GOTO	SAGA_KAYDIR 	
	RRF		PORTB, F		
	GOTO	CHECK_A1_A2		
	CALL	GECIKME			
	GOTO	saga_kay		

sola_kay
	BTFSC	PORTB,7			
	GOTO	SOLA_KAYDIR 	
	RLF		PORTB, F		
	GOTO	CHECK_A0_A2
	CALL	GECIKME			
	GOTO	sola_kay		



CHECK_A0_A1_1
	BTFSC	PORTA,0			
	GOTO 	SAGA_KAYDIR		
	BTFSC	PORTA,1			
	GOTO 	SOLA_KAYDIR		
	GOTO	SAG
CHECK_A0_A1_2
	BTFSC	PORTA,0			
	GOTO 	SAGA_KAYDIR		
	BTFSC	PORTA,1			
	GOTO 	SOLA_KAYDIR		
	GOTO	SOL
	

CHECK_A0_A2
	BTFSC	PORTA,0			
	GOTO 	SAGA_KAYDIR		
	BTFSC	PORTA,2			
	GOTO 	SAGA_SOLA_KAYDIR_1	
	GOTO	sola_kay

CHECK_A1_A2
	BTFSC	PORTA,1			
	GOTO 	SOLA_KAYDIR		
	BTFSC	PORTA,2			
	GOTO 	SAGA_SOLA_KAYDIR_1	
	GOTO	saga_kay

GECIKME					
	MOVLW	h'81'  		
	MOVWF	SAYAC1 		
DONGU1
	MOVLW	h'81'	
	MOVWF	SAYAC2		
DONGU2	
	DECFSZ	SAYAC2, F	
	GOTO	DONGU2		
	DECFSZ	SAYAC1, F	
	GOTO	DONGU1		
	RETURN				
	END

;==========================================================
;==========================================================
;==========================================================
