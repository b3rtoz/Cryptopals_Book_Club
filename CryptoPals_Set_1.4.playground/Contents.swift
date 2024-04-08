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

func decryptSingleByteXOR(_ hexString: String) -> (key: UInt8, plaintext: String, score: Int)? {
    guard let data = hexString.hexadecimalData else {
        return nil
    }
    
    var maxScore = 0
    var bestKey: UInt8 = 0
    var bestPlaintext = ""
    var bestScore = 0
    
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
        
        // Update best key, plaintext, and score if score is higher
        if score > maxScore {
            maxScore = score
            bestKey = UInt8(key)
            bestPlaintext = plaintext
            bestScore = score
        }
    }
    
    return (bestKey, bestPlaintext, bestScore)
}
//function to read .txt file
func readTextFile(fileName: String) -> [String]? {
    // Get the URL for the file
    guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt") else {
        print("File not found.")
        return nil
    }
    
    // Read the contents of the file
    do {
        let fileContents = try String(contentsOf: fileURL)
        // Split the contents by newline character to get an array strings
        let hexStrings = fileContents.components(separatedBy: .newlines)
        return hexStrings
    } catch {
        print("Error reading file:", error)
        return nil
    }
}

print("CryptoPals Challenge Set 1.4\n Finding encyrpted message...\n")

if let hexStrings = readTextFile(fileName: "CryptoPals_1.4_Input") {
    var maxScore = 0
    var bestDecryption: (key: UInt8, plaintext: String, score: Int)? = nil
    
    // Iterate through each hex string
    for hexString in hexStrings {
        if let decryption = decryptSingleByteXOR(hexString) {
            if decryption.score > maxScore {
                maxScore = decryption.score
                bestDecryption = decryption
            }
        } else {
            print("Invalid input.")
        }
    }
    
    // Print the decryption with the highest score
    if let bestDecryption = bestDecryption {
        print("Decrypted using key \(bestDecryption.key)\n Decrypted message: \(bestDecryption.plaintext)")
    } else {
        print("No valid decryption found.")
    }
}
