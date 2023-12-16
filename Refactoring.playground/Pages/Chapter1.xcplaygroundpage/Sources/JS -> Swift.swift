import Foundation

// 에러 처리
public enum StatementError: Error {
    case typeError(String)
    case playIDError(String)
}


// JS -> Swift 변환에 필요한 코드
public typealias Play = [String: Theater]

public struct Theater {
    public let name: String
    public let type: String

    public init(name: String, type: String) {
        self.name = name
        self.type = type
    }
}

public struct Invoice {
    public let customer: String
    public let performances: [Performance]

    public init(customer: String, performances: [Performance]) {
        self.customer = customer
        self.performances = performances
    }
}

public struct Performance {
    public let playID: String
    public let audience: Int

    public init(playID: String, audience: Int) {
        self.playID = playID
        self.audience = audience
    }
}

