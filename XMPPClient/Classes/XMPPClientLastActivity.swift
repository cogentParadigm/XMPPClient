//
//  XMPPClientLastActivity.swift
//  Pods
//
//  Created by Ali Gangji on 6/19/16.
//
//

import Foundation
import XMPPFramework

public class XMPPClientLastActivity: NSObject {
    
    lazy var activity: XMPPLastActivity = {
       return XMPPLastActivity()
    }()
    
    public func setup(connection:XMPPClientConnection) {
        connection.activate(activity)
    }
    
    public func teardown() {
        activity.deactivate()
    }
}
