;-------------------------------------------------------------------------------
    ;Archivo:	  main.s
    ;Dispositivo: PIC16F887
    ;Autor: José Vanegas
    ;Compilador: pic-as (v2.30), MPLABX V5.45
    ;
    ;Programa: Proyecto 1 - Semaforos
    ;Hardware: Display 7 Seg, Push Buttom, Leds, Resistencias. 
    ;
    ;Creado: 24 mar, 2021
    ;Última modificación: 04 abril, 2021    
;-------------------------------------------------------------------------------
    PROCESSOR 16F887
    #include <xc.inc>
        
    CONFIG FOSC=INTRC_NOCLKOUT //Oscillador interno
    CONFIG WDTE=OFF	//WDT disabled (reinicio repetitivo del pic)
    CONFIG PWRTE=OFF	//PWRT enabled (espera de 72ms al iniciar)
    CONFIG MCLRE=OFF	//El pin de MCLR se utiliza como I/O
    CONFIG CP=OFF	//Sin proteccion de codigo
    CONFIG CPD=OFF	//Sin proteccion de datos

    CONFIG BOREN=OFF	//Sin reinicio cuando el voltaje de alimentacion baja 4v
    CONFIG IESO=OFF	//Reinicio sin cambio de reloj de interno a externo
    CONFIG FCMEN=OFF	//Cambio de reloj externo a interno en caso de fallo
    CONFIG LVP=OFF	//programacion en bajo voltaje permitida
    
    CONFIG WRT=OFF	//Proteccion de autoescritura por el programa desactivada
    CONFIG BOR4V=BOR40V //Reinicio abajo de 4V, (BOR21v=2.1v)
PSECT udata_shr ;common memory
 
    STATUS_TEMP: DS 1
     WTEMP: DS 1
    ;VARIABLES PARA FUNCION CONTADOR
    PORTB_ANTERIOR: DS 1	
    PORTB_ACTUAL: DS 1
    VALOR_CONTADOR: DS 1 ;VALOR PARA COMENZAR
    CONTADOR_MUX: DS 1 ;ME INDICA QUE BIT ES 
    ;CONTADOR DE CADA SEMAFORO
    CONTADOR1: DS 1
    CONTADOR2: DS 1
    CONTADOR3: DS 1
    CONTADOR4: DS 1 ;CONTADOR PARA LA CONFIGUCAGION
    ;VARIABLES PARA DIVISION
    
    UNIDAD: DS 1
    DECENA: DS 1
    VAL_DIVISION: DS 1
    VER_CONTADOR4: DS 1 ;SI ES 1 MUESTRA DISP4 Y  SI ES 0 NO
    OPCION: DS 1 ;SEMAFORO QUE SE LE ESTA CONFIGURANDO, 0 SI NO SE ESTA 
    
    
    
 PSECT resVect, class=CODE, abs, delta=2
 ORG 0x00
 GOTO CONFIG_PROG
 
 ORG 0X04

PUSH:
    MOVWF WTEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
    
    
    BTFSC INTCON, 0
    CALL ISR_CONTADOR
   
    
    
 POP:
    SWAPF STATUS_TEMP,W
    MOVWF STATUS
    SWAPF WTEMP, F
    SWAPF WTEMP, W
    
    RETFIE
 
 TABLA7SEG: ;Tabla para pasar de binario a valor numerico en el display
    ANDLW  00001111B  
    addwf PCL, F
    retlw 00111111B ;0
    retlw 00000110B ;1
    retlw 01011011B ;2
    retlw 01001111B ;3
    retlw 01100110B ;4
    retlw 01101101B ;5
    retlw 01111101B ;6
    retlw 00000111B ;7
    retlw 01111111B ;8
    retlw 01100111B ;9
    retlw 0 ;A
    retlw 0 ;B
    retlw 0 ;C
    retlw 0;D
    retlw 0 ;E
    retlw 0;F
    
 ISR_CONTADOR: ;interrupcion para el contador binario
   
    MOVF    PORTB_ACTUAL,W
    MOVWF   PORTB_ANTERIOR
    MOVF    PORTB,W
    MOVWF   PORTB_ACTUAL ;SE ACTUALIZAN LOS VALORES DE LAS VARIABLES
    BCF INTCON, 0
    
    
    BTFSC PORTB_ANTERIOR, 6
    GOTO INCDEC
    ;--- SI ANTES ERA 0 CONTUNA AQUI
    BTFSS PORTB_ACTUAL,6 
    GOTO INCDEC
    ;---------- SI EL ACTUAL ES 1 CONTINUA AQUI
    INCF OPCION, F
    MOVF   OPCION,W
    MOVWF PORTA
    INCDEC:
    MOVF    OPCION,W
    
    SUBLW 1
    BTFSC   STATUS,2 
    GOTO OPCION1

;    MOVF    OPCION,W
;    SUBLW 2
;    BTFSC   STATUS,2 
;    GOTO OPCION2
;    
;    MOVF OPCION,W
;    SUBLW 3
;    BTFSC   STATUS,2 
;    GOTO OPCION3
    RETURN
    
    
    OPCION1:
    BTFSC  PORTB_ANTERIOR,4 ;PARA INCREMENTAR
    GOTO DEC_OP1
    ;---- AQUI SIGUE SI ANTES ERA 0
    BTFSC PORTB_ACTUAL, 4
    INCF CONTADOR1,F
    MOVF CONTADOR1,W
    SUBLW 21
    BTFSS STATUS, 2
    GOTO DEC_OP1
    ; SI DA 0 LO ANTERIOR SE SIGUE AQUI
    MOVLW 10
    MOVWF CONTADOR1
    
    DEC_OP1:
    BTFSC  PORTB_ANTERIOR,5 ;PARA INCREMENTAR
    RETURN
    ;---- AQUI SIGUE SI ANTES ERA 0
    BTFSC PORTB_ACTUAL, 5
    DECF CONTADOR1,F
    MOVF CONTADOR1,W
    SUBLW 9
    BTFSS   STATUS,2
    RETURN
    ;--- --------- AQUI SIGUE SI LO ANTEOIRO DA 0
    MOVLW 20
    MOVWF CONTADOR1
    
    RETURN
    
    
    
    
   ;RETURN
    
    
ISR_TMR1:
    BCF PIR1,0
    
    
    MOVLW 11
    MOVWF TMR1H
    MOVLW   11011011B ;VALORES REALES PARA .5 SEGUNDOS
    MOVWF   TMR1L
;    
    
    
 
    INCF CONTADOR1, F
    RETURN
    
CONFIG_PROG: ;Configuracion de los bits
    
    BSF STATUS, 5
    BSF STATUS, 6 ;Banco 3
    
    CLRF ANSEL
    CLRF ANSELH
    
    BSF STATUS, 5 ;Banco 1
    BCF STATUS, 6 ;Banco 1
    
    ;BSF	PIE1,0 ;ACTIVAR INTERRUPCION TMR1
    
    CLRF TRISA
    CLRF TRISC
    CLRF TRISD
    CLRF TRISB ;Puerto A,B,C,D como salidas
    
    BSF TRISB, 4
    BSF TRISB, 5
    BSF TRISB, 6 ;Bit 4,5,6 del puerto B como entrada
    
    BCF OPTION_REG, 7 ;Pull ups puerto B
    BCF OPTION_REG, 5 ;Clok interno
    BCF OPTION_REG, 3 ;Prescaler
    BCF OPTION_REG, 2 ;Prescaler a 4
    BCF OPTION_REG, 1
    BSF OPTION_REG, 0
    
    BSF INTCON, 7 ;INTERRUPCION GLOBAL
    BSF INTCON, 6 ; INTERRUPCIOENS PERIFERICAS
;    BSF INTCON, 5 ;INTERRUPCION TIMER0
    BSF INTCON, 3 ;INTERRUPCION DEL PUERTO B
;    
    BSF IOCB, 4
    BSF IOCB, 6
    BSF IOCB, 5 ;ACTIVAR INTERRUPCION EN PIN RB0 Y RB1
    
    BCF STATUS, 5 ;Banco 0
   
    ;configuracion del tmr1 interrupcion cada 0.5 s
    BCF T1CON, 6 ;SIEMPRE ESTA CONTADO
    BSF	T1CON, 5
    BSF	T1CON, 4 ;PRESCALER !:8
    BCF T1CON,1 ;RELIJ INTERNO
    BSF	T1CON,0;SE ENCIENDE
    
    MOVLW 11
    MOVWF TMR1H ; VALORES PARA QUE SEAN .5 REALES 
    MOVLW   11011011B
    MOVWF   TMR1L
    
    MOVLW 130
    MOVWF TMR1L
    MOVLW   255
    MOVWF    TMR1H
    
    
    MOVLW 6
    MOVWF TMR0 ;BANDERA SE ENCIENDE CADA 1mS
    
    CLRF PORTA ;COLOCAR EN 0 puerto A
    CLRF PORTB ;COLOCAR EN 0 puerto B
    CLRF PORTC ;COLOCAR EN 0 puerto C
    MOVLW 128
    MOVWF PORTD ;COLOCAR EN 0 puerto Dd
    
    MOVLW 10
    MOVWF   CONTADOR1
    MOVWF   CONTADOR2
    MOVWF   CONTADOR3
    MOVWF   CONTADOR4
    MOVLW   255
    MOVWF   CONTADOR_MUX
    MOVLW 0
    MOVWF VER_CONTADOR4
    movwf OPCION
    MOVLW 255
    MOVWF   PORTB_ACTUAL
    MOVWF PORTB_ANTERIOR
    
LOOP:
    BTFSC INTCON, 2; SI SE ENCIENDE LA BANDERA DEL TIMER 
    CALL MULTIPLEX
    ;BTFSC PIR1,0
    ;CALL ISR_TMR1
    
    
    GOTO LOOP
    
MULTIPLEX: ;SE VA A REALIZAR LA MULTIPLEXZCION DE LOS DISPLAY
    BCF INTCON,7
    BCF INTCON, 2
    MOVLW 6
    MOVWF TMR0
    INCF CONTADOR_MUX, F
    
    BCF STATUS, 0
    CLRF  PORTC
    BTFSC PORTD, 7 
    RLF PORTD,F
    RLF PORTD,F
    
    
    BTFSC VER_CONTADOR4, 0
    CALL SALTAR_DISPLAY4
    
    
    BTFSC PORTD, 0
    MOVF    CONTADOR1,W
    BTFSC PORTD, 1
    MOVF    CONTADOR1,W
    BTFSC PORTD, 2
    MOVF    CONTADOR2,W
    BTFSC PORTD, 3
    MOVF    CONTADOR2,W
    BTFSC PORTD, 4
    MOVF    CONTADOR3,W
    BTFSC PORTD, 5
    MOVF    CONTADOR3,W
    BTFSC PORTD, 6
    MOVF    CONTADOR4,W
    BTFSC PORTD, 7
    MOVF    CONTADOR4,W
    
    
    
    
    MOVWF VAL_DIVISION
    CALL DIVISION
    
    BTFSS CONTADOR_MUX, 0; SI ES IMPAR EL BIT ES 1 Y SI ES PAR ES 0 
    GOTO SALTAR
    MOVF    UNIDAD,W
    GOTO CONVERTIR
    SALTAR:
    MOVF   DECENA,W 
    CONVERTIR:
    CALL TABLA7SEG
    MOVWF   PORTC
    BSF INTCON,7
    RETURN

    
SALTAR_DISPLAY4:
    MOVLW 1
    BTFSC PORTD, 6
    MOVWF PORTD
    RETURN
    
DIVISION:
    ;BCF INTCON, 7
    
    CLRF DECENA
    CLRF UNIDAD
    RESTDEC:
    MOVLW 10
    SUBWF VAL_DIVISION, W
    BTFSS STATUS, 0
    GOTO RESTUNI
    MOVWF VAL_DIVISION
    INCF DECENA, F
    GOTO RESTDEC
    RESTUNI:
    MOVF VAL_DIVISION, W
    MOVWF UNIDAD
    ;BSF INTCON, 7
    RETURN
    
    
    
    END


