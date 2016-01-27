import Foundation

public extension String {
    
    static let NumericCharacters = "0123456789"
    static let AlphabethicCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVXYZ"
    static let AlphaNumericCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVXYZ0123456789"
    static let NameCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVXYZ0123456789-_"
    
    public init(characters: Set<Character>, length: Int) {
        self = NSMutableString(capacity: length) as String
        
        for _ in 0..<length {
            self.append(characters.randomElement())
        }
    }
    
    public init(characters: String, length: Int) {
        self = NSMutableString(capacity: length) as String
        
        for _ in 0..<length {
            self.append(characters.randomElement())
        }
    }
    
    public subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    public subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    public subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
}



extension String {
    func randomElement() -> Character {
        let n = Int(arc4random_uniform(UInt32(self.characters.count)))
        let i = self.startIndex.advancedBy(n)
        return self[i]
    }
}

extension Set {
    func randomElement() -> Element {
        let n = Int(arc4random_uniform(UInt32(self.count)))
        let i = self.startIndex.advancedBy(n)
        return self[i]
    }
}
