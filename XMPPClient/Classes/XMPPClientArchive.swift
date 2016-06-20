//
//  XMPPClientArchive.swift
//  Pods
//
//  Created by Ali Gangji on 6/18/16.
//
//

import Foundation
import JSQMessagesViewController
import XMPPFramework

public class XMPPClientArchive: NSObject {
    
    public lazy var storage: XMPPMessageArchivingCoreDataStorage = {
       return XMPPMessageArchivingCoreDataStorage.sharedInstance()
    }()
    
    public lazy var archive: XMPPMessageArchiving = {
        let archive = XMPPMessageArchiving(messageArchivingStorage: self.storage)
        archive.clientSideMessageArchivingOnly = true
        return archive
    }()
    
    var connection:XMPPClientConnection!
    
    public func setup(connection:XMPPClientConnection) {
        self.connection = connection
        connection.activate(archive)
        connection.getStream().addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    public func teardown() {
        archive.deactivate()
    }
    
    public func messagesForJID(jid: String, inThread thread: String) -> NSMutableArray {
        let moc = storage.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entityForName("XMPPMessageArchiving_Message_CoreDataObject", inManagedObjectContext: moc)
        let request = NSFetchRequest()
        let predicateFormat = "bareJidStr like %@ ANd thread like %@"
        let predicate = NSPredicate(format: predicateFormat, jid, thread)
        let retrievedMessages = NSMutableArray()
        var sortedRetrievedMessages = NSArray()
        
        request.predicate = predicate
        request.entity = entityDescription
        
        do {
            let results = try moc?.executeFetchRequest(request)
            
            for message in results! {
                var element: DDXMLElement!
                do {
                    element = try DDXMLElement(XMLString: message.messageStr)
                } catch _ {
                    element = nil
                }
                
                let body: String
                let sender: String
                let date: NSDate
                
                date = message.timestamp
                
                if message.body() != nil {
                    body = message.body()
                } else {
                    body = ""
                }
                
                if element.attributeStringValueForName("to") == jid {
                    let displayName = connection.getStream().myJID
                    sender = displayName!.bare()
                } else {
                    sender = jid
                }
                
                let fullMessage = JSQMessage(senderId: sender, senderDisplayName: sender, date: date, text: body)
                retrievedMessages.addObject(fullMessage)
                
                
                let descriptor:NSSortDescriptor = NSSortDescriptor(key: "date", ascending: true);
                
                sortedRetrievedMessages = retrievedMessages.sortedArrayUsingDescriptors([descriptor]);
                
            }
        } catch _ {
            //catch fetch error here
        }
        return sortedRetrievedMessages.mutableCopy() as! NSMutableArray
    }
    
    public func deleteMessages(messages: NSArray) {
        messages.enumerateObjectsUsingBlock { (message, idx, stop) -> Void in
            let moc = self.storage.mainThreadManagedObjectContext
            let entityDescription = NSEntityDescription.entityForName("XMPPMessageArchiving_Message_CoreDataObject", inManagedObjectContext: moc)
            let request = NSFetchRequest()
            let predicateFormat = "messageStr like %@ "
            let predicate = NSPredicate(format: predicateFormat, message as! String)
            
            request.predicate = predicate
            request.entity = entityDescription
            
            do {
                let results = try moc?.executeFetchRequest(request)
                
                for message in results! {
                    var element: DDXMLElement!
                    do {
                        element = try DDXMLElement(XMLString: message.messageStr)
                    } catch _ {
                        element = nil
                    }
                    
                    if element.attributeStringValueForName("messageStr") == message as! String {
                        moc.deleteObject(message as! NSManagedObject)
                    }
                }
            } catch _ {
                //catch fetch error here
            }
        }
    }
    
    public func clearArchive() {
        deleteEntities("XMPPMessageArchiving_Message_CoreDataObject", fromMoc:storage.mainThreadManagedObjectContext)
        deleteEntities("XMPPMessageArchiving_Contact_CoreDataObject", fromMoc:storage.mainThreadManagedObjectContext)
    }
    
    private func deleteEntities(entity:String, fromMoc moc:ManagedObjectContext) {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(entity, inManagedObjectContext: moc)
        fetchRequest.includesPropertyValues = false
        do {
            if let results = try moc.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                for result in results {
                    moc.deleteObject(result)
                }
                
                try moc.save()
            }
        } catch {
            LOG.debug("failed to clear core data")
        }
    }
}

extension XMPPClientArchive: XMPPStreamDelegate {
    public func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        print("got iq \(iq)")
        //TODO: complete retrieval of archives from server
        return false
    }
}
