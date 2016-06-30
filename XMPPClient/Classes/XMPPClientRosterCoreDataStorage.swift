//
//  XMPPClientRosterCoreDataStorage.swift
//  Pods
//
//  Created by Ali Gangji on 6/30/16.
//
//

import Foundation
import XMPPFramework

public class XMPPClientRosterCoreDataStorage: XMPPRosterCoreDataStorage {
    override public func commonInit() {
        super.commonInit()
        autoRemovePreviousDatabaseFile = false
    }
    override public func managedObjectModelName() -> String! {
        return "XMPPRoster"
    }
    override public func managedObjectModelBundle() -> NSBundle! {
        return NSBundle(forClass: XMPPRosterCoreDataStorage.self)
    }
    override public func clearAllUsersAndResourcesForXMPPStream(stream: XMPPStream!) {
        //prevent destruction of roster
    }
    override public func beginRosterPopulationForXMPPStream(stream: XMPPStream!, withVersion version: String!) {
        //prevent destruction of roster
    }
}
