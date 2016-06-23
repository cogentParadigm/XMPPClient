//
//  XMPPClientvCard.swift
//  Pods
//
//  Created by Ali Gangji on 6/23/16.
//
//

import Foundation
import XMPPFramework

public class XMPPClientvCard: NSObject {

    public lazy var storage: XMPPvCardCoreDataStorage = {
        return XMPPvCardCoreDataStorage.sharedInstance()
    }()
    
    public lazy var temp: XMPPvCardTempModule = {
        return XMPPvCardTempModule(vCardStorage:self.storage)
    }()

    public lazy var avatar: XMPPvCardAvatarModule = {
        return XMPPvCardAvatarModule(vCardTempModule: self.temp)
    }()
    
    var connection:XMPPClientConnection!
    
    public func setup(connection:XMPPClientConnection) {
        self.connection = connection
        connection.activate(temp)
        connection.activate(avatar)
    }
    
    public func teardown() {
        avatar.deactivate()
        temp.deactivate()
    }
    
}
