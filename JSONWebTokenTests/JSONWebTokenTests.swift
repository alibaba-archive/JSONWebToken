//
//  JSONWebTokenTests.swift
//  JSONWebTokenTests
//
//  Created by Zhu Shengqi on 8/18/16.
//  Copyright © 2016 dia. All rights reserved.
//

import XCTest
@testable import JSONWebToken

class JSONWebTokenTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testEncode() {
        let input1 = "test"
        
        guard let data1 = input1.data(using: .utf8) else {
            assertionFailure()
            return
        }
        
        let output1 = base64_encode(data1)
        
        XCTAssert(output1 == "dGVzdA")
        
        //
        
        let input2 = "helloworld"
        
        guard let data2 = input2.data(using: .utf8) else {
            assertionFailure()
            return
        }
        
        let output2 = base64_encode(data2)
        
        XCTAssert(output2 == "aGVsbG93b3JsZA")
    }
    
    func testDecode() {
        let input1 = "dGVzdA=="
        
        guard let data1 = base64_decode(input1),
            let output1 = String(data: data1, encoding: .utf8) else {
            assertionFailure()
            return
        }
        
        XCTAssert(output1 == "test")
        
        //
        
        let input2 = "aGVsbG93b3JsZA"
        
        guard let data2 = base64_decode(input2),
            let output2 = String(data: data2, encoding: .utf8) else {
                assertionFailure()
                return
        }
        
        XCTAssert(output2 == "helloworld")
    }
}
