.MODEL SMALL
.STACK 100H

.DATA

; ================= TITLE =================
title1 DB 13,10
       DB '===============================================',13,10
       DB '  END-TO-END SECURE COMMUNICATION SYSTEM',13,10
       DB '       8086 ASSEMBLY LANGUAGE',13,10
       DB '===============================================',13,10,'$'

; ================= MENU =================
menu DB 13,10
     DB '--------------- MAIN MENU ----------------',13,10
     DB '1. Enter Message',13,10
     DB '2. Encrypt Message',13,10
     DB '3. Generate Checksum',13,10
     DB '4. Simulate Transmission',13,10
     DB '5. Verify Received Data',13,10
     DB '6. Decrypt Message',13,10
     DB '7. Display Status',13,10
     DB '8. Exit',13,10
     DB '-------------------------------------------',13,10
     DB 'Enter your choice: $'

; ================= MESSAGES =================
msgInput DB 13,10,'Enter message: $'

msgStored DB 13,10,'Message stored successfully.$'

msgEncrypt DB 13,10
           DB 'Message encrypted successfully.',13,10
           DB 'Encrypted Message: $'

msgDecrypt DB 13,10
           DB 'Message decrypted successfully.',13,10
           DB 'Decrypted Message: $'

msgChecksum DB 13,10,'Checksum generated: $'

msgTransmit DB 13,10,'Transmission started...',13,10,'$'

msgAskError DB 'Inject a transmission error? (Y/N): $'

msgError DB 'Transmission error injected!',13,10
         DB 'Received data has been modified.$'

msgClean DB 'Transmission completed without errors.$'

msgVerify DB 13,10,'Checking received data...',13,10,'$'

msgValid DB 'Checksum MATCHED.',13,10
         DB 'Data integrity verified.$'

msgInvalid DB 'Checksum MISMATCH!',13,10
           DB 'Data may be corrupted.$'

msgNoMessage      DB 13,10,'Please enter a message first.$'
msgNoEncryption   DB 13,10,'Please encrypt the message first.$'
msgNoChecksum     DB 13,10,'Please generate checksum first.$'
msgNoTransmission DB 13,10,'Please simulate transmission first.$'
msgNoVerification DB 13,10,'Please verify the received data first.$'

msgCorrupted DB 13,10
             DB 'Decryption stopped because the data is corrupted.$'

; ================= STATUS =================
msgStatus DB 13,10
          DB '------------- SYSTEM STATUS -------------',13,10,'$'

statusMsg1 DB 'Message Entered   : $'
statusMsg2 DB 13,10,'Message Encrypted : $'
statusMsg3 DB 13,10,'Checksum          : $'
statusMsg4 DB 13,10,'Transmission      : $'
statusMsg5 DB 13,10,'Verification      : $'

yesMsg     DB 'YES$'
noMsg      DB 'NO$'
successMsg DB 'SUCCESS$'
failedMsg  DB 'FAILED$'
notDoneMsg DB 'NOT PERFORMED$'

; ================= EXIT / OTHER =================
msgExit DB 13,10
        DB 'Exiting Secure Communication System...',13,10
        DB 'Thank you!$'

invalidChoice DB 13,10,'Invalid choice. Please select 1-8.$'

newline DB 13,10,'$'

; ================= PASSWORD =================
passwordMsg DB 13,10,'Enter security password: $'
correctPass DB '1234'
passBuffer  DB 4 DUP(?)

accessGranted DB 13,10,'Access Granted!',13,10,'$'
accessDenied  DB 13,10,'Access Denied!$'

; ================= INPUT BUFFERS =================
inputBuffer DB 50           ; max chars (incl. ENTER) -> 49 usable
            DB 0
            DB 50 DUP(?)

menuBuffer  DB 3
            DB 0
            DB 3 DUP(?)

; ================= MESSAGE BUFFERS =================
originalMsg  DB 51 DUP('$')
encryptedMsg DB 51 DUP('$')
receivedMsg  DB 51 DUP('$')
decryptedMsg DB 51 DUP('$')

; ================= CHECKSUM =================
originalChecksum DW 0
receivedChecksum DW 0

; ================= FLAGS =================
messageEntered     DB 0
messageEncrypted   DB 0
checksumGenerated  DB 0
transmissionDone   DB 0
errorInjected      DB 0
verificationDone   DB 0
verificationResult DB 0

; ================= CAESAR KEY =================
cipherKey DB 3


.CODE

; =========================================================
;                         MAIN
; =========================================================
MAIN PROC

    MOV AX,@DATA
    MOV DS,AX

    CALL CLEAR_SCREEN

    LEA DX,title1
    CALL PRINT_STRING

    CALL LOGIN
    CMP AL,1
    JE START_SYSTEM

    LEA DX,accessDenied
    CALL PRINT_STRING
    JMP EXIT_PROGRAM

START_SYSTEM:
    LEA DX,accessGranted
    CALL PRINT_STRING

MAIN_LOOP:
    LEA DX,menu
    CALL PRINT_STRING

    CALL READ_MENU_CHOICE

    CMP AL,'1'
    JE OPTION_1
    CMP AL,'2'
    JE OPTION_2
    CMP AL,'3'
    JE OPTION_3
    CMP AL,'4'
    JE OPTION_4
    CMP AL,'5'
    JE OPTION_5
    CMP AL,'6'
    JE OPTION_6
    CMP AL,'7'
    JE OPTION_7
    CMP AL,'8'
    JE EXIT_PROGRAM

    LEA DX,invalidChoice
    CALL PRINT_STRING
    JMP MAIN_LOOP

OPTION_1:
    CALL ENTER_MESSAGE
    JMP MAIN_LOOP
OPTION_2:
    CALL ENCRYPT_MESSAGE
    JMP MAIN_LOOP
OPTION_3:
    CALL GENERATE_CHECKSUM
    JMP MAIN_LOOP
OPTION_4:
    CALL TRANSMIT_MESSAGE
    JMP MAIN_LOOP
OPTION_5:
    CALL VERIFY_DATA
    JMP MAIN_LOOP
OPTION_6:
    CALL DECRYPT_MESSAGE
    JMP MAIN_LOOP
OPTION_7:
    CALL DISPLAY_STATUS
    JMP MAIN_LOOP

EXIT_PROGRAM:
    LEA DX,msgExit
    CALL PRINT_STRING

    MOV AH,4CH
    INT 21H

MAIN ENDP


; =========================================================
;   LOGIN  (returns AL = 1 if password correct, else 0)
;   Password is masked with '*'. Exactly 4 chars required.
; =========================================================
LOGIN PROC

    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    LEA DX,passwordMsg
    CALL PRINT_STRING

    LEA SI,passBuffer
    XOR BX,BX                   ; BX = number of chars typed

LOGIN_READ:
    MOV AH,08H                  ; read char, no echo
    INT 21H

    CMP AL,0DH                  ; ENTER ends input
    JE LOGIN_ENTER

    CMP BX,4                    ; only store first 4 chars
    JAE LOGIN_SKIP_STORE
    MOV [SI],AL
    INC SI

LOGIN_SKIP_STORE:
    INC BX

    MOV DL,'*'
    MOV AH,02H
    INT 21H

    JMP LOGIN_READ

LOGIN_ENTER:
    LEA DX,newline
    CALL PRINT_STRING

    CMP BX,4                    ; length must be exactly 4
    JNE LOGIN_FAIL

    LEA SI,passBuffer
    LEA DI,correctPass
    MOV CX,4

COMPARE_PASSWORD:
    MOV AL,[SI]
    CMP AL,[DI]
    JNE LOGIN_FAIL
    INC SI
    INC DI
    LOOP COMPARE_PASSWORD

    MOV AL,1
    JMP LOGIN_DONE

LOGIN_FAIL:
    MOV AL,0

LOGIN_DONE:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    RET

LOGIN ENDP


; =========================================================
;   READ MENU CHOICE  (returns first character in AL)
; =========================================================
READ_MENU_CHOICE PROC

    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA DX,menuBuffer
    MOV AH,0AH
    INT 21H

    MOV AL,[menuBuffer+1]       ; number of chars entered
    CMP AL,0
    JE EMPTY_MENU_CHOICE

    MOV AL,[menuBuffer+2]       ; first char
    JMP MENU_CHOICE_DONE

EMPTY_MENU_CHOICE:
    MOV AL,0

MENU_CHOICE_DONE:
    LEA DX,newline
    CALL PRINT_STRING           ; PRINT_STRING preserves AL

    POP SI
    POP DX
    POP CX
    POP BX
    RET

READ_MENU_CHOICE ENDP


; =========================================================
;   ENTER MESSAGE
; =========================================================
ENTER_MESSAGE PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    LEA DX,msgInput
    CALL PRINT_STRING

    LEA DX,inputBuffer
    MOV AH,0AH
    INT 21H

    MOV BL,[inputBuffer+1]
    MOV BH,0

    LEA SI,inputBuffer+2
    LEA DI,originalMsg

    MOV CX,BX
    CMP CX,0
    JE STORE_EMPTY

COPY_MESSAGE:
    MOV AL,[SI]
    CMP AL,'$'                  ; '$' would break DOS string printing
    JNE COPY_STORE
    MOV AL,'_'                  ; replace it with '_'
COPY_STORE:
    MOV [DI],AL
    INC SI
    INC DI
    LOOP COPY_MESSAGE

STORE_EMPTY:
    MOV BYTE PTR [DI],'$'

    MOV messageEntered,1
    MOV messageEncrypted,0
    MOV checksumGenerated,0
    MOV transmissionDone,0
    MOV errorInjected,0
    MOV verificationDone,0
    MOV verificationResult,0

    LEA DX,msgStored
    CALL PRINT_STRING

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET

ENTER_MESSAGE ENDP


; =========================================================
;   ENCRYPT MESSAGE  (Caesar cipher)
; =========================================================
ENCRYPT_MESSAGE PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    CMP messageEntered,1
    JE ENCRYPT_START

    LEA DX,msgNoMessage
    CALL PRINT_STRING
    JMP ENCRYPT_FINISH

ENCRYPT_START:
    LEA SI,originalMsg
    LEA DI,encryptedMsg

    MOV BL,cipherKey
    MOV BH,0

ENCRYPT_LOOP:
    MOV AL,[SI]
    CMP AL,'$'
    JE ENCRYPT_DONE

    ; uppercase?
    CMP AL,'A'
    JB CHECK_LOWER
    CMP AL,'Z'
    JA CHECK_LOWER

    ADD AL,BL
    CMP AL,'Z'
    JBE STORE_ENCRYPTED
    SUB AL,26
    JMP STORE_ENCRYPTED

CHECK_LOWER:
    CMP AL,'a'
    JB STORE_ENCRYPTED
    CMP AL,'z'
    JA STORE_ENCRYPTED

    ADD AL,BL
    CMP AL,'z'
    JBE STORE_ENCRYPTED
    SUB AL,26

STORE_ENCRYPTED:
    MOV [DI],AL
    INC SI
    INC DI
    JMP ENCRYPT_LOOP

ENCRYPT_DONE:
    MOV BYTE PTR [DI],'$'

    MOV messageEncrypted,1

    ; anything after encryption must be redone
    MOV checksumGenerated,0
    MOV transmissionDone,0
    MOV errorInjected,0
    MOV verificationDone,0
    MOV verificationResult,0

    LEA DX,msgEncrypt
    CALL PRINT_STRING
    LEA DX,encryptedMsg
    CALL PRINT_STRING

ENCRYPT_FINISH:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET

ENCRYPT_MESSAGE ENDP


; =========================================================
;   GENERATE CHECKSUM  (16-bit sum of encrypted bytes)
; =========================================================
GENERATE_CHECKSUM PROC

    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI

    CMP messageEncrypted,1
    JE CHECKSUM_START

    LEA DX,msgNoEncryption
    CALL PRINT_STRING
    JMP CHECKSUM_FINISH

CHECKSUM_START:
    LEA SI,encryptedMsg
    XOR BX,BX

CHECKSUM_LOOP:
    MOV AL,[SI]
    CMP AL,'$'
    JE CHECKSUM_DONE

    MOV AH,0
    ADD BX,AX
    INC SI
    JMP CHECKSUM_LOOP

CHECKSUM_DONE:
    MOV originalChecksum,BX
    MOV checksumGenerated,1

    ; a new checksum invalidates old transmission results
    MOV transmissionDone,0
    MOV errorInjected,0
    MOV verificationDone,0
    MOV verificationResult,0

    LEA DX,msgChecksum
    CALL PRINT_STRING

    MOV AX,BX
    CALL PRINT_NUMBER

CHECKSUM_FINISH:
    POP SI
    POP DX
    POP BX
    POP AX
    RET

GENERATE_CHECKSUM ENDP


; =========================================================
;   SIMULATE TRANSMISSION  (user chooses whether to inject error)
; =========================================================
TRANSMIT_MESSAGE PROC

    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI
    PUSH DI

    CMP checksumGenerated,1
    JE TRANSMISSION_START

    LEA DX,msgNoChecksum
    CALL PRINT_STRING
    JMP TRANSMISSION_FINISH

TRANSMISSION_START:
    LEA DX,msgTransmit
    CALL PRINT_STRING

    ; copy encrypted -> received
    LEA SI,encryptedMsg
    LEA DI,receivedMsg

COPY_RECEIVED:
    MOV AL,[SI]
    CMP AL,'$'
    JE COPY_DONE

    MOV [DI],AL
    INC SI
    INC DI
    JMP COPY_RECEIVED

COPY_DONE:
    MOV BYTE PTR [DI],'$'

    MOV errorInjected,0
    MOV verificationDone,0
    MOV verificationResult,0

    ; ask whether to inject an error
    LEA DX,msgAskError
    CALL PRINT_STRING

    MOV AH,01H                  ; read one key (no ENTER needed)
    INT 21H

    PUSH AX
    LEA DX,newline
    CALL PRINT_STRING
    POP AX

    CMP AL,'Y'
    JE INJECT_ERROR
    CMP AL,'y'
    JE INJECT_ERROR
    JMP TRANSMISSION_NO_ERROR

INJECT_ERROR:
    LEA SI,receivedMsg
    MOV AL,[SI]
    CMP AL,'$'                  ; empty message -> nothing to corrupt
    JE TRANSMISSION_NO_ERROR

    INC AL                      ; corrupt first character
    CMP AL,'$'                  ; never create a fake terminator
    JNE STORE_CORRUPT
    INC AL
STORE_CORRUPT:
    MOV [SI],AL

    MOV errorInjected,1

    LEA DX,msgError
    CALL PRINT_STRING
    JMP TRANSMISSION_COMPLETE

TRANSMISSION_NO_ERROR:
    MOV errorInjected,0
    LEA DX,msgClean
    CALL PRINT_STRING

TRANSMISSION_COMPLETE:
    MOV transmissionDone,1

TRANSMISSION_FINISH:
    POP DI
    POP SI
    POP DX
    POP BX
    POP AX
    RET

TRANSMIT_MESSAGE ENDP


; =========================================================
;   VERIFY DATA
; =========================================================
VERIFY_DATA PROC

    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI

    CMP transmissionDone,1
    JE VERIFY_START

    LEA DX,msgNoTransmission
    CALL PRINT_STRING
    JMP VERIFY_FINISH

VERIFY_START:
    LEA DX,msgVerify
    CALL PRINT_STRING

    LEA SI,receivedMsg
    XOR BX,BX

VERIFY_CHECKSUM_LOOP:
    MOV AL,[SI]
    CMP AL,'$'
    JE VERIFY_CHECKSUM_DONE

    MOV AH,0
    ADD BX,AX
    INC SI
    JMP VERIFY_CHECKSUM_LOOP

VERIFY_CHECKSUM_DONE:
    MOV receivedChecksum,BX

    MOV AX,originalChecksum
    CMP AX,receivedChecksum
    JE DATA_VALID

DATA_INVALID:
    MOV verificationResult,0
    MOV verificationDone,1

    LEA DX,msgInvalid
    CALL PRINT_STRING
    JMP VERIFY_FINISH

DATA_VALID:
    MOV verificationResult,1
    MOV verificationDone,1

    LEA DX,msgValid
    CALL PRINT_STRING

VERIFY_FINISH:
    POP SI
    POP DX
    POP BX
    POP AX
    RET

VERIFY_DATA ENDP


; =========================================================
;   DECRYPT MESSAGE
; =========================================================
DECRYPT_MESSAGE PROC

    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI
    PUSH DI

    CMP verificationDone,1
    JE DECRYPT_CHECK

    LEA DX,msgNoVerification
    CALL PRINT_STRING
    JMP DECRYPT_FINISH

DECRYPT_CHECK:
    CMP verificationResult,1
    JE DECRYPT_START

    LEA DX,msgCorrupted
    CALL PRINT_STRING
    JMP DECRYPT_FINISH

DECRYPT_START:
    LEA SI,receivedMsg
    LEA DI,decryptedMsg

    MOV BL,cipherKey
    MOV BH,0

DECRYPT_LOOP:
    MOV AL,[SI]
    CMP AL,'$'
    JE DECRYPT_DONE

    ; uppercase?
    CMP AL,'A'
    JB CHECK_LOWER_DEC
    CMP AL,'Z'
    JA CHECK_LOWER_DEC

    SUB AL,BL
    CMP AL,'A'
    JAE STORE_DECRYPTED
    ADD AL,26
    JMP STORE_DECRYPTED

CHECK_LOWER_DEC:
    CMP AL,'a'
    JB STORE_DECRYPTED
    CMP AL,'z'
    JA STORE_DECRYPTED

    SUB AL,BL
    CMP AL,'a'
    JAE STORE_DECRYPTED
    ADD AL,26

STORE_DECRYPTED:
    MOV [DI],AL
    INC SI
    INC DI
    JMP DECRYPT_LOOP

DECRYPT_DONE:
    MOV BYTE PTR [DI],'$'

    LEA DX,msgDecrypt
    CALL PRINT_STRING
    LEA DX,decryptedMsg
    CALL PRINT_STRING

DECRYPT_FINISH:
    POP DI
    POP SI
    POP DX
    POP BX
    POP AX
    RET

DECRYPT_MESSAGE ENDP


; =========================================================
;   DISPLAY STATUS
; =========================================================
DISPLAY_STATUS PROC

    PUSH AX
    PUSH DX

    LEA DX,msgStatus
    CALL PRINT_STRING

    ; ---- Message entered ----
    LEA DX,statusMsg1
    CALL PRINT_STRING

    CMP messageEntered,1
    JE STATUS_MESSAGE_YES
    LEA DX,noMsg
    CALL PRINT_STRING
    JMP STATUS_ENCRYPTED

STATUS_MESSAGE_YES:
    LEA DX,yesMsg
    CALL PRINT_STRING

    ; ---- Message encrypted ----
STATUS_ENCRYPTED:
    LEA DX,statusMsg2
    CALL PRINT_STRING

    CMP messageEncrypted,1
    JE STATUS_ENCRYPTED_YES
    LEA DX,noMsg
    CALL PRINT_STRING
    JMP STATUS_CHECKSUM

STATUS_ENCRYPTED_YES:
    LEA DX,yesMsg
    CALL PRINT_STRING

    ; ---- Checksum ----
STATUS_CHECKSUM:
    LEA DX,statusMsg3
    CALL PRINT_STRING

    CMP checksumGenerated,1
    JE STATUS_CHECKSUM_YES
    LEA DX,notDoneMsg
    CALL PRINT_STRING
    JMP STATUS_TRANSMISSION

STATUS_CHECKSUM_YES:
    MOV AX,originalChecksum
    CALL PRINT_NUMBER

    ; ---- Transmission ----
STATUS_TRANSMISSION:
    LEA DX,statusMsg4
    CALL PRINT_STRING

    CMP transmissionDone,1
    JE STATUS_TRANSMISSION_YES
    LEA DX,notDoneMsg
    CALL PRINT_STRING
    JMP STATUS_VERIFICATION

STATUS_TRANSMISSION_YES:
    CMP errorInjected,1
    JE STATUS_TRANSMISSION_FAILED
    LEA DX,successMsg
    CALL PRINT_STRING
    JMP STATUS_VERIFICATION

STATUS_TRANSMISSION_FAILED:
    LEA DX,failedMsg
    CALL PRINT_STRING

    ; ---- Verification ----
STATUS_VERIFICATION:
    LEA DX,statusMsg5
    CALL PRINT_STRING

    CMP verificationDone,1
    JE STATUS_VERIFICATION_DONE
    LEA DX,notDoneMsg
    CALL PRINT_STRING
    JMP STATUS_END

STATUS_VERIFICATION_DONE:
    CMP verificationResult,1
    JE STATUS_VERIFIED
    LEA DX,failedMsg
    CALL PRINT_STRING
    JMP STATUS_END

STATUS_VERIFIED:
    LEA DX,successMsg
    CALL PRINT_STRING

STATUS_END:
    POP DX
    POP AX
    RET

DISPLAY_STATUS ENDP


; =========================================================
;   PRINT STRING  (DX = offset of '$'-terminated string)
;   Preserves AX: INT 21h/09h overwrites AL with '$' (24h)
; =========================================================
PRINT_STRING PROC

    PUSH AX
    MOV AH,09H
    INT 21H
    POP AX
    RET

PRINT_STRING ENDP


; =========================================================
;   PRINT NUMBER  (AX = unsigned 16-bit value)
; =========================================================
PRINT_NUMBER PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX,0
    JNE CONVERT_NUMBER

    MOV DL,'0'
    MOV AH,02H
    INT 21H
    JMP PRINT_NUMBER_DONE

CONVERT_NUMBER:
    XOR CX,CX
    MOV BX,10

NUMBER_LOOP:
    XOR DX,DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX,0
    JNE NUMBER_LOOP

PRINT_DIGITS:
    POP DX
    ADD DL,'0'
    MOV AH,02H
    INT 21H
    LOOP PRINT_DIGITS

PRINT_NUMBER_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET

PRINT_NUMBER ENDP


; =========================================================
;   CLEAR SCREEN
; =========================================================
CLEAR_SCREEN PROC

    MOV AX,0600H
    MOV BH,07H
    MOV CX,0000H
    MOV DX,184FH
    INT 10H

    MOV AH,02H
    MOV BH,00H
    MOV DX,0000H
    INT 10H

    RET

CLEAR_SCREEN ENDP

END MAIN