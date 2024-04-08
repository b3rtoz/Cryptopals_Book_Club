import Foundation

func repeatingKeyXOREncrypt(_ plaintext: String, key: String) -> String? {
    let plaintextData = plaintext.data(using: .utf8)
    let keyData = key.data(using: .utf8)
    
    guard let plaintextBytes = plaintextData, let keyBytes = keyData else {
        return nil
    }
    
    let plaintextLength = plaintextBytes.count
    let keyLength = keyBytes.count
    var encryptedBytes = [UInt8]()
    
    for i in 0..<plaintextLength {
        let keyByteIndex = i % keyLength
        let encryptedByte = plaintextBytes[i] ^ keyBytes[keyByteIndex]
        encryptedBytes.append(encryptedByte)
    }
    
    let encryptedData = Data(encryptedBytes)
    let encryptedHexString = encryptedData.map { String(format: "%02x", $0) }.joined()
    
    return encryptedHexString
}

let plaintext = "Burning 'em, if you ain't quick and nimble I go crazy when I hear a cymbal"
let key = "ICE"

if let encrypted = repeatingKeyXOREncrypt(plaintext, key: key) {
    print("Encrypted text:")
    print(encrypted)
} else {
    print("Encryption failed.")
}
