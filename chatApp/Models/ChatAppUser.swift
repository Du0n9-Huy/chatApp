//
//  User.swift
//  chatApp
//
//  Created by huy on 19/10/2022.
//

import Foundation

@propertyWrapper
struct NSC_UCD_RRW_Formatted {
    private var str: String
    private(set) var projectedValue: String
    var wrappedValue: String {
        get { return str }
        set { (str, projectedValue) = newValue.NSC_UCD_RWR_map() }
    }

    init() {
        str = ""
        projectedValue = ""
    }
}

struct ChatAppUser {
    @NSC_UCD_RRW_Formatted var firstName: String
    @NSC_UCD_RRW_Formatted var lastName: String
    var emailAddress: String // ID

    var safeEmailAddress: String {
        return emailAddress.replacingOccurrences(of: ".", with: "-")
    }

    var profilePictureFilename: String {
        return "\(safeEmailAddress)_profile_picture.png"
    }

    var dictionary: [String: Any] {
        return [
            "email_address": emailAddress,
            "first_name": firstName,
            "last_name": lastName,
        ]
    }

    init(firstName: String, lastName: String, emailAddress: String) {
        self.emailAddress = emailAddress
        self.firstName = firstName
        self.lastName = lastName
    }
}

protocol ChatAppUserDocumentSerializable {
    init?(dictionary: [String: Any])
}

extension ChatAppUser: ChatAppUserDocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let emailAddress = dictionary["email_adddress"] as? String,
              let firstName = dictionary["first_name"] as? String,
              let lastName = dictionary["last_name"] as? String
        else { return nil }

        self.init(firstName: firstName, lastName: lastName, emailAddress: emailAddress)
    }
}
