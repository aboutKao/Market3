//
//  Item.swift
//  Market
//
//  Created by Kao on 2020/8/30.
//  Copyright © 2020 Kao Che. All rights reserved.
//

import Foundation
import UIKit

class Item {
    var id: String!
    var categoryId: String!
    var name: String!
    var description: String!
    var price: Double!
    var imageLinks: [String]!
    
    init() {
        
    }
    init(_dictionary: NSDictionary) {
        id = _dictionary[kOBJECTID] as? String
        categoryId = _dictionary[kCATEGORYID] as? String
        name = _dictionary[kNAME] as? String
        description = _dictionary[kDESCRIPTION] as? String
        price = _dictionary[kPRICE] as? Double
        imageLinks = _dictionary[kIMAGELINKS] as? [String]
    }
}

// Save item func
func saveItemToFirestore(_ item: Item) {
    FirebaseReference(.Items).document(item.id).setData(itemDictionaryFrom(item) as! [String: Any])
}

//Helper func
func itemDictionaryFrom(_ item: Item) -> NSDictionary {
    
    return NSDictionary(objects: [item.id, item.categoryId, item.name, item.description, item.price, item.imageLinks], forKeys: [kOBJECTID as NSCopying, kCATEGORYID as NSCopying, kNAME as NSCopying, kDESCRIPTION as NSCopying, kPRICE as NSCopying, kIMAGELINKS as NSCopying])
}


//下載func
func downloadItemFromFirebase(withCategoryId: String, completion: @escaping(_ itemArray: [Item]) -> Void) {
    var itemArray: [Item] = []
    FirebaseReference(.Items).whereField(kCATEGORYID, isEqualTo: withCategoryId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(itemArray)
            return
        }
        if !snapshot.isEmpty {
            for itemDict in snapshot.documents {
                itemArray.append(Item(_dictionary: itemDict.data() as NSDictionary))
            }
        }
        completion(itemArray)
    }
    
}

func downloadItems(_ withIds: [String], completion: @escaping (_ itemArray: [Item]) -> Void) {
    
    var count = 0
    var itemArray: [Item] = []
    if withIds.count > 0 {
        
        for itemId in withIds {
            FirebaseReference(.Items).document(itemId).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {
                    completion(itemArray)
                    return
                }
                
                if snapshot.exists {
                    itemArray.append(Item(_dictionary: snapshot.data()! as NSDictionary))
                    count += 1
                    print("印")
                } else {
                    completion(itemArray)
                }
                if count == withIds.count {
                    completion(itemArray)
                }
            }
        }
        
        
    } else {
        completion(itemArray)
    }
}
