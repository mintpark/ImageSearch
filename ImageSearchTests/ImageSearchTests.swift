//
//  ImageSearchTests.swift
//  ImageSearchTests
//
//  Created by Hayoung Park on 18/12/2018.
//  Copyright © 2018 Hayoung Park. All rights reserved.
//

import XCTest
@testable import ImageSearch

class ImageSearchTests: XCTestCase {
    let kakaoApiUrl = "https://dapi.kakao.com/v2/search/image"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testKaKaoAPI() {
        let query1 = String(format: "query=ioi&page=%d&size=%d", 1, 5)
        var response1: URLResponse?
        var request1 = URLRequest(url: URL(string: kakaoApiUrl)!)
        request1.httpMethod = "GET"
        request1.httpBody = query1.data(using:String.Encoding.utf8, allowLossyConversion: false)
        request1.setValue(KAKAO_KEY, forHTTPHeaderField: "Authorization")
        
        let query2 = String(format: "query=ioi&page=%d&size=%d", 2, 5)
        var response2: URLResponse?
        var request2 = URLRequest(url: URL(string: kakaoApiUrl)!)
        request2.httpMethod = "GET"
        request2.httpBody = query2.data(using:String.Encoding.utf8, allowLossyConversion: false)
        request2.setValue(KAKAO_KEY, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request1) { (data, response, error) in
            response1 = response
        }
        URLSession.shared.dataTask(with: request2) { (data, response, error) in
            response2 = response
        }
        
        XCTAssertNotEqual(response1, response2)
//        XCTAssertEqual(response1, response2)
    }

}
