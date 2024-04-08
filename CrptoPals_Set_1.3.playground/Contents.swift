import Foundation

// Extension to convert hexadecimal strings to byte arrays
extension String {
    var hexadecimalData: Data? {
        var hexString = self
        // Remove any spaces or non-hex characters
        hexString = hexString.replacingOccurrences(of: " ", with: "")
        guard hexString.count % 2 == 0 else { return nil } // Hex string must have even length
        
        var data = Data(capacity: hexString.count / 2)
        var index = hexString.startIndex
        
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2)
            if let byte = UInt8(hexString[index..<nextIndex], radix: 16) {
                data.append(byte)
            } else {
                return nil // Invalid hex character
            }
            index = nextIndex
        }
        return data
    }
}

func decryptSingleByteXOR(_ hexString: String) -> (key: UInt8, plaintext: String)? {
    guard let data = hexString.hexadecimalData else {
        return nil
    }
    
    var maxScore = 0
    var bestKey: UInt8 = 0
    var bestPlaintext = ""
    
    // Try XOR with every possible single byte
    for key in 0...255 {
        var plaintext = ""
        var score = 0
        
        // Perform XOR operation with the key
        for byte in data {
            let decryptedByte = byte ^ UInt8(key)
            plaintext += String(format: "%c", decryptedByte)
            
            // Score plaintext based on ASCII character. If it is not A-Z, a-z, or " ", score is not incremented
            if (decryptedByte >= 65 && decryptedByte <= 90) || (decryptedByte >= 97 && decryptedByte <= 122) || decryptedByte == 32 {
                score += 1
            }
        }
        
        // Update best key and plaintext if score is higher
        if score > maxScore {
            maxScore = score
            bestKey = UInt8(key)
            bestPlaintext = plaintext
        }
    }
    
    return (bestKey, bestPlaintext)
}

//set hex sting to decrypt
let hexString = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"

print("CryptoPals Challenge Set 1.3\n")

if let (key, plaintext) = decryptSingleByteXOR(hexString) {
    print("Decrypted using key \(key): \(plaintext)")
} else {
    print("Invalid input.")
}
