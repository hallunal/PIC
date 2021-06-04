;=== 15156051-HALİL İBRAHİM ÜNAL ===============================

LIST	P=16F628A
INCLUDE	"P16F628A.INC"
__CONFIG _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF & _BODEN_OFF & _LVP_OFF & _DATA_CP_OFF & _CP_OFF

;------------------------------------------------------------------------------------------------------------------------
;RA4 port'undaki ledi yakamadığım için program düzgün çalışsın diye led sayısını 4'e indirdim ve max degeri h'0F' yaptım
;------------------------------------------------------------------------------------------------------------------------

	CBLOCK	20h
GECİK_10mS,YAK_SONDUR,DEGER			;Değişkenlere adres atmak için
	ENDC
	ORG		h'00'			;Reset veya gerilim verildiğinde
	GOTO 	BASLA			;BASLA fonksiyonuna gitmek için 
	ORG		h'004'			;Kesme oluştuğunda çalışır
	GOTO	KESME_SECME		;KESME_SECME fonksiyonuna gider(kesme olduğunda)

BASLA						
	CLRF	PORTA			;PortA'yi temizle
	CLRF	PORTB			;PortB'yi temizle
	CLRF	YAK_SONDUR		;Bu fonksiyon ilerde ledlerin yanık mı yoksa sönük mü olduğunu kontrol etmemiz için
 	BANKSEL TRISA			;BANK1'e geç
	MOVLW	b'11110111'		
	MOVWF	TRISB			;PORTB'deki 3. portu çıkış, gerisini giriş yapıyoruz
	MOVLW	h'00'			
	MOVWF	TRISA			;PORTA'daki bütün portlar çıkış olacak
	MOVLW	b'11010111'		; T0CS=0, PSA=0, Fre_Böl=1/256
	MOVWF	OPTION_REG		;W'yi OPTION saklayıcıya yükle
	BANKSEL PORTA			;BANK0'a geç
	MOVLW	h'01'			
	MOVWF	DEGER			;PORTA'nın çıkışlarında gösterilecek degerin ilk hali için 
	BSF		INTCON,7		;Tüm kesmelere izin ver
	BSF		INTCON,5		;TMR0 kesmesine izin ver.
	
	

DONGU_1							
	BCF		PORTB,3			;hayır, RB3'deki ledi söndür
	BTFSS	PORTB,2			;butona basılmış mı?
	GOTO	DONGU_1			;Başlangıç döngüsünü tekrarla
	BSF		PORTB,3			;evet RB3'deki ledi yak 
DONGU_2
	BTFSS	PORTB,2			;butona basılmış mı?
	GOTO	DONGU_1			;Başlangıç döngüsünü tekrarla
	GOTO	DONGU_2			;Konrol döngüsünü tekrarla
	
KESME_SECME
	BTFSC	INTCON,INTF		;Kesme RB0'da mı olmuş?
	CALL 	AZALT			;evet,azaltma fonksiyonuna git
	BTFSC	INTCON,RBIF		;Kesme RB<4:7> butonların birinde mi olmuş?
	CALL 	ARTTIR			;evet,arttırma fonksiyonuna git
	BCF		INTCON,2		;TMR0 kesmesini sonrakilere hazırla
	MOVLW	h'EF'			;TMR0 ilk sayısı = d’217’
	MOVWF	TMR0			;TMR0 saymaya başlar
	INCF	GECİK_10mS,F	; 10 mS'leri tutan sayacı 1 arttır
	MOVLW	d'50'			; W = d'50'
	SUBWF	GECİK_10mS,W	; W = GECİK_10mS - W
	BTFSS	STATUS,Z		; SAY_10mS = 50 oldu mu?
	GOTO	KESME_SONU		; Hayır, ana programa git ve bekle.
	CLRF	GECİK_10mS		; Evet,10 mS'leri tutan sayacı sıfırla
	BTFSS	YAK_SONDUR,0	;PORTA'daki ledler yanık mı?(yanıksa:1,sönükse:0)
	GOTO 	YAK				;hayır sönük yakmaya git
	CLRF 	PORTA			;evet yanık PORTA'daki ledleri söndür
	BCF		YAK_SONDUR,0	;ledlerin söndüğünü belirlemek için
	RETFIE
	
KESME_SONU
	RETFIE					; Kesme alt programından ana programa dön.
	
YAK
	MOVF	DEGER,W			
	MOVWF	PORTA			;DEGER'i PORTA'ya aktarıyoruz
	BSF		YAK_SONDUR,0	;ledlerin yandığını belirlemek için
	RETFIE
	
; TMR0'sini hesaplamak için kesme gecikme süresi ve simulasyon çalıma 
; frekansı kullanarak bullabiriz. Simulasyon frekansını 2MHz alırsak
; ve kesme gecikme süreside 10mS olduğu için denklemden
; TMR0'ın ilk değeri = 236 buluruz.Buda h'EF' ye eşittir.
; Aldıgımız W = d'50' degeri ise sayacı tutan degeri 50 kez dönderip
; gecikmeyi 0.5 S yapmak için gecikmeyi 50 kez döndürmekte butona basım işlemini 
; daha rahat okuyabilmek için  

AZALT						
	BCF		INTCON,INTF		
	MOVLW	H'01'			;DEGER min deger e ulaştı mı kontrol ediyoruz
	SUBWF	DEGER,W		
	BTFSC	STATUS,Z		;sayımız 0'a eşit mi?
	RETURN
	DECF	DEGER,F			;zero flag clear olduğu için değeri 1 azalt
	RETURN					
	
ARTTIR	
	BCF		INTCON,RBIF		
	MOVLW	H'0F'			;DEGER max deger e ulaştı mı kontrol ediyoruz
	SUBWF	DEGER,W		
	BTFSC	STATUS,Z		;sayımız 0'a eşit mi?
	RETURN
	BTFSC	PORTB,4			;evet değer clear da. Basılan buton RB4 mü?
	INCF	DEGER,F			;evet. Degeri arttır
	BTFSC	PORTB,5			;hayır.Basılan buton RB5 mi?
	INCF	DEGER,F			;evet. Degeri arttır
	BTFSC	PORTB,6			;hayır.Basılan buton RB6 mı?
	INCF	DEGER,F			;evet. Degeri arttır
	BTFSC	PORTB,7			;hayır.Basılan buton RB57 mi?
	INCF	DEGER,F			;evet. Degeri arttır
	RETURN					
END
;----------------------------------------------------------