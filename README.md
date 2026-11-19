# 🔐 End-to-End Secure Communication System

An educational **8086 Assembly Language** project that simulates a secure communication process, demonstrating message encryption, transmission, and data integrity verification.

## 📌 Overview

The End-to-End Secure Communication System demonstrates how a message can be protected before transmission and verified after receiving it.

The system uses password-based authentication, Caesar Cipher encryption, checksum generation, simulated transmission, and checksum comparison to detect data corruption.

## ✨ Features

- **Password Authentication:** Protects system access with a password.
- **Message Input:** Allows users to enter messages.
- **Caesar Cipher Encryption:** Encrypts messages using a shift key of 3.
- **Checksum Generation:** Calculates a 16-bit checksum from encrypted message bytes.
- **Simulated Transmission:** Transfers encrypted messages to a receiving buffer.
- **Error Injection:** Simulates transmission errors by modifying received data.
- **Data Integrity Verification:** Compares original and received checksums.
- **Message Decryption:** Decrypts messages only after successful verification.
- **System Status:** Displays the current progress of communication operations.

## ⚙️ Technologies Used

- 8086 Assembly Language
- MASM/TASM-compatible syntax
- DOS Interrupts
- DOSBox (for DOS-based execution)

## 🔄 System Workflow

1. User logs in using the security password.
2. User enters a message.
3. The system encrypts the message using Caesar Cipher.
4. A checksum is generated from the encrypted message.
5. The encrypted message is transmitted.
6. The user can optionally inject a transmission error.
7. The receiver verifies data integrity using checksum comparison.
8. If verification succeeds, the original message is decrypted.

## 🚀 Getting Started

### Requirements

- An 8086-compatible assembler such as MASM or TASM.
- DOSBox or a compatible DOS environment.

### Execution

1. Clone or download this repository.
2. Open the project directory in your DOS environment.
3. Assemble and link the source file using your configured assembler.
4. Run the generated executable.

## 🔑 Default Login Password

```text
1234
```

## ⚠️ Educational Disclaimer

This project is developed for educational purposes to demonstrate fundamental concepts of encryption, transmission simulation, and data integrity.

The Caesar Cipher and additive checksum used here are not suitable for real-world security. The password is hardcoded in the source code, and this project should not be considered a production-ready secure communication solution.

## 👩‍💻 Author

**Neha Kumari**

Computer Science Student  
The Shaikh Ayaz University, Shikarpur

---

⭐ If you find this project interesting, consider giving the repository a star!
