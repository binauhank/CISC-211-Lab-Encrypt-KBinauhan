/*** asmEncrypt.s   ***/

/* Declare the following to be in data memory */
.data  

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Kristian Binauhan"  
.align
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

/* Define the globals so that the C code can access them */
/* (in this lab we return the pointer, so strictly speaking, */
/* does not really need to be defined as global) */
/* .global cipherText */
.type cipherText,%gnu_unique_object

.align
 
/* NOTE: THIS .equ MUST MATCH THE #DEFINE IN main.c !!!!!
 * TODO: create a .h file that handles both C and assembly syntax for this definition */
.equ CIPHER_TEXT_LEN, 200
 
/* space allocated for cipherText: 200 bytes, prefilled with 0x2A */
cipherText: .space CIPHER_TEXT_LEN,0x2A  

.align
 
.global cipherTextPtr
.type cipherTextPtr,%gnu_unique_object
cipherTextPtr: .word cipherText

/* Tell the assembler that what follows is in instruction memory     */
.text
.align

/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

    
/********************************************************************
function name: asmEncrypt
function description:
     pointerToCipherText = asmEncrypt ( ptrToInputText , key )
     
where:
     input:
     ptrToInputText: location of first character in null-terminated
                     input string. Per calling convention, passed in via r0.
     key:            shift value (K). Range 0-25. Passed in via r1.
     
     output:
     pointerToCipherText: mem location (address) of first character of
                          encrypted text. Returned in r0
     
     function description: asmEncrypt reads each character of an input
                           string, uses a shifted alphabet to encrypt it,
                           and stores the new character value in memory
                           location beginning at "cipherText". After copying
                           a character to cipherText, a pointer is incremented 
                           so that the next letter is stored in the bext byte.
                           Only encrypt characters in the range [a-zA-Z].
                           Any other characters should just be copied as-is
                           without modifications
                           Stop processing the input string when a NULL (0)
                           byte is reached. Make sure to add the NULL at the
                           end of the cipherText string.
     
     notes:
        The return value will always be the mem location defined by
        the label "cipherText".
     
     
********************************************************************/    
.global asmEncrypt
.type asmEncrypt,%function
asmEncrypt:   

    /* DON'T FORGET TO FOLLOW THE ARM CALLING CONVENTION!  */

    /* YOUR asmEncrypt CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    push {r4-r11, LR}
    
    LDR R4, [R0] /* Load value from address into R4 */
    
    /* Detect if byte is ASCII, leading byte, or continuation byte */
    MOV R5, 0x0 /* 0xxxxxxx (ASCII) */
    LSR R6, R0, 7 /* Clear all bits in R0 except MSB */
    LSL R6, R6, 7 /* Move it back to MSB */
    CMP R6, R5
    BEQ isAscii /* Branch if character is ASCII */
    
    pop {r4-r11, LR}
    
    BX LR
    
isAscii:
    /* Check for uppercase or lowercase */
    CMP R4, 97 /* In decimal, uppercase range is 65 - 90, lowercase range is 97 - 122 */
    CMPHS R4, 123 /* Check if within lowercase range if above or equal to 97 */
    BHS asciiIsNonAlphabet /* If not within lowercase range, branch */
    BLO asciiIsLowercase
    
    /* ASCII is either uppercase or non-alphabet */
    /* Checks if within uppercase range, branches if not */
    CMP R4, 48
    BLO asciiIsNonAlphabet /* < 48 */
    CMP R4, 90 
    BHI asciiIsNonAlphabet /* > 90 (not lowercase) */
    
    /* ASCII is uppercase, shift by K (value in R1) */
    ADD R4, R4, R1
    CMP R4, 90
    SUBHI R5, R4, 90 /* If higher than 90, subtract value by 90 to get number needed for wraparound */
    ADDHI R4, R4, 64 /* Wrap around starting with A (65) */
    
    STR R4, [R0]
    
    pop {r4-r11, LR}
    
    BX LR
    
asciiIsLowercase:
    ADD R4, R4, R1
    CMP R4, 122
    SUBHI R5, R4, 122
    SUBHI R4, R4, 96
    
    STR R4, [R0]
    
    pop {r4-r11, LR}
    
    BX LR
    
asciiIsNonAlphabet:
    STR R4, [R0]
    
    pop {r4-r11, LR}
    
    BX LR
    
    /* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




