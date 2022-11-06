//
//  ChatViewController.swift
//  chatApp
//
//  Created by huy on 12/10/2022.
//

import InputBarAccessoryView
import MessageKit
import UIKit

struct Message: MessageType {
    var sender: MessageKit.SenderType

    var messageId: String

    var sentDate: Date

    var kind: MessageKit.MessageKind
}

struct Sender: SenderType {
    var photoURL: String

    var senderId: String

    var displayName: String
}

class ChatViewController: MessagesViewController {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.timeZone = .current
        return formatter
    }()

    var isNewConversation = false
    let otherUserEmail: String

    private var messages = [Message]()

    private let dummySender = Sender(photoURL: "", senderId: "dummy@gmail.com", displayName: "dummy")

    private let selfSender: Sender? = {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        return Sender(photoURL: "", senderId: email, displayName: "")
    }()

    init(withOtherUserEmail email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
//            print("Self Sender is nil, email should be cached.")
        return selfSender ?? dummySender
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = selfSender
        else {
            return
        }
        let message = Message(sender: selfSender, messageId: "", sentDate: Date(), kind: .text(text))

        // Send Message
        if isNewConversation {
            // create convo in database
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message) { _ in
            }
        }
        else {
            // append to existing conversation data
        }
    }

//    private func createMessageId() -> String? {
//        // date, otherUserEmail, senderEmail, randomInt
//        let dateString = Self.dateFormatter.string(from: Date())
//        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
//            return nil
//        }
//        let newIdentifier = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
//        return newIdentifier
//    }
}
