//
//  Database.swift
//  chatApp
//
//  Created by huy on 28/09/2022.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

final class DatabaseManager {
    static let shared = DatabaseManager()
    private init() {}
    private let db = Firestore.firestore()
}

// MARK: Database Insert

extension DatabaseManager {
    typealias userDoesExistCompletion = (DocumentReference, [String: Any]?) -> Void
    func userDoesExist(email: String, completion: @escaping userDoesExistCompletion) {
        let safeEmailAddress = email.replacingOccurrences(of: ".", with: "-")
        let userRef = db.collection("users").document(safeEmailAddress)
        userRef.getDocument { docSnapshot, error in
            guard let data = docSnapshot?.data(),
                  error == nil
            else {
                completion(userRef, nil)
                return
            }
            print("User does exist on FirestoreDatabase")
            completion(userRef, data)
        }
    }

    func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(user.safeEmailAddress).setData(
            [
                "first_name": user.firstName,
                "last_name": user.lastName,
                "keywords": createUserSearchKeywords(withName: "\(user.$lastName) \(user.$firstName)")
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

// MARK: Database Search

extension DatabaseManager {
    typealias searchUsersCompletion = (Result<[ChatAppUser], DatabaseSearchError>) -> Void
    func searchUsers(thatHaveNamesLike searchText: String, completion: @escaping searchUsersCompletion) {
        let searchTextComponents = searchText.NSC_UCR_RWR_map()
        guard !searchTextComponents.isEmpty else {
            completion(.failure(.InvalidSearchText))
            return
        }

        let usersRef = db.collection("users")
        var query = usersRef.whereField("keywords.\(searchTextComponents[0])", isEqualTo: true)
        for (index, component) in searchTextComponents.enumerated() {
            guard index != 0 else {
                continue
            }
            query = query.whereField("keywords.\(component)", isEqualTo: true)
        }
        query.getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot, error == nil else {
                print(error!.localizedDescription)
                completion(.failure(.failedToSearchUsers))
                return
            }
            let results = querySnapshot.documents.compactMap { document in
                var userDict = document.data()
                userDict["email_adddress"] = document.documentID.replacingOccurrences(of: "-", with: ".")
                userDict["keywords"] = nil
                return ChatAppUser(dictionary: userDict)
            }

            guard results.count > 0 else {
                completion(.failure(.DocumentSerializationFailure))
                return
            }
            completion(.success(results))
        }
    }

    private func createUserSearchKeywords(withName name: String) -> [String: Bool] {
        // không cần phải .trimmingCharacters(in: .whitespacesAndNewlines)
        // vì ở dưới reduce sẽ xử lý
        var keywords = [String: Bool]()
        let nameComponents = name.lowercased().components(separatedBy: .whitespaces)
        nameComponents.forEach { component in
            // nếu component.count = 0, thì reduce trả về initialResult
            _ = component.reduce("") { currentString, char in
                // char is of type String.Element (aka 'Character')
                let nextString = currentString + String(char)
                keywords[nextString] = true
                return nextString
            }
        }
        return keywords
    }

    enum DatabaseSearchError: Error {
        case InvalidSearchText
        case failedToSearchUsers
        case DocumentSerializationFailure
    }
}

// MARK: - Sending messages  conversations

extension DatabaseManager {
    /// Creates a new conversation with target user email and first sent message
    func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("User email has not been cached - func-createNewConversation")
            completion(false)
            return
        }
        let safeEmail = currentUserEmail.replacingOccurrences(of: ".", with: "-")

        DatabaseManager.shared.userDoesExist(email: safeEmail) { [weak self] userRef, userData in
            guard userData != nil else {
                print("User not found - func-createNewConversation")
                completion(false)
                return
            }
            let conversationRef = (self?.db.collection("conversations").document())!

            let newConversationData: [String: Any] = [
                "conversation_name": "",
                "is_personal_conversation": true,
                "is_group_conversation": false,
                "conversation_picture": "",
                "tag": "",
                "is_pinned": false,
                "is_active": true
            ]

            conversationRef.setData(newConversationData) { error in
                guard error == nil else {
                    print("Top-level conversation data can not be set in Cloud Firestore - func-createNewConversation")
                    completion(false)
                    return
                }

                let messageRef = conversationRef.collection("messages").document()

                var messageData: [String: Any] = [
                    "content": "",
                    "content_type": "",
                    "date": ChatViewController.dateFormatter.string(from: firstMessage.sentDate),
                    "is_read": false,
                    "sender_email": currentUserEmail,
                    "receiver_email": otherUserEmail
                ]

                switch firstMessage.kind {
                case .text(let messageText):
                    messageData["content"] = messageText
                    messageData["content_type"] = "text"
                case .attributedText:
                    break
                case .photo:
                    break
                case .video:
                    break
                case .location:
                    break
                case .emoji:
                    break
                case .audio:
                    break
                case .contact:
                    break
                case .linkPreview:
                    break
                case .custom:
                    break
                }

                messageRef.setData(messageData) { error in
                    guard error == nil else {
                        print("Message data in top-level conversation data can not be set in Cloud Firestore - func-createNewConversation")
                        completion(false)
                        return
                    }

                    let conversationInUserConversationListRef = userRef.collection("conversationList").document("\(conversationRef.documentID)")

                    var dataOfConversationInUserConversationList = newConversationData

                    dataOfConversationInUserConversationList["latest_message"] = [messageRef.documentID: messageData]

                    conversationInUserConversationListRef.setData(dataOfConversationInUserConversationList) { error in
                        guard error == nil else {
                            print("Conversation data in 'users' collection can not be set in Cloud Firestore - func-createNewConversation")
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }

            //
        }
    }

    /// Fetches and returns all conversations for the user with passed-in email
    func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        //
    }

    /// Gets all messages for a given conversation
    func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        //
    }

    /// Sends a message with target conversation and message
    func sendMessage(to conversation: String, message: Message, Completion: @escaping (Bool) -> Void) {
        //
    }
}
