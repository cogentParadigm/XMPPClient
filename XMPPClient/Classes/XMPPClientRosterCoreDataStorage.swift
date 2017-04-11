//
//  XMPPClientRosterCoreDataStorage.swift
//  Pods
//
//  Created by Ali Gangji on 6/30/16.
//
//

import Foundation
import XMPPFramework

open class XMPPClientRosterCoreDataStorage: XMPPRosterCoreDataStorage {
    override open func commonInit() {
        super.commonInit()
        autoRemovePreviousDatabaseFile = false
    }
    override open func managedObjectModelName() -> String! {
        return "XMPPRoster"
    }
    override open func managedObjectModelBundle() -> Bundle! {
        return Bundle(forClass: XMPPRosterCoreDataStorage.self)
    }
    override open func clearAllUsersAndResourcesForXMPPStream(_ stream: XMPPStream!) {
        //prevent destruction of roster
    }
    override open func beginRosterPopulationForXMPPStream(_ stream: XMPPStream!, withVersion version: String!) {
        //prevent destruction of roster
    }
}
