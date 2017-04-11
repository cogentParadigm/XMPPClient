//
//  XMPPClientRoster.swift
//  Pods
//
//  Created by Ali Gangji on 6/19/16.
//
//

import Foundation
import XMPPFramework

open class XMPPClientRoster: NSObject {
    
    open lazy var storage: XMPPClientRosterCoreDataStorage = {
        return XMPPClientRosterCoreDataStorage()
    }()
    
    open lazy var roster: XMPPRoster = {
        let roster = XMPPRoster(rosterStorage:self.storage)
        roster.autoFetchRoster = true
        roster.autoAcceptKnownPresenceSubscriptionRequests = true
        roster.autoClearAllUsersAndResources = false
        return roster
    }()
    
    var connection:XMPPClientConnection!

    open func setup(_ connection:XMPPClientConnection) {
        self.connection = connection
        connection.activate(roster)
    }
    
    open func teardown() {
        roster.deactivate()
    }
    
    open func userForJID(_ jid: String) -> XMPPUserCoreDataStorageObject? {
        let userJID = XMPPJID.jidWithString(jid)
        if let user = storage.userForJID(userJID, xmppStream: connection.getStream(), managedObjectContext: storage.mainThreadManagedObjectContext) {
            return user
        } else {
            return nil
        }
    }
    
    open func sendBuddyRequestTo(_ username: String) {
        let presence: DDXMLElement = DDXMLElement.elementWithName("presence") as! DDXMLElement
        presence.addAttributeWithName("type", stringValue: "subscribe")
        presence.addAttributeWithName("to", stringValue: username)
        presence.addAttributeWithName("from", stringValue: connection.getStream().myJID.bare())
        connection.getStream().sendElement(presence)
    }
    
    open func acceptBuddyRequestFrom(_ username: String) {
        let presence: DDXMLElement = DDXMLElement.elementWithName("presence") as! DDXMLElement
        presence.addAttributeWithName("to", stringValue: username)
        presence.addAttributeWithName("from", stringValue: connection.getStream().myJID.bare())
        presence.addAttributeWithName("type", stringValue: "subscribed")
        connection.getStream().sendElement(presence)
    }
    
    open func declineBuddyRequestFrom(_ username: String) {
        let presence: DDXMLElement = DDXMLElement.elementWithName("presence") as! DDXMLElement
        presence.addAttributeWithName("to", stringValue: username)
        presence.addAttributeWithName("from", stringValue: connection.getStream().myJID.bare())
        presence.addAttributeWithName("type", stringValue: "unsubscribed")
        connection.getStream().sendElement(presence)
    }

}
