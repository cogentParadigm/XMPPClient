//
//  XMPPClientCapabilities.swift
//  Pods
//
//  Created by Ali Gangji on 6/19/16.
//
//

import Foundation
import XMPPFramework

public class XMPPClientCapabilities: NSObject {
    
    public lazy var storage: XMPPCapabilitiesCoreDataStorage = {
        return XMPPCapabilitiesCoreDataStorage.sharedInstance()
    }()
    
    public lazy var capabilities: XMPPCapabilities = {
        let capabilities = XMPPCapabilities(capabilitiesStorage:self.storage)
        capabilities.autoFetchHashedCapabilities = true;
        capabilities.autoFetchNonHashedCapabilities = false;
        return capabilities
    }()
    
    public func setup(connection:XMPPClientConnection) {
        connection.activate(capabilities)
    }
    
    public func teardown() {
        capabilities.deactivate()
    }
}
