//
//  User+CoreDataClass.swift
//  MovieApp
//
//  Created by 이정인 on 2/27/26.
//
//

public import Foundation
public import CoreData

public typealias UserCoreDataClassSet = NSSet

@objc(User)
public class User: NSManagedObject {
    public static let className = "User"
    
    public enum Key {
        static let birthday = "birthday"
        static let id = "id"
        static let name = "name"
        static let password = "password"
        static let phoneNumber = "phoneNumber"
        
    }

}
