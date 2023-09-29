//
//  VisionService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/9/23.
//

import UIKit
import Vision

struct VisionService {
    
    static func processImages(_ images: [UIImage]) -> [CaseImage] {
        var processedImages: [CaseImage] = []
        
        for image in images {
            let (containsFaces, faceRectangles) = detectFaces(in: image)
            
            if containsFaces == true, let faceRectangles = faceRectangles {
                if let faceImage = hideFacesInImage(originalImage: image, faceRectangles: faceRectangles) {
                    processedImages.append(CaseImage(image: image, faceImage: faceImage))
                } else {
                    processedImages.append(CaseImage(image: image, faceImage: nil))
                }
            } else {
                processedImages.append(CaseImage(image: image, faceImage: nil))
            }
        }
        
        return processedImages
    }
    
    
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
    
    static func hideFacesInImage(originalImage: UIImage, faceRectangles: [CGRect]) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)
        
        originalImage.draw(in: CGRect(origin: .zero, size: originalImage.size))
        
        let hideColor = UIColor.white
        
        let imageSize = originalImage.size
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        
        for faceRect in faceRectangles {
            
            let rectX = faceRect.origin.x * imageWidth
            let rectY = (1 - faceRect.origin.y - faceRect.size.height) * imageHeight
            let rectWidth = faceRect.size.width * imageWidth
            let rectHeight = faceRect.size.height * imageHeight
            
            let pixelRect = CGRect(x: rectX, y: rectY, width: rectWidth, height: rectHeight)
            
            let context = UIGraphicsGetCurrentContext()
            
            context?.setFillColor(hideColor.cgColor)
            
            context?.fill(pixelRect)
        }
        
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
}
