//
//  Users.swift
//  betus
//
//  Created by amr Elshendidy on 10/30/17.
//  Copyright © 2017 amr Elshendidy. All rights reserved.
//


import Foundation
import UIKit
import AWSDynamoDB

class Users: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var id: String?
    var birthday: String?
    var cover: [String: String]?
    var currency: [String: String]?
    var devices: [String: String]?
    var _text: String?
    var _userId: String?
    var _videourl: [String: String]?
    
    class func dynamoDBTableName() -> String {
        
        return "betus-mobilehub-1316247808-Users"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_postId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_postId" : "postId",
            "_dateTime" : "dateTime",
            "_imageurl" : "imageurl",
            "_postType" : "postType",
            "_taggedusers" : "taggedusers",
            "_text" : "text",
            "_userId" : "userId",
            "_videourl" : "videourl",
        ]
    }
}

