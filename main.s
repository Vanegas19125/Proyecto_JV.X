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
    ;Última modificación: 06 abril, 2021    
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
PSECT udata ;common memory
 
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
    ENTRO_INT: DS 1;SI ENTRO A LA INTERRUPCION
    ;--- VARIABLES PARA GUARDAR VALOR TEMPORAL DE LA CONFIGURACION DEL SEMAFORO
    TEM1: DS 1
    TEM2: DS 1
    TEM3: DS 1
    ;--- PARA ALMACENAR VALORES DE CUENTA REGRESIVA DEL SEMAFORO
    SEMAFORO1: DS 1
    SEMAFORO2: DS 1
    SEMAFORO3: DS 1
    ;----- DELAYS -------
    DELAY: DS 1
    DELAY1: DS 1
    ;-------- OPCIONES SEMAFORO ------
    OPCION_SEM: DS 1
    CONT_TMR1: DS 1
    CONT_TMR2: DS 1
    OPCION_TITILAR: DS 1
    
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
    BTFSC PIR1, 1
    CALL ISR_TMR2
    
    
 POP:
    SWAPF STATUS_TEMP,W
    MOVWF STATUS
    SWAPF WTEMP, F
    SWAPF WTEMP, W
    
    RETFIE
 
    
    
 TABLA7SEG: ;TABLA PARA PASAR DE BINARIO AL VALOR DEL 7 SEGMENTOS
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
    retlw 01101111B ;9
    retlw 0 ;A
    retlw 0 ;B
    retlw 0 ;C
    retlw 0;D
    retlw 0 ;E
    retlw 0;F
 
 OPCIONES: ;Subrutinas para los 5 modos de operacion del semaforo
    CLRF ENTRO_INT
    MOVF   OPCION,W
    ADDWF PCL,F
    
    GOTO OP0
    GOTO OP1
    GOTO OP2
    GOTO OP3
    GOTO OP4
    GOTO OP5
 OP0:
    BCF PORTB,1
    BCF PORTB,2 
    BCF PORTB,3
    CLRF VER_CONTADOR4
    RETURN
 OP1:
    BSF PORTB,1
    MOVLW 1
    MOVWF VER_CONTADOR4
    MOVF SEMAFORO1,W
    MOVWF CONTADOR4
    RETURN
 OP2:
    BCF PORTB,1
    BSF PORTB,2
    MOVF CONTADOR4,W
    MOVWF TEM1
    MOVF SEMAFORO2,W
    MOVWF CONTADOR4
    RETURN
 OP3:
    BCF PORTB,2
    BSF PORTB,3
    MOVF CONTADOR4,W
    MOVWF TEM2
    MOVF SEMAFORO3,W
    MOVWF CONTADOR4
    RETURN
 OP4:
    BSF PORTB,2
    BSF PORTB,1
    MOVF CONTADOR4,W
    MOVWF TEM3
    RETURN
 OP5:
    MOVLW 4
    MOVWF OPCION
    RETURN
 
 SEMAFOROS:   ;Subrutina para la funcion de los semaforos
    MOVLW 2
    MOVWF CONT_TMR1
        
    MOVF OPCION_SEM, W
    ADDWF PCL, F
    ;Creamos 9 subrutinas que nos serviran para las secuencias de los 3 
	;semaforos sincronizados.
    GOTO SEM1
    GOTO SEM2
    GOTO SEM3
    GOTO SEM4
    GOTO SEM5
    GOTO SEM6
    GOTO SEM7
    GOTO SEM8
    GOTO SEM9
    CLRF OPCION_SEM
;Las subrutinas de con prefijo SEW sirven para crear la secuencia de encendido
    ;y apagado de los leds del semaforo
 SEM1:	;primer semaforo en verde, el resto en rojo	    
    MOVF SEMAFORO3,W
    MOVWF CONTADOR3
    
    BCF PORTA,0
    BCF PORTA,7
    
    BSF PORTA,2
    BSF PORTA,3
    BSF PORTA,6
    
    DECF CONTADOR1,F
    MOVF CONTADOR1,W
    SUBLW 7
    BTFSC  STATUS,2
    INCF OPCION_SEM,F 
    RETURN
    
 SEM2:    ;Sub para verde titilante del primer semaforo, los demas en rojo
    CLRF OPCION_TITILAR
    BSF T2CON, 2
    BSF PORTA,2
    BSF PORTA,3
    BSF PORTA,6
    
    DECF CONTADOR1,F
    MOVF CONTADOR1,W
    SUBLW 4
    BTFSC  STATUS,2
    INCF OPCION_SEM,F 
    RETURN
    
    
 SEM3:	;Primer semaforo en amarillo, el resto en Rojo
    BCF T2CON,2
    BCF PORTA,2
    
    BSF PORTA,1
    BSF PORTA,3
    BSF PORTA,6
    
    DECF CONTADOR1,F
    MOVF CONTADOR1,W
    SUBLW 1
    BTFSC  STATUS,2
    INCF OPCION_SEM,F 
    RETURN
    
    
 SEM4:	;Segundo semaforo en verde, resto en rojo
    MOVF SEMAFORO1,W
    MOVWF CONTADOR1
    BCF PORTA,1
    BCF PORTA,3
    
    BSF PORTA,0
    BSF PORTA,5
    BSF PORTA,6
    
    DECF CONTADOR2,F
    MOVF CONTADOR2,W
    SUBLW 7
    BTFSC  STATUS,2
    INCF OPCION_SEM,F 
    RETURN
    
 SEM5:	;Verde titilante para el segundo semaforo, resto en rojo
    MOVLW 1
    MOVWF OPCION_TITILAR
    BSF T2CON, 2
    
    
    BSF PORTA,0
    BSF PORTA,5
    BSF PORTA,6
    
    DECF CONTADOR2,F
    MOVF CONTADOR2,W
    SUBLW 4
    BTFSC  STATUS,2
    INCF OPCION_SEM,F 
    RETURN
    
    
 SEM6:	;Amarillo para el segundo, resto en rojo
    BCF T2CON,2
    BCF PORTA, 5
    
    BSF PORTA,0
    BSF PORTA,4
    BSF PORTA,6
    
    DECF CONTADOR2,F
    MOVF CONTADOR2,W
    SUBLW 1
    BTFSC  STATUS,2
    INCF OPCION_SEM,F 
    RETURN
    
 SEM7:	;Tercer semaforo en verde, los demas en rojo
    
    MOVF SEMAFORO2,W
    MOVWF CONTADOR2
    BCF PORTA,4
    BCF PORTA,6
    
    BSF PORTA,0
    BSF PORTA,3
    BSF PORTB,0
    
    DECF CONTADOR3,F
    MOVF CONTADOR3,W
    SUBLW 7
    BTFSC  STATUS,2
    INCF OPCION_SEM,F 
    RETURN
    
 SEM8:	;Verde titilante para el tercer semaforo, los demas en rojo
    MOVLW 2
    MOVWF OPCION_TITILAR
    BSF T2CON,2
  
    BSF PORTA,0
    BSF PORTA,3
    BSF PORTB,0
    
    DECF CONTADOR3,F
    MOVF CONTADOR3,W
    SUBLW 4
    BTFSC  STATUS,2
    INCF OPCION_SEM,F 
    RETURN
    
    
 SEM9:	;Amarillo para el tecer semaforo, los demas en rojo
    BCF T2CON,2
    BCF PORTB,0
    
    BSF PORTA,0
    BSF PORTA,3
    BSF PORTA,7
    
    DECF CONTADOR3,F
    MOVF CONTADOR3,W
    SUBLW 1
    BTFSC  STATUS,2
    INCF OPCION_SEM,F 
    RETURN
 ;Aqui se progra el titileo de los leds verdes, los delays se hacen con el TMR2   
 TITILAR:
    MOVLW 5
    MOVWF CONT_TMR2
    
    MOVF OPCION_TITILAR,W
    ADDWF PCL, F
    
    GOTO TITILAR1
    GOTO TITILAR2
    GOTO TITILAR3
    
 TITILAR1:
    BTFSC PORTA, 2
    GOTO ENCENDIDO1
    ;-- SI ESTA APAGADO
    BSF PORTA,2
    RETURN
 ENCENDIDO1:
    BCF PORTA,2
    RETURN
    
 TITILAR2:
    BTFSC PORTA, 5
    GOTO ENCENDIDO2
    ;-- SI ESTA APAGADO
    BSF PORTA,5
    RETURN
 ENCENDIDO2:
    BCF PORTA,5
    RETURN
    
 TITILAR3:
    BTFSC PORTB, 0
    GOTO ENCENDIDO3
    ;-- SI ESTA APAGADO
    BSF PORTB,0
    RETURN
 ENCENDIDO3:
    BCF PORTB,0
    RETURN
        
 ISR_TMR2:
    BCF PIR1,1 
    
    DECF CONT_TMR2,F
    BTFSC STATUS, 2
    CALL TITILAR
    RETURN
    
 ISR_TMR1:
    BCF PIR1,0
    
    
    MOVLW 11
    MOVWF TMR1H
    MOVLW   11011011B ;VALORES REALES PARA .5 SEGUNDOS
    MOVWF   TMR1L
    
    DECF CONT_TMR1, F
    BTFSC STATUS, 2
    CALL SEMAFOROS
    RETURN
    
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
    INCF OPCION,F
    MOVLW 1
    MOVWF ENTRO_INT
    ;CALL OPCIONES
 INCDEC: ;Subrutina para incrementar y decrementar el contador de configuracion
    MOVF OPCION,W
    SUBLW 4
    BTFSS   STATUS,2
    GOTO INCREMENTAR_DECREMENTAR
    ;-- SI EL VALOR DE LA OPCION ES 4
    BTFSC PORTB_ANTERIOR, 4
    GOTO RECHAZAR
    BTFSS PORTB_ACTUAL,4
    GOTO RECHAZAR
    ;-------------
    MOVF TEM1,W
    MOVWF SEMAFORO1
    MOVWF CONTADOR1
    MOVF TEM2,W
    MOVWF CONTADOR2
    MOVWF SEMAFORO2
    MOVF TEM3,W
    MOVWF SEMAFORO3
    MOVWF CONTADOR3
    MOVLW 1
    MOVWF ENTRO_INT
    CLRF OPCION
    CLRF OPCION_SEM
    BCF T2CON,2
 SECUENCIA: ;Secuencia de reseteo del semaforo, Prendemos los leds en orden 
    CLRF PORTC
    BSF	PORTA,0
    BSF	PORTA,3
    BSF	PORTA,6
    CALL delay_big
    BSF PORTA,1
    BSF PORTA,4
    BSF PORTA,7
    CALL delay_big
    BSF PORTA, 2
    BSF PORTA, 5
    BSF PORTB, 0
    CALL delay_big
    CLRF PORTA
    BCF PORTB,0
    BSF PORTA,2
    BSF PORTA,3
    BSF PORTA,6
    RETURN
 RECHAZAR:	;Subrutina para rechazar los cambios de los tiempos en la config
    BTFSC PORTB_ANTERIOR,5
    GOTO INCREMENTAR_DECREMENTAR
    BTFSS PORTB_ACTUAL,5
    GOTO INCREMENTAR_DECREMENTAR
    CLRF OPCION
    MOVLW 1
    MOVWF ENTRO_INT
    RETURN
    
 INCREMENTAR_DECREMENTAR:   ;Subrutina para inc. y dec. el display de config
    BTFSC  PORTB_ANTERIOR,4 ;PARA INCREMENTAR
    GOTO DEC_OP1
    ;---- AQUI SIGUE SI ANTES ERA 0
    BTFSC PORTB_ACTUAL, 4
    INCF CONTADOR4,F
    MOVF CONTADOR4,W
    SUBLW 21
    BTFSS STATUS, 2
    GOTO DEC_OP1
    ; SI DA 0 LO ANTERIOR SE SIGUE AQUI
    MOVLW 10
    MOVWF CONTADOR4
    
 DEC_OP1:   ;Subrutina para hacer el over y underflow del display de config
    BTFSC  PORTB_ANTERIOR,5 ;PARA INCREMENTAR
    RETURN
    ;---- AQUI SIGUE SI ANTES ERA 0
    BTFSC PORTB_ACTUAL, 5
    DECF CONTADOR4,F
    MOVF CONTADOR4,W
    SUBLW 9
    BTFSS   STATUS,2
    RETURN
    ;--- --------- AQUI SIGUE SI LO ANTEOIRO DA 0
    MOVLW 20
    MOVWF CONTADOR4
    
    RETURN
      
CONFIG_PROG: ;Configuracion de los bits
    
    BSF STATUS, 5
    BSF STATUS, 6 ;Banco 3
    
    CLRF ANSEL
    CLRF ANSELH
    
    BSF STATUS, 5 ;Banco 1
    BCF STATUS, 6 ;Banco 1
    
    
    
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
    BSF INTCON, 3 ;INTERRUPCION DEL PUERTO B
    
    BSF IOCB, 4
    BSF IOCB, 6
    BSF IOCB, 5 ;ACTIVAR INTERRUPCION EN PIN 
    
    
    MOVLW 195
    MOVWF PR2 ;TIMER 2 CON EL CUAL SE COMPARA
    ;-- ACTIAR INTERRUPCION TMR2
    BSF PIE1, 1
    BCF STATUS, 5 ;Banco 0
   
    ;configuracion del tmr1 cada 0.5 s
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
    ;-- CONFIGURACION DEL TIMER 2
    MOVLW 11111011B
    MOVWF T2CON
     
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
    MOVWF   SEMAFORO1
    MOVWF SEMAFORO2
    MOVWF SEMAFORO3
    MOVLW   255
    MOVWF   CONTADOR_MUX
    MOVLW 0
    MOVWF VER_CONTADOR4
    MOVWF OPCION
    MOVLW 255
    MOVWF   PORTB_ACTUAL
    MOVWF PORTB_ANTERIOR
    MOVLW   1
    MOVWF    ENTRO_INT
    MOVLW 2
    MOVWF CONT_TMR1
    CLRF OPCION_SEM
    
    BSF PORTA,2
    BSF PORTA,3
    BSF PORTA,6 ;
    
    CLRF OPCION_TITILAR
    MOVLW 5
    MOVWF CONT_TMR2
    
LOOP:	;Loop general del programa
    BTFSC INTCON, 2; SI SE ENCIENDE LA BANDERA DEL TIMER 
    CALL MULTIPLEX
    BTFSC PIR1,0
    CALL ISR_TMR1
    BTFSC ENTRO_INT,0
    CALL OPCIONES
    
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
    
    
    BTFSS VER_CONTADOR4, 0
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

    
SALTAR_DISPLAY4: ;Subrutina para apagar el display cuando esta en el modo normal
    MOVLW 1
    BTFSC PORTD, 6
    MOVWF PORTD
    RETURN
    
DIVISION:	;Subrutina para separar las decenas y unidades de los contadores
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
  
 delay_big:		    ;Delay Big
    movlw   255		    ;valor inicial del contador 
    movwf   DELAY1
    call    delay_small	    ;rutina de delay
    decfsz  DELAY1, 1	    ;decrementar el contador
    goto    $-2		    ;ejecutar dos lineas atras
    return		    ;
    
 delay_small:		    ;Delay Small
    movlw   255		    ;valor inicial del contador 
    movwf   DELAY	    ;
    decfsz  DELAY, 1   ;decrementar el contador
    goto    $-1		    ;ejecutar linea anterior
    return	
 
    END