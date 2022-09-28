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
}

extension DatabaseManager {
    func userDoesExist(email: String, completion: @escaping (Bool) -> Void) {
        let safeEmailAddress = email.replacingOccurrences(of: ".", with: "-")
        database.child(safeEmailAddress).observeSingleEvent(of: .value) { snapshot in
            guard let user = snapshot.value as? [String:Any] else {
                completion(false)
                return
            }
            print(user)
            completion(true)
        }
    }

    func insertUser(with user: chatAppUser) {
        database.child(user.safeEmailAddress).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
        ])
    }
}

struct chatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String

    var safeEmailAddress: String {
        return emailAddress.replacingOccurrences(of: ".", with: "-")
    }
}
