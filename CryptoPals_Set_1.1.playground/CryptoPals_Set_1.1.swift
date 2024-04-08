print("CryptoPals Challenge Set 1.1\n")
// Print strings
let pStep = ["Input hex string:", "\nStep 1: Converts the hex string into bytes\n", "\nStep 2: Translates the bytes into an array of 8-bit binary values \n",
                 "\nStep 3: Combines the 8-bit binary array into a single binary string", "\nStep 4: Divides the binry string into 6-bit binary bytes\n",
                 "\nStep 5: Translates the 6-bit binary bytes into Base64 values using the binToB64Table dictionary\n",
                 "\nStep 6: Converts the array of Base64 encoded characters into a Base64 string\n Base64 string:",
                 "\nStep 7: Extracts any potential encoded message from the byte array and displays in plain text\nEncoded text:"]

// convert initial hex string into integer bytes
func stringToBytes(inputString hexString: String) -> [UInt8]? {
    let length = hexString.count
    //make sure hex string length is even
    if length & 1 != 0 {
        print("\nInput hex string has an invalid odd length:", length)
        return nil
    } else {
        print("\nInput hex string is valid and contains", length/2, "bytes")
    }
    var byteArray = [UInt8]()
    byteArray.reserveCapacity(length/2)
    var index = hexString.startIndex
    for _ in 0..<length/2 {
        let nextIndex = hexString.index(index, offsetBy: 2)
        if let byte = UInt8(hexString[index..<nextIndex], radix: 16) {
            byteArray.append(byte)
        } else {
            return nil
        }
        index = nextIndex
    }
    return byteArray
}

// convert byteArray from bytes into an array of 8-bit binary strings
func bytesToBin(inputBytes byteArray: [UInt8]) -> [String] {
    var binArray = [String]()
    for eachByte in byteArray [0...] {
        var bins = String(eachByte, radix: 2)
        while bins.count != 8 {
            bins = "0" + bins
        }
        binArray.append(bins)
    }
    return binArray
}

// convert the array of 8-bit binary byte strings into a single binary string
func binsToString(inputBinArray binArray: [String]) -> String {
    var binString = String()
    for eachbin in binArray [0...] {
        let binStr = String(eachbin)
        binString.append(binStr)
    }
    return binString
}

// convert the binary string into an array of 6-bit binary byte strings
func sixBitBytes(inputBinString binString: String) -> [String]? {
    let length = binString.count
    print("Input binary is:", length, "bits which will be", length/6, "Base64 bytes")
    var sixBitArray = [String]()
    sixBitArray.reserveCapacity(length/6)
    var index = binString.startIndex
    for _ in 0..<length/6 {
        let nextIndex = binString.index(index, offsetBy: 6)
        if let byte = UInt(binString[index..<nextIndex]) {
            var newByte = String(byte)
            // add leading 0s to binary translation
            while newByte.count != 6 {
                newByte = "0" + newByte
            }
            sixBitArray.append(newByte)
        } else {
            return nil
        }
        index = nextIndex
    }
    return sixBitArray
}

// convert 6-bit string array to 1-char base64 array
func sixBitArrayToB64(inputBinArray sixBitArray: [String]) -> [String]? {
    var b64Array = [String]()
    for sixBitByte in sixBitArray [0...] {
        if let b64Char = binToB64Table[sixBitByte] {
            b64Array.append(b64Char)
        }
    }
    return b64Array
    }

// convert the array of bins into a single binary string
func b64ArrayToString(inputB64Array b64Array: [String]) -> String {
    var b64String = String()
    for eachChar in b64Array [0...] {
        let b64Char = String(eachChar)
        b64String.append(b64Char)
    }
    return b64String
    }

// Variable to store the input hex string
let hexString = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
print(pStep[0], hexString)

// Step 1: Converts the hex string into bytes
let byteArray = stringToBytes(inputString: hexString)
print(pStep[1], byteArray ?? [])

// Step 2: Translates the bytes into an array of 8-bit binary values
let binArray = bytesToBin(inputBytes: byteArray!)
print(pStep[2], binArray)

// Step 3: Combines the 8-bit binary array into a single binary string
let binString = binsToString(inputBinArray: binArray)
print(pStep[3], binString)

// Step 4: Divides the binry string into 6-bit binary bytes
let sixBitArray = sixBitBytes(inputBinString: binString)
print(pStep[4], sixBitArray ?? [])

// Step 4.5: Dictionary used as a lookup table in order to convert 6-bit binary value into Base64 character equivalent
let binToB64Table = ["000000": "A", "000001": "B", "000010": "C", "000011": "D", "000100": "E", "000101": "F", "000110": "G", "000111": "H",
                     "001000": "I", "001001": "J", "001010": "K", "001011": "L", "001100": "M", "001101": "N", "001110": "O", "001111": "P",
                     "010000": "Q", "010001": "R", "010010": "S", "010011": "T", "010100": "U", "010101": "V", "010110": "W", "010111": "X",
                     "011000": "Y", "011001": "Z", "011010": "a", "011011": "b", "011100": "c", "011101": "d", "011110": "e", "011111": "f",
                     "100000": "g", "100001": "h", "100010": "i", "100011": "j", "100100": "k", "100101": "l", "100110": "m", "100111": "n",
                     "101000": "o", "101001": "p", "101010": "q", "101011": "r", "101100": "s", "101101": "t", "101110": "u", "101111": "v",
                     "110000": "w", "110001": "x", "110010": "y", "110011": "z", "110100": "0", "110101": "1", "110110": "2", "110111": "3",
                     "111000": "4", "111001": "5", "111010": "6", "111011": "7", "111100": "8", "111101": "9", "111110": "+", "111111": "/"]


// Step 5: Translates the 6-bit binary bytes into Base64 values using the dictionary from step 4.5
let b64Array = sixBitArrayToB64(inputBinArray: sixBitArray!)
print(pStep[5], b64Array ?? [])

// Step 6: Converts the array of Base64 encoded characters into a Base64 string
let b64String = b64ArrayToString(inputB64Array: b64Array!)
print(pStep[6], b64String)

// Step 7: Extracts any potential encoded message from the byte array and displays in plain text
let text = String(decoding: byteArray!, as: UTF8.self)
print(pStep[7], text)

