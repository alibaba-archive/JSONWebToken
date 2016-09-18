//
//  Claims.swift
//  JSONWebToken
//
//  Created by Zhu Shengqi on 8/18/16.
//  Copyright © 2016 dia. All rights reserved.
//

import Foundation

func validateClaims(_ payload: Payload, audience: String?, issuer: String?) -> TokenValidationError? {
    return validateIssuer(payload, issuer: issuer) ?? validateAudience(payload, audience: audience) ??
        validateDate(payload, key: "exp", comparison: .orderedAscending, failure: .expiredSignature, decodeError: "Expiration time claim (exp) must be an integer") ??
        validateDate(payload, key: "nbf", comparison: .orderedDescending, failure: .immatureSignature, decodeError: "Not before claim (nbf) must be an integer") ??
        validateDate(payload, key: "iat", comparison: .orderedDescending, failure: .invalidIssuedAt, decodeError: "Issued at claim (iat) must be an integer")
}

func validateAudience(_ payload: Payload, audience: String?) -> TokenValidationError? {
    guard let audience = audience else {
        return nil
    }
    
    if let aud = payload["aud"] as? [String] {
        return !aud.contains(audience) ? .invalidAudience : nil
    } else if let aud = payload["aud"] as? String {
        return aud != audience ? .invalidAudience : nil
    } else {
        return .decodeError("Invalid audience claim, must be a string or an array of strings")
    }
}

func validateIssuer(_ payload: Payload, issuer: String?) -> TokenValidationError? {
    guard let issuer = issuer else {
        return nil
    }
    
    if let iss = payload["iss"] as? String {
        return iss != issuer ? .invalidIssuer : nil
    } else {
        return .invalidIssuer
    }
}

func validateDate(_ payload: Payload, key: String, comparison: ComparisonResult, failure: TokenValidationError, decodeError: String) -> TokenValidationError? {
    guard let timestampObj = payload[key] else {
        return nil
    }
    
    if let timestamp = ((timestampObj as? TimeInterval) ?? (timestampObj as? NSNumber)?.doubleValue) {
        let date = Date(timeIntervalSince1970: timestamp)
        
        return date.compare(Date()) == comparison ? failure : nil
    } else {
        return .decodeError(decodeError)
    }
}
