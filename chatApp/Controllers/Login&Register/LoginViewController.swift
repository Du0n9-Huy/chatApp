//
//  LoginViewController.swift
//  chatApp
//
//  Created by huy on 22/09/2022.
//

import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn
import JGProgressHUD
import UIKit

class LoginViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ZaloLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailTF: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .continue
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.placeholder = "Email Address..."
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        tf.leftViewMode = .always
        tf.backgroundColor = .white
        return tf
    }()
    
    private let passwordTF: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .done
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.placeholder = "Password..."
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        tf.leftViewMode = .always
        tf.backgroundColor = .white
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Log In", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        btn.backgroundColor = .link
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        return btn
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let btn = FBLoginButton()
        btn.permissions = ["public_profile", "email"]
        return btn
    }()
    
    private let googleSignInButton: GIDSignInButton = {
        let btn = GIDSignInButton()
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Login"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegisterButton))
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        facebookLoginButton.delegate = self
        
        googleSignInButton.addTarget(self, action: #selector(didTapGoogleSignInButton), for: .touchUpInside)
        
        emailTF.delegate = self
        passwordTF.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailTF)
        scrollView.addSubview(passwordTF)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleSignInButton)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        let size = scrollView.width / 2
        imageView.frame = CGRect(x: (scrollView.width - size) / 2, y: 0, width: size, height: size)
        emailTF.frame = CGRect(x: 30, y: imageView.bottom + 20, width: scrollView.width - 60, height: 52)
        passwordTF.frame = CGRect(x: 30, y: emailTF.bottom + 20, width: scrollView.width - 60, height: 52)
        loginButton.frame = CGRect(x: 30, y: passwordTF.bottom + 20, width: scrollView.width - 60, height: 52)
        facebookLoginButton.frame = CGRect(x: 30, y: loginButton.bottom + 20, width: scrollView.width - 60, height: 52)
        googleSignInButton.frame = CGRect(x: 30, y: facebookLoginButton.bottom + 20, width: scrollView.width - 60, height: 52)
    }
    
    @objc private func didTapRegisterButton() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapLoginButton() {
        emailTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
        
        spinner.show(in: view)
        
        guard let email = emailTF.text, let password = passwordTF.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6
        else {
            DispatchQueue.main.async {
                self.spinner.dismiss(animated: true)
            }
            alertUserLoginError()
            return
        }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            
            /*
              Whenever you do anything user interface related
              you need to do it on the main thread.
             
             This callback that Firebase gives us comes back on a background thread
             
             So we need to call this function
             "self?/self.spinner.dismiss(animated: true)"
             on the main queue
             */
            
            guard authResult != nil, error == nil else {
                print("Đăng nhập sử dụng email/password thất bại.")
                print(error!.localizedDescription)
                DispatchQueue.main.async {
                    self?.spinner.dismiss(animated: true)
                }
                self?.alertUserLoginError(with: "Sai tài khoản hoặc mật khẩu.")
                return
            }
            print("Đăng nhập sử dụng email/password thành công")
            self?.navigationController?.dismiss(animated: true)
        }
    }
    
    @objc private func didTapGoogleSignInButton() {
        LoginViewModel.shared.googleSignIn()
    }
    
    private func alertUserLoginError(with message: String = "Please enter all information to login") {
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTF {
            passwordTF.becomeFirstResponder()
        }
        else if textField == passwordTF {
            didTapLoginButton()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to login with Facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email,  first_name, last_name, picture.type(large)"],
                                                         tokenString: token, version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make a facebook graph request.")
                return
            }
             
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrlString = data["url"] as? String
            else {
                print("Failed to get email and name from facebook result.")
                return
            }
            
            DatabaseManager.shared.userDoesExist(email: email) { userDoesExist in
                if !userDoesExist {
                    // insert to Firebase database
                    let chatUser = chatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success {
                            guard let url = URL(string: pictureUrlString) else {
                                return
                            }
                            // Downloading data from Facebook image
                            URLSession.shared.dataTask(with: url) { data, _, error in
                                guard let data = data, error == nil else {
                                    print("Failed to get data from Facebook.")
                                    return
                                }
                                // Got data from Facebook. Uploading...
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
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential) {
                [weak self] authResult, error in
                guard authResult != nil, error == nil else {
                    print("Facebook credential login failed, MFA may be neeeded", error!.localizedDescription)
                    return
                }
                print("Successfully logged Facebook user in with Firebase")
                self?.navigationController?.dismiss(animated: true)
            }
        }
    }
}
