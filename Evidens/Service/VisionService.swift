//
//  VisionService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/9/23.
//

import UIKit
import Vision

/// The model used to interface with Vision API.
struct VisionService {
    
    /// Processes an array of images, detecting faces and creating corresponding CaseImage objects.
    ///
    /// - Parameter images: An array of UIImage objects to be processed.
    /// - Returns: An array of CaseImage objects, each containing the original image and a processed version
    ///            with faces hidden if detected.
    static func processImages(_ images: [UIImage]) -> [CaseImage] {
        var processedImages: [CaseImage] = []
        
        for image in images {
            let (containsFaces, _) = detectFaces(in: image)
            
            if containsFaces == true {
                processedImages.append(CaseImage(image: image, containsFaces: true))
            } else {
                processedImages.append(CaseImage(image: image, containsFaces: false))
            }
        }
        
        return processedImages
    }
    
    /// Detects faces in a given UIImage.
    ///
    /// - Parameter image: The UIImage in which to detect faces.
    /// - Returns: A tuple indicating whether faces are present and, if so, an array of CGRect representing
    ///            the bounding boxes of detected faces.
    static func detectFaces(in image: UIImage) -> (containsFaces: Bool, faceRectangles: [CGRect]?) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest()
        
        guard let cgImage = image.cgImage else {
            return (containsFaces: false, faceRectangles: nil)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        do {
            try handler.perform([faceDetectionRequest])
            
            guard let observations = faceDetectionRequest.results, !observations.isEmpty else {
                return (containsFaces: false, faceRectangles: nil)
            }
            
            let faceRectangles = observations.map { observation in
                return observation.boundingBox
            }
            
            return (containsFaces: true, faceRectangles: faceRectangles)
        } catch {
            return (containsFaces: false, faceRectangles: nil)
        }
    }
}
