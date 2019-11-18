//
//  ImageProcessorTests.swift
//  PinVisionTests
//
//  Created by Matt Stanford on 11/17/19.
//  Copyright © 2019 Matt Stanford. All rights reserved.
//

import XCTest

@testable import PinVision

class AppleImageProcessorTests: XCTestCase {
    var processor: AppleImageProcessor = AppleImageProcessor()
    
    func testRecognizeCloseUpLCD() {
        let recognizedValues = getTopValues(fileName: "medieval_madness", fileExtension: "png")
        XCTAssert(recognizedValues.contains(54368080))
    }
    
    func testCloseUpModernScreen() {
        let recognizedValues = getTopValues(fileName: "tna", fileExtension: "jpg")
        XCTAssert(recognizedValues.contains(1627000))
    }
    
    func testEM() {
        let recognizedValues = getTopValues(fileName: "can_crusher", fileExtension: "jpg")
        XCTAssert(recognizedValues.contains(5661))
    }
}

//MARK: - Helper Functions
extension AppleImageProcessorTests {
    func getTopValues(fileName: String, fileExtension: String) -> [Int] {
        guard let imageData = self.dataFromFile(named: fileName, fileExtension: fileExtension),
            let image = UIImage(data: imageData) else {
                XCTFail("Couldn't get image data!")
                return []
        }
        
        var returnedScores: [Int] = []
        let imageExpectation = XCTestExpectation(description: "Image processing")
        processor.startProcessing(image: image, completion: { scores in
            if scores.count > 0 {
                returnedScores = Array(scores.prefix(4))
            }
            imageExpectation.fulfill()
        })
        wait(for: [imageExpectation], timeout: 10)
        
        return returnedScores
    }
    
    func dataFromFile(named name: String, fileExtension: String) -> Data? {
        
        let testBundle = Bundle(for: AppleImageProcessorTests.self)
        guard let url = testBundle.url(forResource: name, withExtension: fileExtension) else {
            return nil
        }
        
        return try? Data(contentsOf: url)
    }
}

