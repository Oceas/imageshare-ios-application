//
//  DecodeImages.swift
//  Image Share
//
//  Created by Deni on 7/13/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import UIKit

class DecodeOperation: NSOperation {
    
    let image: UIImage
    let decoder: DecodeUtility
    let completion: (UIImage -> Void)
    
    init(image: UIImage, decoder: DecodeUtility, completion: (UIImage -> Void)) {
        self.image = image
        self.decoder = decoder
        self.completion = completion
    }
    
    override func main() {
        if cancelled {
            return
        }
        
        let decodedImage = decoder.decode(image)
        
        if cancelled {
            return
        }
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.completion(decodedImage)
        }
    }
    
}