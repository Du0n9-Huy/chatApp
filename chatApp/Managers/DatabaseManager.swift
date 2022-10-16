//
//  Database.swift
//  chatApp
//
//  Created by huy on 28/09/2022.
//

import FirebaseFirestore
import Foundation

final class DatabaseManager {
    static let shared = DatabaseManager()
    private init() {}

    private let db = Firestore.firestore()
}

extension DatabaseManager {
    func userDoesExist(email: String, completion: @escaping (Bool) -> Void) {
        let safeEmailAddress = email.replacingOccurrences(of: ".", with: "-")
        let document = db.collection("users").document(safeEmailAddress)
        document.getDocument { document, error in
            guard let data = document?.data(),
                  error == nil
            else {
                completion(false)
                return
            }
            print("User does exist on FirestoreDatabase", data)
            completion(true)
        }
    }

    func insertUser(with user: chatAppUser, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(user.safeEmailAddress).setData(
            [
                "first_name": user.firstName,
                "last_name": user.lastName,
            ]) { error in
                guard error == nil else {
                    print("Failed to write to Firebase Firestore")
                    completion(false)
                    return
                }
                completion(true)
            }
    }
}

struct chatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String

    var safeEmailAddress: String {
        return emailAddress.replacingOccurrences(of: ".", with: "-")
    }

    var profilePictureFilename: String {
        return "\(safeEmailAddress)_profile_picture.png"
    }
}
