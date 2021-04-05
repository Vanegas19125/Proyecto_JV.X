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
    
;    BCF OPTION_REG, 7 ;Pull ups puerto B
;    BCF OPTION_REG, 5 ;Clok interno
;    BCF OPTION_REG, 3 ;Prescaler
;    BSF OPTION_REG, 2 ;Prescaler a 256
;    BSF OPTION_REG, 1
;    BSF OPTION_REG, 0
    
;    BSF INTCON, 7 ;INTERRUPCION GLOBAL
;    BSF INTCON, 5 ;INTERRUPCION TIMER0
;    BSF INTCON, 3 ;INTERRUPCION DEL PUERTO B
;    
;    BSF IOCB, 0
;    BSF IOCB, 1 ;ACTIVAR INTERRUPCION EN PIN RB0 Y RB1
    
    BCF STATUS, 5 ;Banco 0
    
;    CLRF PORTA ;COLOCAR EN 0 puerto A
;    CLRF PORTB ;COLOCAR EN 0 puerto B
;    CLRF PORTC ;COLOCAR EN 0 puerto C
;    CLRF PORTD ;COLOCAR EN 0 puerto D


