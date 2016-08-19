//
//  Claims.swift
//  JSONWebToken
//
//  Created by Zhu Shengqi on 8/18/16.
//  Copyright © 2016 dia. All rights reserved.
//

import Foundation

func validateClaims(payload: Payload, audience: String?, issuer: String?) -> TokenValidationError? {
    return validateIssuer(payload, issuer: issuer) ?? validateAudience(payload, audience: audience) ??
        validateDate(payload, key: "exp", comparison: .OrderedAscending, failure: .ExpiredSignature, decodeError: "Expiration time claim (exp) must be an integer") ??
        validateDate(payload, key: "nbf", comparison: .OrderedDescending, failure: .ImmatureSignature, decodeError: "Not before claim (nbf) must be an integer") ??
        validateDate(payload, key: "iat", comparison: .OrderedDescending, failure: .InvalidIssuedAt, decodeError: "Issued at claim (iat) must be an integer")
}

func validateAudience(payload: Payload, audience: String?) -> TokenValidationError? {
    guard let audience = audience else {
        return nil
    }
    
    if let aud = payload["aud"] as? [String] {
        return !aud.contains(audience) ? .InvalidAudience : nil
    } else if let aud = payload["aud"] as? String {
        return aud != audience ? .InvalidAudience : nil
    } else {
        return .DecodeError("Invalid audience claim, must be a string or an array of strings")
    }
}

func validateIssuer(payload: Payload, issuer: String?) -> TokenValidationError? {
    guard let issuer = issuer else {
        return nil
    }
    
    if let iss = payload["iss"] as? String {
        return iss != issuer ? .InvalidIssuer : nil
    } else {
        return .InvalidIssuer
    }
}

func validateDate(payload: Payload, key: String, comparison: NSComparisonResult, failure: TokenValidationError, decodeError: String) -> TokenValidationError? {
    guard let timestampObj = payload[key] else {
        return nil
    }
    
    if let timestamp = ((timestampObj as? NSTimeInterval) ?? (timestampObj as? NSNumber)?.doubleValue) {
        let date = NSDate(timeIntervalSince1970: timestamp)
        
        return date.compare(NSDate()) == comparison ? failure : nil
    } else {
        return .DecodeError(decodeError)
    }
}
