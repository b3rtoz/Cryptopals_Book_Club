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

// Extension of String for converting hex strings into Data
extension String {
    var hexadecimalData: Data? {
        var hexString = self
        // Remove any spaces or newlines
        hexString = hexString.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
        guard !hexString.isEmpty else { return nil } // Ensure the string is not empty
        guard hexString.count % 2 == 0 else { return nil } // Hex string must have even length
        
        var data = Data(capacity: hexString.count / 2)
        var index = hexString.startIndex
        
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard nextIndex <= hexString.endIndex else { return nil } // Ensure we don't go out of bounds
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

// Function to split data into blocks
func splitIntoBlocks(data: Data, blockSize: Int) -> [Data] {
    var blocks = [Data]()
    let totalBlocks = data.count / blockSize
    for i in 0..<totalBlocks {
        let start = i * blockSize
        let end = start + blockSize
        let block = data[start..<end]
        blocks.append(block)
    }
    return blocks
}

// Function to count repeated blocks
func countRepeatedBlocks(data: Data, blockSize: Int) -> Int {
    let blocks = splitIntoBlocks(data: data, blockSize: blockSize)
    var blockSet = Set<Data>()
    var repeatCount = 0
    for block in blocks {
        if blockSet.contains(block) {
            repeatCount += 1
        } else {
            blockSet.insert(block)
        }
    }
    return repeatCount
}

// Read the input pile and process each line
if let ciphertext = readTextFileContents(fileName: "CP_1.8_Input") {
    let content = ciphertext
    let lines = content.components(separatedBy: .newlines)
    var maxRepeats = 0
    var ecbLineNumber = 0
    var ecbCiphertext = ""
    
    for (index, line) in lines.enumerated() {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLine.isEmpty else { continue } // Skip empty lines
        
        if let data = trimmedLine.hexadecimalData {
            let repeats = countRepeatedBlocks(data: data, blockSize: 16)
            if repeats > maxRepeats {
                maxRepeats = repeats
                ecbLineNumber = index + 1
                ecbCiphertext = trimmedLine
            }
        } else {
            print("Failed to convert line \(index + 1) to data.")
        }
    }
    if ecbLineNumber > 0 {
        print("ECB encrypted ciphertext found at line \(ecbLineNumber)")
        print("Ciphertext: \(ecbCiphertext)")
    }
}
