//
//  RegisterViewController.swift
//  chatApp
//
//  Created by huy on 22/09/2022.
//

import FirebaseAuth
import JGProgressHUD
import UIKit

class RegisterViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let firstNameTF: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .continue
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.placeholder = "First Name..."
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        tf.leftViewMode = .always
        tf.backgroundColor = .white
        return tf
    }()
    
    private let lastNameTF: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .continue
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.placeholder = "Last Name..."
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        tf.leftViewMode = .always
        tf.backgroundColor = .white
        return tf
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
    
    private let registerButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Register", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Create Account"
        
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameTF)
        scrollView.addSubview(lastNameTF)
        scrollView.addSubview(emailTF)
        scrollView.addSubview(passwordTF)
        scrollView.addSubview(registerButton)
        
        scrollView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProflePicture))
        imageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 2
        imageView.frame = CGRect(x: (scrollView.width - size) / 2, y: 0, width: size, height: size)
        imageView.layer.cornerRadius = imageView.width / 2

        firstNameTF.frame = CGRect(x: 30, y: imageView.bottom + 20, width: scrollView.width - 60, height: 52)
        lastNameTF.frame = CGRect(x: 30, y: firstNameTF.bottom + 20, width: scrollView.width - 60, height: 52)
        emailTF.frame = CGRect(x: 30, y: lastNameTF.bottom + 20, width: scrollView.width - 60, height: 52)
        passwordTF.frame = CGRect(x: 30, y: emailTF.bottom + 20, width: scrollView.width - 60, height: 52)
        registerButton.frame = CGRect(x: 30, y: passwordTF.bottom + 20, width: scrollView.width - 60, height: 52)
    }
    
    @objc private func didTapRegisterButton() {
        firstNameTF.resignFirstResponder()
        lastNameTF.resignFirstResponder()
        emailTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
        
        spinner.show(in: view)
        
        guard let firstName = firstNameTF.text,
              let lastName = lastNameTF.text,
              let email = emailTF.text,
              let password = passwordTF.text,
              !firstName.isEmpty, !lastName.isEmpty,
              !email.isEmpty, !password.isEmpty, password.count >= 6
        else {
            DispatchQueue.main.async {
                self.spinner.dismiss(animated: true)
            }
            alertUserRegisterError()
            return
        }
        
        DatabaseManager.shared.userDoesExist(email: email) { [weak self] _, userData in
            
            guard userData == nil else {
                DispatchQueue.main.async {
                    self?.spinner.dismiss(animated: true)
                }
                self?.alertUserRegisterError(message: "Looks like a user account for that email address has already existed")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Đăng ký tài khoản thất bại.")
                    print(error!.localizedDescription)
                    DispatchQueue.main.async {
                        self?.spinner.dismiss(animated: true)
                    }
                    self?.alertUserRegisterError(message: "Đăng kí tài khoản thất bại, do không thể tạo user mới trên cơ sở dữ liệu.")
                    return
                }
                
                let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser) { success in
                    if success {
                        // upload image
                        guard let image = self?.imageView.image,
                              let data = image.pngData()
                        else {
                            return
                        }
                        
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
                    }
                }
                UserDefaults.standard.set(email, forKey: "email")
                print("Đăng ký thành công")
                self?.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    private func alertUserRegisterError(message: String = "Please enter all information to create a new account") {
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapChangeProflePicture() {
        presentPhotoActionSheet()
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTF {
            lastNameTF.becomeFirstResponder()
        }
        else if textField == lastNameTF {
            emailTF.becomeFirstResponder()
        }
        else if textField == emailTF {
            passwordTF.becomeFirstResponder()
        }
        else if textField == passwordTF {
            didTapRegisterButton()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func presentPhotoActionSheet() {
        let alert = UIAlertController(title: "Profile Picture",
                                      message: "How would you like to select a picture?",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "Take a photo",
                                      style: .default,
                                      handler: { [weak self] _ in
                                          self?.presentCamera()
                                      }))
        alert.addAction(UIAlertAction(title: "Choose a photo",
                                      style: .default,
                                      handler: { [weak self] _ in
                                          self?.presentPhotoLibrary()
                                      }))
        present(alert, animated: true)
    }
    
    private func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    private func presentPhotoLibrary() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
