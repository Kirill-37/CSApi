//
//  GroupList.swift
//  Client for VK
//
//  Created by Кирилл Харузин on 05/12/2019.
//  Copyright © 2019 Кирилл Харузин. All rights reserved.
//

import UIKit
import RealmSwift


class GroupList: UITableViewController {
    
    @IBOutlet weak var searchBarGroup: UISearchBar!
    
    var groupList: [Groups] = []
    var vkApi = VKApi()
    
    var cachedAvatars = [String: UIImage]()
    
    
       override func viewDidLoad() {
        super.viewDidLoad()
    
        
        vkApi.getGroups(token: UserSession.shared.token) { () in
            self.loadData()
            self.tableView.reloadData()
        }
        
        let hideAction = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
              view.addGestureRecognizer(hideAction)
        
        //makeSortedSections()
        
        }
    
    func loadData() {
        do {
            let realm = try Realm()
            let groups = realm.objects(Groups.self)
            groupList = Array( groups )
            
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    //Скрытие клавиатуры при тапе в любое место экрана
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

       
       override func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }

       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return groupList.count
       }
       
       let queue = DispatchQueue(label: "Groupss_avatar_download_queue")
       
       private func downloadImage( for url: String, indexPath: IndexPath ) {
           queue.async {
               if self.cachedAvatars[url] == nil {
                if let image = self.vkApi.getImageByURL(imageUrl: url ) {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTemplate", for: indexPath) as? GroupCell else {
            return UITableViewCell()
        }
        cell.groupId.text = groupList[indexPath.row].name
        
        
        let url = groupList[indexPath.row].photo
        if let cashed = cachedAvatars[url] {
            cell.groupAva.image = cashed
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
                self.groupList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                actionPerformed(true)
                        tableView.reloadData()
            }))
     
            self.present(alert, animated: true)
        }

             return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
  
}


