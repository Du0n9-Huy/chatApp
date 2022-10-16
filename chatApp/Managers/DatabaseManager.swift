//
//  Database.swift
//  chatApp
//
//  Created by huy on 28/09/2022.
//

import FirebaseDatabase
import Foundation

final class DatabaseManager {
    static let shared = DatabaseManager()
    private init() {}

    private let database = Database.database().reference()

    static func safeEmailAddress(emailAddress: String) -> String {
        return emailAddress.replacingOccurrences(of: ".", with: "-")
    }
}

extension DatabaseManager {
    func userDoesExist(email: String, completion: @escaping (Bool) -> Void) {
        let safeEmailAddress = email.replacingOccurrences(of: ".", with: "-")
        database.child(safeEmailAddress).observeSingleEvent(of: .value) { snapshot in
            guard let user = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            print("User does exist on realtime-database", user)
            completion(true)
        }
    }

    func insertUser(with user: chatAppUser, completion: @escaping (Bool) -> Void) {
//        database.child(user.safeEmailAddress).setValue([
//            "first_name": user.firstName,
//            "last_name": user.lastName,
//        ]) { error, _ in
//            guard error == nil else {
//                print("Failed to write to Firebase")
//                completion(false)
//                return
//            }
//            completion(true)
//        }
        database.child("sadas").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let value = snapshot.value else {
                print("failed to cast")
                return
            }
            print("cos gia tri,", value)

            print(value as? [[String: String]])
//            if var usersCollection = snapshot.value as? [[String: String]] {
//                let newUser = [
//                    "name": "\(user.firstName) \(user.lastName)",
//                    "email": user.emailAddress
//                ]
//                usersCollection.append(newUser)
//
//                self?.database.child("users").setValue(usersCollection) { error, _ in
//                    guard error == nil else {
//                        completion(false)
//                        return
//                    }
//                    completion(true)
//                }
//            } else {
//                let newUsersCollection = [[
//                    "name": "\(user.firstName) \(user.lastName)",
//                    "email": user.emailAddress
//                ]]
//
//                self?.database.child("users ").setValue(newUsersCollection) { error, _ in
//                    guard error == nil else {
//                        completion(false)
//                        return
//                    }
//                    completion(true)
//                }
//            }
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
