//
//  XMPPClientRoster.swift
//  Pods
//
//  Created by Ali Gangji on 6/19/16.
//
//

import Foundation
import XMPPFramework

public class XMPPClientRoster: NSObject {
    
    lazy var storage: XMPPRosterCoreDataStorage = {
        return XMPPRosterCoreDataStorage()
    }()
    
    lazy var roster: XMPPRoster = {
        let roster = XMPPRoster(rosterStorage:self.storage)
        roster.autoFetchRoster = true
        roster.autoAcceptKnownPresenceSubscriptionRequests = true
        return roster
    }()
    
    var connection:XMPPClientConnection!

    public func setup(connection:XMPPClientConnection) {
        self.connection = connection
        connection.activate(roster)
    }
    
    public func teardown() {
        roster.deactivate()
    }
    
    public func userForJID(jid: String) -> XMPPUserCoreDataStorageObject? {
        let userJID = XMPPJID.jidWithString(jid)
        if let user = storage.userForJID(userJID, xmppStream: connection.getStream(), managedObjectContext: storage.mainThreadManagedObjectContext) {
            return user
        } else {
            return nil
        }
    }
    
    public func sendBuddyRequestTo(username: String) {
        let presence: DDXMLElement = DDXMLElement.elementWithName("presence") as! DDXMLElement
        presence.addAttributeWithName("type", stringValue: "subscribe")
        presence.addAttributeWithName("to", stringValue: username)
        presence.addAttributeWithName("from", stringValue: connection.getStream().myJID.bare())
        connection.getStream().sendElement(presence)
    }
    
    public func acceptBuddyRequestFrom(username: String) {
        let presence: DDXMLElement = DDXMLElement.elementWithName("presence") as! DDXMLElement
        presence.addAttributeWithName("to", stringValue: username)
        presence.addAttributeWithName("from", stringValue: connection.getStream().myJID.bare())
        presence.addAttributeWithName("type", stringValue: "subscribed")
        connection.getStream().sendElement(presence)
    }
    
    public func declineBuddyRequestFrom(username: String) {
        let presence: DDXMLElement = DDXMLElement.elementWithName("presence") as! DDXMLElement
        presence.addAttributeWithName("to", stringValue: username)
        presence.addAttributeWithName("from", stringValue: connection.getStream().myJID.bare())
        presence.addAttributeWithName("type", stringValue: "unsubscribed")
        connection.getStream().sendElement(presence)
    }

}
