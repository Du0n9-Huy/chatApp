//
//  LoginViewModel.swift
//  chatApp
//
//  Created by huy on 11/10/2022.
//

import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn

final class LoginViewModel {
    static let shared = LoginViewModel()

    private init() {}

    func getUser(completion: @escaping (GIDGoogleUser) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            guard let user = user, error == nil else {
                print(error!.localizedDescription)
                return
            }
            completion(user)
        }
    }

    func googleSignIn() {
        // 1
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                self?.authenticateUser(for: user, with: error)
            }
        }
        else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            let configuration = GIDConfiguration(clientID: clientID)

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

            // UINavigationController lồng LoginViewController
            guard let loginNav = rootViewController.presentedViewController else { return }

            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: loginNav) {
                [weak self] user, error in
                self?.authenticateUser(for: user, with: error)
            }
        }
    }

    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        // 1-Kiểm tra user có đăng nhập thành công với google hay không.
        guard let user = user, error == nil else {
            print(error!.localizedDescription)
            return
        }
        print("Đã đăng nhập thành công với google.")

        // 2-Thêm user mới vào database, nếu user đã tồn tài rồi thì không thêm lại nữa.
        guard let email = user.profile?.email,
              let firstName = user.profile?.givenName,
              let lastName = user.profile?.familyName,
              let userHasImage = user.profile?.hasImage
        else {
            return
        }
        DatabaseManager.shared.userDoesExist(email: email) { userDoesExist in
            if !userDoesExist {
                // insert to firebase database
                let chatUser = chatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser) { success in
                    if success && userHasImage {
                        guard let pictureURL = user.profile?.imageURL(withDimension: 200) else {
                            return
                        }
                        // Downloading data from Google image
                        URLSession.shared.dataTask(with: pictureURL) { data, _, error in
                            guard let data = data, error == nil else {
                                print("Failed to get data from Google.")
                                return
                            }
                            //Got data from Google. Uploading...
                            // upload image
                            let fileName = chatUser.profilePictureFilename
                            StorageManager.shared.uploadProfilePicture(with: data, filename: fileName) { result in
                                switch result {
                                case .success(let downloadURL):
                                    UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                    print("Download Url returned: \(downloadURL)")
                                case .failure(let error):
                                    print("StorageErrors: \(error) ")
                                }
                            }
                        }.resume()
                    }
                }
            }
        }

        // 3-Truy xuất credential từ user đăng nhập thành công với google
        guard let idToken = user.authentication.idToken else { return }
        let accessToken = user.authentication.accessToken

        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

        // 4-Đăng nhập user với FirebaseAuth, nếu đăng nhập thành công thì tắt màn hình đăng nhập hiện tại
        Auth.auth().signIn(with: credential) {
            authResult, error in
            guard authResult != nil, error == nil else {
                print(error!.localizedDescription)
                return
            }
            print("Successfully logged user in with Google.")

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

            // UINavigationController lồng LoginViewController
            guard let loginNav = rootViewController.presentedViewController else { return }

            loginNav.dismiss(animated: true)
        }
    }
}
