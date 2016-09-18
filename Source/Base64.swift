//
//  Base64.swift
//  JSONWebToken
//
//  Created by Zhu Shengqi on 8/18/16.
//  Copyright © 2016 dia. All rights reserved.
//

import Foundation

/// URI Safe base64 encode
func base64_encode(_ input: Data) -> String {
    let data = input.base64EncodedData(options: [])
    let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
    return string
        .replacingOccurrences(of: "+", with: "-", options: [], range: nil)
        .replacingOccurrences(of: "/", with: "_", options: [], range: nil)
        .replacingOccurrences(of: "=", with: "", options: [], range: nil)
}

/// URI Safe base64 decode
func base64_decode(_ input: String) -> Data? {
    let rem = input.characters.count % 4
    
    var ending = ""
    if rem > 0 {
        let amount = 4 - rem
        ending = String(repeating: "=", count: amount)
    }
    
    let base64 = input.replacingOccurrences(of: "-", with: "+", options: [], range: nil)
        .replacingOccurrences(of: "_", with: "/", options: [], range: nil) + ending
    
    return Data(base64Encoded: base64, options: [])
}
