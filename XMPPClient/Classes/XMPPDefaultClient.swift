//
//  XMPPClient.swift
//  Pods
//
//  Created by Ali Gangji on 6/18/16.
//
//  a default XMPP Client with access to capabilities, roster, archiving, delivery receipts, and last activity

import Foundation
import XMPPFramework

public typealias XMPPMessageCompletionHandler = (stream: XMPPStream, message: XMPPMessage) -> Void

public protocol XMPPClientDelegate : NSObjectProtocol {
    func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject)
    func oneStream(sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject)
}

public class XMPPDefaultClient: NSObject {

    lazy var connection: XMPPClientConnection = {
       return XMPPClientConnection()
    }()
    
    public lazy var archive: XMPPClientArchive = {
        return XMPPClientArchive()
    }()
    
    public lazy var capabilities: XMPPClientCapabilities = {
        return XMPPClientCapabilities()
    }()
    
    public lazy var roster:XMPPClientRoster = {
        return XMPPClientRoster()
    }()
    
    public lazy var receipts:XMPPClientDeliveryReceipts = {
        return XMPPClientDeliveryReceipts()
    }()
    
    public var enableArchiving = true
    public var delegate:XMPPClientDelegate?
    
    var messageCompletionHandler:XMPPMessageCompletionHandler?
    
    public func setup() {
        roster.setup(connection)
        capabilities.setup(connection)
        receipts.setup(connection)
        if enableArchiving {
            archive.setup(connection)
        }
        
        connection.getStream().addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    public func teardown() {
        connection.getStream().removeDelegate(self)
        if enableArchiving {
            archive.teardown()
        }
        receipts.teardown()
        capabilities.teardown()
        roster.teardown()
    }
    
    public func sendMessage(message: String, thread:String, to receiver: String, completionHandler completion:XMPPMessageCompletionHandler) {
        let body = DDXMLElement.elementWithName("body") as! DDXMLElement
        let messageID = connection.getStream().generateUUID()
        
        body.setStringValue(message)
        
        let threadElement = DDXMLElement.elementWithName("thread") as! DDXMLElement
        threadElement.setStringValue(thread)
        
        let completeMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
        
        completeMessage.addAttributeWithName("id", stringValue: messageID)
        completeMessage.addAttributeWithName("type", stringValue: "chat")
        completeMessage.addAttributeWithName("to", stringValue: receiver)
        completeMessage.addChild(body)
        completeMessage.addChild(threadElement)
        
        messageCompletionHandler = completion
        connection.getStream().sendElement(completeMessage)
    }
    
}

extension XMPPDefaultClient: XMPPStreamDelegate {
    
    public func xmppStream(sender: XMPPStream, didSendMessage message: XMPPMessage) {
        if let completion = messageCompletionHandler {
            completion(stream: sender, message: message)
        }
    }
    
    public func xmppStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage) {
        let user = roster.storage.userForJID(message.from(), xmppStream: connection.getStream(), managedObjectContext: roster.storage.mainThreadManagedObjectContext)
        if message.isChatMessageWithBody() {
            delegate?.oneStream(sender, didReceiveMessage: message, from: user)
        } else if let _ = message.elementForName("composing") {
            delegate?.oneStream(sender, userIsComposing: user)
        }
    }
}
