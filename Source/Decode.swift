//
//  Decode.swift
//  JSONWebToken
//
//  Created by Zhu Shengqi on 8/18/16.
//  Copyright © 2016 dia. All rights reserved.
//

import Foundation

/// Failure reasons from decoding a JWT
public enum TokenValidationError: CustomStringConvertible, ErrorType {
    /// Decoding the JWT itself failed
    case DecodeError(String)
    
    /// The JWT uses an unsupported algorithm
    case InvalidAlgorithm
    
    /// The issued claim has expired
    case ExpiredSignature
    
    /// The issued claim is for the future
    case ImmatureSignature
    
    /// The claim is for the future
    case InvalidIssuedAt
    
    /// The audience of the claim doesn't match
    case InvalidAudience
    
    /// The issuer claim failed to verify
    case InvalidIssuer
    
    /// Returns a readable description of the error
    public var description: String {
        switch self {
        case .DecodeError(let error):
            return "Decode Error: \(error)"
        case .InvalidIssuer:
            return "Invalid Issuer"
        case .ExpiredSignature:
            return "Expired Signature"
        case .ImmatureSignature:
            return "The token is not yet valid (not before claim)"
        case .InvalidIssuedAt:
            return "Issued at claim (iat) is in the future"
        case InvalidAudience:
            return "Invalid Audience"
        case InvalidAlgorithm:
            return "Unsupported algorithm or incorrect key"
        }
    }
}


/// Decode a JWT
public func decode(jwt: String, algorithms: [Algorithm], verify: Bool = true, audience: String? = nil, issuer: String? = nil) throws -> Payload {
    switch load(jwt) {
    case let .Success(header, payload, signature, signatureInput):
        if verify {
            if let error = validateClaims(payload, audience: audience, issuer: issuer) ?? verifySignature(algorithms, header: header, signingInput: signatureInput, signature: signature) {
                throw error
            }
        }
        
        return payload
    case .Failure(let failure):
        throw failure
    }
}

/// Decode a JWT
public func decode(jwt: String, algorithm: Algorithm, verify: Bool = true, audience: String? = nil, issuer: String? = nil) throws -> Payload {
    return try decode(jwt, algorithms: [algorithm], verify: verify, audience: audience, issuer: issuer)
}

// MARK: Parsing a JWT

enum LoadResult {
    case Success(header: Payload, payload: Payload, signature: NSData, signatureInput: String)
    case Failure(TokenValidationError)
}

func load(jwt: String) -> LoadResult {
    let segments = jwt.componentsSeparatedByString(".")
    if segments.count != 3 {
        return .Failure(.DecodeError("Not enough segments"))
    }
    
    let headerSegment = segments[0]
    let payloadSegment = segments[1]
    let signatureSegment = segments[2]
    let signatureInput = "\(headerSegment).\(payloadSegment)"
    
    guard let headerData = base64_decode(headerSegment) else {
        return .Failure(.DecodeError("Header is not correctly encoded as base64"))
    }
    
    guard let header = (try? NSJSONSerialization.JSONObjectWithData(headerData, options: [])) as? Payload else {
        return .Failure(.DecodeError("Invalid header"))
    }
    
    guard let payloadData = base64_decode(payloadSegment) else {
        return .Failure(.DecodeError("Payload is not correctly encoded as base64"))
    }
    
    guard let payload = (try? NSJSONSerialization.JSONObjectWithData(payloadData, options: [])) as? Payload else {
        return .Failure(.DecodeError("Invalid payload"))
    }
    
    guard let signature = base64_decode(signatureSegment) else {
        return .Failure(.DecodeError("Signature is not correctly encoded as base64"))
    }
    
    return .Success(header:header, payload:payload, signature:signature, signatureInput:signatureInput)
}

// MARK: Signature Verification
func verifySignature(algorithms: [Algorithm], header: Payload, signingInput: String, signature: NSData) -> TokenValidationError? {
    guard let alg = header["alg"] as? String else {
        return .DecodeError("Missing Algorithm")
    }
    
    let matchingAlgorithms = algorithms.filter { $0.description == alg }
    let results = matchingAlgorithms.map { $0.verify(signingInput, signature: signature) }
    let successes = results.filter { $0 }
    
    return successes.isEmpty ? .InvalidAlgorithm : nil
}