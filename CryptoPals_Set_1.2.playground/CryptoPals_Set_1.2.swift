//Crypto Pals Challenge Set 1.2
import Foundation

// Extension to String to convert hexadecimal strings to byte arrays
extension String {
    var hexadecimalData: Data? {
        var hexString = self
        // Remove any spaces or non-hex characters
        hexString = hexString.replacingOccurrences(of: " ", with: "")
        // Hex string must have even length
        guard hexString.count % 2 == 0 else { return nil }
        
        var data = Data(capacity: hexString.count / 2)
        var index = hexString.startIndex
        
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2)
            if let byte = UInt8(hexString[index..<nextIndex], radix: 16) {
                data.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
        return data
    }
}

func xorCompareHexStrings(_ hexString1: String, _ hexString2: String) -> [UInt8]? {
    // Convert hexadecimal strings to byte arrays
    guard let data1 = hexString1.hexadecimalData, let data2 = hexString2.hexadecimalData else {
        return nil
    }
    
    // Check if byte arrays have the same length
    guard data1.count == data2.count else {
        return nil // Byte arrays must have the same length for XOR comparison
    }
    
    var result = [UInt8]()
    
    // Perform element-wise XOR operation
    for (byte1, byte2) in zip(data1, data2) {
        result.append(byte1 ^ byte2)
    }
    print(result)
    return result
}

print("CryptoPals Challenge Set 1.2\n")
// set two hex strings:
let hexString1 = "1c0111001f010100061a024b53535009181c"
let hexString2 = "686974207468652062756c6c277320657965"

if let result = xorCompareHexStrings(hexString1, hexString2) {
    let resultHex = result.map { String(format: "%02X", $0) }.joined()
    print("XOR Comparison Result: \(resultHex)")
} else {
    print("Invalid input or input length mismatch.")
}
