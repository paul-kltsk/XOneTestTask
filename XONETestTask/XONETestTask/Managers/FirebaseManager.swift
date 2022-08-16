//
//  FirebaseManager.swift
//  XONETestTask
//
//  Created by Павел Кулицкий on 28.11.21.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore
import UIKit

class FirebaseManager {
    
    
    static func getImagesCount(complition: @escaping(Int) -> ()) {
        
        var countOfPhotos: Int = 0
        let db = Firestore.firestore()
        
        let document = db.collection("info").document("AppInfo")
        document.getDocument { document, error in
            if let document = document, document.exists {
                guard let dataDescription = document.get("countOfImages") else {
                    print("ASDADA")
                    return }
                countOfPhotos =  (dataDescription as! Int)
                complition(countOfPhotos)
            }
        }
    }
    
    static func saveCountOfImages(count: Int) {
        let db = Firestore.firestore()
        let document = db.collection("info").document("AppInfo")
        document.setData(["countOfImages" : count], merge: true)
    }
    
    static func getLibraryName(complition: @escaping(String) -> ()) {
        let db = Firestore.firestore()
        let document = db.collection("info").document("AppInfo")
        document.getDocument { document, error in
            if let document = document, document.exists {
                guard let libraryName = document.get("LibraryName") else { return }
                complition(libraryName as! String)
            }
        }
    }
    
    static func saveLibraryName(name: String) {
        let db = Firestore.firestore()
        let document = db.collection("info").document("AppInfo")
        document.updateData(["LibraryName" : name])
    }
    
    
    static func downloadImages(i: Int, complition: @escaping (UIImage) -> ()) {
            let storage = Storage.storage()
            let storageRef = storage.reference().child("photos")
            
                storageRef.child(String(i)).getData(maxSize: 10*1024*1024, completion: { data, error in
                    guard let data = data else { print("NET PHOTO"); return}
                    DispatchQueue.main.async {
                        complition(UIImage(data: data)!)
                    }
                })
    }
    
    
    static func uploadImages(image: UIImage, name: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("photos").child(name)
        
        guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                guard let _ = metadata else {
                    print(error)
                    return
                }
            }
    }
    
}

