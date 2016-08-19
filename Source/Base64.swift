//
//  Base64.swift
//  JSONWebToken
//
//  Created by Zhu Shengqi on 8/18/16.
//  Copyright © 2016 dia. All rights reserved.
//

import Foundation

/// URI Safe base64 encode
func base64_encode(input: NSData) -> String {
    let data = input.base64EncodedDataWithOptions([])
    let string = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
    return string
        .stringByReplacingOccurrencesOfString("+", withString: "-", options: [], range: nil)
        .stringByReplacingOccurrencesOfString("/", withString: "_", options: [], range: nil)
        .stringByReplacingOccurrencesOfString("=", withString: "", options: [], range: nil)
}

/// URI Safe base64 decode
func base64_decode(input: String) -> NSData? {
    let rem = input.characters.count % 4
    
    var ending = ""
    if rem > 0 {
        let amount = 4 - rem
        ending = String(count: amount, repeatedValue: Character("="))
    }
    
    let base64 = input.stringByReplacingOccurrencesOfString("-", withString: "+", options: [], range: nil)
        .stringByReplacingOccurrencesOfString("_", withString: "/", options: [], range: nil) + ending
    
    return NSData(base64EncodedString: base64, options: [])
}