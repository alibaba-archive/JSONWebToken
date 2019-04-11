//
//  JWT.swift
//  JSONWebToken
//
//  Created by Zhu Shengqi on 8/18/16.
//  Copyright © 2016 dia. All rights reserved.
//

import Foundation
import CryptoSwift

public typealias Payload = [String: Any]

/// The supported Algorithms
public enum Algorithm: CustomStringConvertible {
    /// No Algorithm, i-e, insecure
    case none
    
    /// HMAC using SHA-256 hash algorithm
    case hs256(String)
    
    /// HMAC using SHA-384 hash algorithm
    case hs384(String)
    
    /// HMAC using SHA-512 hash algorithm
    case hs512(String)
    
    static func algorithm(_ name: String, key: String?) -> Algorithm? {
        if name == "none" {
            if key != nil {
                return nil  // We don't allow nil when we configured a key
            }
            return Algorithm.none
        } else if let key = key {
            if name == "HS256" {
                return .hs256(key)
            } else if name == "HS384" {
                return .hs384(key)
            } else if name == "HS512" {
                return .hs512(key)
            }
        }
        
        return nil
    }
    
    public var description: String {
        switch self {
        case .none:
            return "none"
        case .hs256:
            return "HS256"
        case .hs384:
            return "HS384"
        case .hs512:
            return "HS512"
        }
    }
    
    /// Sign a message using the algorithm
    func sign(_ message: String) -> String {
        func signHS(_ key: String, variant: CryptoSwift.HMAC.Variant) -> String {
            let keyData = key.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            let messageData = message.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            let mac = HMAC(key: keyData.bytes, variant: variant)
            let result = (try? mac.authenticate(messageData.bytes)) ?? []
   
            return base64_encode(Data(result))
        }
        
        switch self {
        case .none:
            return ""
            
        case .hs256(let key):
            return signHS(key, variant: .sha256)
            
        case .hs384(let key):
            return signHS(key, variant: .sha384)
            
        case .hs512(let key):
            return signHS(key, variant: .sha512)
        }
    }
    
    /// Verify a signature for a message using the algorithm
    func verify(_ message: String, signature: Data) -> Bool {
        return sign(message) == base64_encode(signature)
    }
}

// MARK: Encoding

/*** Encode a payload
 - parameter payload: The payload to sign
 - parameter algorithm: The algorithm to sign the payload with
 - returns: The JSON web token as a String
 */
public func encode(_ payload: Payload, algorithm: Algorithm) -> String {
    func encodeJSON(_ payload:Payload) -> String {
        let data = try! JSONSerialization.data(withJSONObject: payload, options: [])
        return base64_encode(data)
    }
    
    let header = encodeJSON(["typ": "JWT", "alg": algorithm.description])
    let payload = encodeJSON(payload)
    let signingInput = "\(header).\(payload)"
    let signature = algorithm.sign(signingInput)
    return "\(signingInput).\(signature)"
}

public final class PayloadBuilder {
    var payload = Payload()
    
    public var issuer: String? {
        get {
            return payload["iss"] as? String
        }
        set {
            payload["iss"] = newValue
        }
    }
    
    public var audience: String? {
        get {
            return payload["aud"] as? String
        }
        set {
            payload["aud"] = newValue
        }
    }
    
    public var expiration: Date? {
        get {
            if let expiration = payload["exp"] as? TimeInterval {
                return Date(timeIntervalSince1970: expiration)
            }
            
            return nil
        }
        set {
            payload["exp"] = newValue?.timeIntervalSince1970
        }
    }
    
    public var notBefore: Date? {
        get {
            if let notBefore = payload["nbf"] as? TimeInterval {
                return Date(timeIntervalSince1970: notBefore)
            }
            
            return nil
        }
        set {
            payload["nbf"] = newValue?.timeIntervalSince1970
        }
    }
    
    public var issuedAt: Date? {
        get {
            if let issuedAt = payload["iat"] as? TimeInterval {
                return Date(timeIntervalSince1970: issuedAt)
            }
            
            return nil
        }
        set {
            payload["iat"] = newValue?.timeIntervalSince1970
        }
    }
    
    public subscript(key: String) -> Any? {
        get {
            return payload[key]
        }
        set {
            payload[key] = newValue
        }
    }
}

public func encode(_ algorithm: Algorithm, closure: ((PayloadBuilder) -> Void)) -> String {
    let builder = PayloadBuilder()
    closure(builder)
    return encode(builder.payload, algorithm: algorithm)
}
