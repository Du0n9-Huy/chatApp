//
//  MainTabBarViewController.swift
//  chatApp
//
//  Created by huy on 07/10/2022.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc1 = ConversationsViewController()
        let vc2 = ProfileViewController()
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)

        nav1.tabBarItem = UITabBarItem(title: "Chats", image: UIImage(systemName: "ellipsis.message"), selectedImage: UIImage(systemName: "ellipsis.message.fill"))
        nav2.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))

        setViewControllers([nav1, nav2], animated: true)
    }
}
