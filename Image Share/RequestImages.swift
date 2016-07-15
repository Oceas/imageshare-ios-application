//
//  RequestImages.swift
//  Image Share
//
//  Created by Deni on 7/13/16.
//  Copyright © 2016 ImageShare. All rights reserved.
//

import Foundation


import UIKit
import Alamofire

class RequestImages{
    
    var decodeOperation: NSOperation?
    var request: Request
    
    init(request: Request) {
        self.request = request
    }
    
    func cancel() {
        decodeOperation?.cancel()
        request.cancel()
    }
    
}