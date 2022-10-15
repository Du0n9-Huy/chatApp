//
//  StorageManager.swift
//  chatApp
//
//  Created by huy on 14/10/2022.
//

import FirebaseStorage
import Foundation
final class StorageManager {
    static let shared = StorageManager()
    private init() {}
    private let storage = Storage.storage().reference()

    /*
     example fileName: /images/huy@gmail-com_profile_picture.png
     */

    /// Upload picture to Firebase Storage and returns completion with url string to download
    typealias UploadPictureCompletion = (Result<String, StorageErrors>) -> Void

    func uploadProfilePicture(with data: Data, filename: String, completion: @escaping UploadPictureCompletion) {
        // 1 - Tải dữ liệu hình ảnh lên Firebase Storage
        storage.child("images/\(filename)").putData(data) { [weak self] metadata, error in

            // 2.1 - Nếu tải dữ liệu hình ảnh lên Firebase Storage thất bại
            guard metadata != nil, error == nil else {
                // 2.1 - Thực hiện bước tiếp theo với 1 lỗi
                completion(.failure(.failedToUpload))
                return
            }

            // 2.2 - Nếu tải dữ liệu hình ảnh lên Firebase Storage thành công
            // 2.2 - Truy xuất url của dữ liệu hình ảnh vừa mới tải lên Firebase Storage
            self?.storage.child("images/\(filename)").downloadURL { url, error in

                // 3.1 - Nếu truy xuất url của dữ liệu hình ảnh thất bại
                guard let url = url, error == nil else {
                    // 3.1 - Thực hiện bước tiếp theo với 1 lỗi
                    completion(.failure(.failedToGetDownloadURL))
                    return
                }

                // 3.2 - Nếu truy xuất url của dữ liệu hình ảnh thành công
                // 3.2 - Thực hiện bước tiếp theo với 1 chuỗi url
                let urlString = url.absoluteString
                completion(.success(urlString))
            } 
        }
    }

    enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
}
