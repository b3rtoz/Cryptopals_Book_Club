import Foundation
import CryptoSwift


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

/* Main Code */
    
if let base64DataString = readTextFileContents(fileName: "CP_1.7_Input") {
    print("Reading encrypted Base64 data from file...")
        
    // Combine file lines into a single Base64 string
    let base64String = base64DataString.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
        
    // 16-byte key
    let keyString = "YELLOW SUBMARINE"
    guard let keyData = keyString.data(using: .utf8)
        else {
        fatalError("Failed to convert key to data.")
        }
        
    // Decode Base64 String
    guard let encryptedData = Data(base64Encoded: base64String) else {
        fatalError("Failed to decode Base64 string.")
    }
        
    do {
        // Decrypt the data using AES-128 ECB
        let decryptedBytes = try AES(key: keyData.bytes, blockMode: ECB(), padding: .pkcs7).decrypt(encryptedData.bytes)
        let decryptedData = Data(decryptedBytes)
        if let decryptedMessage = String(data: decryptedData, encoding: .utf8) {
            print("Decrypted Message:")
            print(decryptedMessage)
            print("--------------------------------------------------")
        } else {
            print("Failed to convert decrypted data to string.")
        }
    } catch {
        print("Decryption failed with error:" , error)
    }
}
