//
//  AppleImageProcessor.swift
//  PinVision
//
//  Created by Matt Stanford on 11/17/19.
//  Copyright © 2019 Matt Stanford. All rights reserved.
//

import UIKit
import Vision

class AppleImageProcessor {
    
    func startProcessing(image: UIImage, completion: @escaping ([Int]) -> Void) {
        guard let cgImage = image.cgImage else {
            return
        }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            var scores: [Int] = []
            
            for currentObservation in observations {
                let topCandidates = currentObservation.topCandidates(10)
                
                for candidate in topCandidates {
                    if let score = self.tryToGetScoreFrom(text: candidate.string) {
                        scores.append(score)
                    }
                }
            }
            let sortedScores = self.getMostCommonScores(scores: scores)
            completion(sortedScores)
        }
        
        request.recognitionLevel = .accurate
        
        try? requestHandler.perform([request])
    }
    
    func getMostCommonScores(scores: [Int]) -> [Int] {
        var scoreFoundMap: [Int: Int] = [:]
        for score in scores {
            if let previousValue = scoreFoundMap[score] {
                scoreFoundMap[score] = previousValue + 1
            } else {
                scoreFoundMap[score] = 1
            }
        }
        
        let sortedScores = scoreFoundMap.sorted(by: { $0.value > $1.value }).map { $0.key }
        
        return sortedScores
    }
    
    func tryToGetScoreFrom(text: String) -> Int? {
        let result = String(text.filter { "01234567890".contains($0) })
        return Int(result)
    }
}
