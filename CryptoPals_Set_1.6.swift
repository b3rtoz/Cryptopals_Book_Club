import Foundation

// Function to read the contents of a text file
func readTextFileContents(fileName: String) -> String? {
    // Get the URL for the file
    guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt") else {
        print("File not found.")
        return nil
    }
    
    // Read the contents of the file with specified encoding
    do {
        let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
        return fileContents
    } catch {
        print("Error reading file:", error)
        return nil
    }
}

// Function to convert a Base64 string into a hex string
func hexString(fromBase64 base64String: String) -> String? {
    guard let data = Data(base64Encoded: base64String) else {
        print("Invalid Base64 string.")
        return nil
    }
    
    let hexString = data.map { String(format: "%02hhx", $0) }.joined()
    return hexString
}

// Extension of String for converting hex strings into Data
extension String {
    var hexadecimalData: Data? {
        var hexString = self
        // Remove any spaces or newlines
        hexString = hexString.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
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

// Function to convert string into bytes
func stringToBytes(fromString string: String) -> [UInt8] {
    return [UInt8](string.utf8)
}

// Function to calculate the Hamming distance between two byte arrays
func hammingDistance(bytes1: [UInt8], bytes2: [UInt8]) -> Int? {
    // Hamming distance is only defined for equal-length arrays
    guard bytes1.count == bytes2.count else {
        return nil
    }

    var distance = 0
    for i in 0..<bytes1.count {
        let xorResult = bytes1[i] ^ bytes2[i]
        distance += xorResult.nonzeroBitCount
    }
    
    return distance
}

// Function to calculate the average normalized Hamming distance for a given key size
func averageNormalizedHammingDistance(data: [UInt8], keySize: Int) -> Double {
    let numBlocks = 10 // Number of blocks to compare
    var distances = [Double]()
    for i in 0..<numBlocks - 1 {
        let start1 = i * keySize
        let start2 = (i + 1) * keySize
        if start2 + keySize > data.count {
            break
        }
        let block1 = Array(data[start1..<start1 + keySize])
        let block2 = Array(data[start2..<start2 + keySize])
        if let distance = hammingDistance(bytes1: block1, bytes2: block2) {
            let normalizedDistance = Double(distance) / Double(keySize)
            distances.append(normalizedDistance)
        }
    }
    return distances.reduce(0, +) / Double(distances.count)
}

// Function to transpose data into blocks
func transposeData(_ data: [UInt8], blockSize: Int) -> [[UInt8]] {
    var blocks = [[UInt8]](repeating: [], count: blockSize)
    for (index, byte) in data.enumerated() {
        blocks[index % blockSize].append(byte)
    }
    return blocks
}

// ASCII scoring function
func scoreDecryptedText(_ bytes: [UInt8]) -> Double {
    var score = 0.0
    for decryptedByte in bytes {
        if (decryptedByte >= 65 && decryptedByte <= 90) || // 'A' to 'Z'
           (decryptedByte >= 97 && decryptedByte <= 122) || // 'a' to 'z'
            decryptedByte == 32 { // Space character
            score += 1.0
        } else {
            score -= 1.0 // Penalize non-letter characters
        }
    }
    return score
}

// Function to crack single-byte XOR
func singleByteXORCrack(_ bytes: [UInt8]) -> UInt8 {
    var bestKey: UInt8 = 0
    var highestScore = Double.leastNonzeroMagnitude
    for key in UInt8.min...UInt8.max {
        let decrypted = bytes.map { $0 ^ key }
        let score = scoreDecryptedText(decrypted)
        if score > highestScore {
            highestScore = score
            bestKey = key
        }
    }
    return bestKey
}

// Function to find the repeating key
func findRepeatingKey(transposedBlocks: [[UInt8]]) -> [UInt8] {
    var key = [UInt8]()
    for block in transposedBlocks {
        let keyByte = singleByteXORCrack(block)
        key.append(keyByte)
    }
    return key
}

// Function to decrypt the ciphertext using the repeating key
func decryptRepeatingKeyXOR(encryptedBytes: [UInt8], key: [UInt8]) -> [UInt8] {
    var decryptedBytes = [UInt8]()
    for (index, byte) in encryptedBytes.enumerated() {
        let keyByte = key[index % key.count]
        decryptedBytes.append(byte ^ keyByte)
    }
    return decryptedBytes
}

/* This code tests the Hamming distance function:

// Test strings (hamming distance should be 37)
let inputString1 = "this is a test"
let inputString2 = "wokka wokka!!!"

// Convert test strings to bytes
let bytes1 = stringToBytes(fromString: inputString1)
let bytes2 = stringToBytes(fromString: inputString2)

// Verify the Hamming distance function
if let distance = hammingDistance(bytes1: bytes1, bytes2: bytes2) {
    print("Hamming Distance between test strings: \(distance)") // Should be 37
} else {
    print("The input byte arrays have different lengths.")
}
 */

/* Main Code*/

// Read the Base64 enoded data from the input file
if let base64DataString = readTextFileContents(fileName: "CP_1.6_Input") {
    print("Reading encrypted Base64 data from file...")
    
    // Combine file lines into a single Base64 string
    let base64String = base64DataString.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
    
    // Convert Base64 string to hex string
    if let hexString = hexString(fromBase64: base64String) {
        
        // Convert hex string to data
        if let data = hexString.hexadecimalData {
            let encryptedBytes = [UInt8](data)
            
            // Determine probable key sizes
            var keySizeDistances: [(keySize: Int, distance: Double)] = []
            print("Determining probable key sizes...")
            for keySize in 2...40 {
                let distance = averageNormalizedHammingDistance(data: encryptedBytes, keySize: keySize)
                keySizeDistances.append((keySize, distance))
            }
            // Sort key sizes by normalized Hamming distance
            keySizeDistances.sort { $0.distance < $1.distance }
            
            // Choose top probable key sizes
            let probableKeySizes = keySizeDistances.prefix(1).map { $0.keySize }
            
            var decryptedMessages: [String] = []
            for keySize in probableKeySizes {
                // Transpose data into blocks
                let transposedBlocks = transposeData(encryptedBytes, blockSize: keySize)
                print("Transposing data into blocks...")
                // Find repeating key
                let key = findRepeatingKey(transposedBlocks: transposedBlocks)
                print("Finding repeating key...")
                // Decrypt the ciphertext
                let decryptedBytes = decryptRepeatingKeyXOR(encryptedBytes: encryptedBytes, key: key)
                if let decryptedMessage = String(bytes: decryptedBytes, encoding: .utf8) {
                    print("Key Size: \(keySize)")
                    print("Key: \(String(bytes: key, encoding: .utf8) ?? key.map { String(format: "%02x", $0) }.joined())")
                    print("Decrypted Message:")
                    print(decryptedMessage)
                    print("--------------------------------------------------")
                    decryptedMessages.append(decryptedMessage)
                } else {
                    print("Failed to decode decrypted bytes for key size \(keySize)")
                }
            }
        } else {
            print("Failed to convert hex string to data.")
        }
    } else {
        print("Failed to convert Base64 string to hex.")
    }
} else {
    print("Failed to read Base64 data from file.")
}
