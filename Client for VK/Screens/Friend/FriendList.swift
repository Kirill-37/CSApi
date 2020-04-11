//
//  FriendList.swift
//  Client for VK
//
//  Created by Кирилл Харузин on 05/12/2019.
//  Copyright © 2019 Кирилл Харузин. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift


class FriendList: UITableViewController{
    
    let vkAPI = VKApi()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var friendList: [Friends] = []
    var friendsSection = [Character]()
    var friendsNameArray = [Friends]()
    var cachedAvatars = [String: UIImage]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vkAPI.getFriends(token: UserSession.shared.token) { () in
            self.loadFriends()
            self.friendsSection = self.makeSortedSections(friendsArray: self.friendList)
            self.friendsNameArray = self.friendList
            self.tableView.reloadData()
        }
        //searchBar.delegate = self
        
        let hideAction = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(hideAction)
    
    }
    
    func loadFriends() {
        do {
            let realm = try Realm()
            let friends = realm.objects(Friends.self)
            friendList = Array( friends )
            
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    //Скрытие клавиатуры при тапе в любое место экрана
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    func makeSortedSections(friendsArray: [Friends]) -> [Character] {
    var alphabetArray = [Character]()
    for index in 0..<friendsArray.count {
        
        let firstCharacter = friendsArray[index].name.first!
        alphabetArray.append(firstCharacter)
        
        }
    
    alphabetArray = Array(Set(alphabetArray)).sorted()
    
    return alphabetArray
    }
    

override func numberOfSections(in tableView: UITableView) -> Int {
    return friendsSection.count
       }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           let headerTitle = friendsSection[section]
           return "\(headerTitle)"
       }
    
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       let friendsForSection = friendList.filter { $0.name.first == friendsSection[section] }
            return friendsForSection.count
        }
        
    let queue = DispatchQueue(label: "Friends_avatar_download_queue")
    
    private func downloadImage( for url: String, indexPath: IndexPath ) {
        queue.async {
            if self.cachedAvatars[url] == nil {
                if let image = self.vkAPI.getImageByURL(imageUrl: url) {
                    self.cachedAvatars[url] = image
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTemplate", for: indexPath) as? FriendCell else {
               return UITableViewCell()
           }
        
        cell.username.text = friendList[indexPath.row].name + " " + friendList[indexPath.row].surname
        
        let url = friendList[indexPath.row].photo
        if let cashed = cachedAvatars[url] {
            cell.avatar.image = cashed
        } else {
            downloadImage(for: url, indexPath: indexPath)
        }
            
            return cell
        }
       
      override func tableView(_ tableView: UITableView,
                           trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
            {
                let deleteAction = UIContextualAction(style: .destructive, title:  "Delete"){ (contextualAction, view, actionPerformed: @escaping (Bool) -> ()) in
                    
                    let alert = UIAlertController(title: "Удалить группу", message: "Вы уверены что хотите удалить эту группу?", preferredStyle: .alert)
     
                    alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { (alertAction) in
                actionPerformed(false)
            }))
     
                    alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { (alertAction) in
                self.friendList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                actionPerformed(true)
                        tableView.reloadData()
            }))
     
            self.present(alert, animated: true)
        }

             return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
  
}


