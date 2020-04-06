//
//  GroupList.swift
//  Client for VK
//
//  Created by Кирилл Харузин on 05/12/2019.
//  Copyright © 2019 Кирилл Харузин. All rights reserved.
//

import UIKit


class GroupList: UITableViewController {
    
    @IBOutlet weak var searchBarGroup: UISearchBar!
    
    var groupList: [Groups] = []
    var vkApi = VKApi()
    
    
       override func viewDidLoad() {
        super.viewDidLoad()
    
        
        vkApi.getGroups(token: UserSession.shared.token) { (groups) in
            self.groupList = groups
            self.tableView.reloadData()
        }
        
        let hideAction = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
              view.addGestureRecognizer(hideAction)
        
        //makeSortedSections()
        
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
       
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTemplate", for: indexPath) as? GroupCell else {
               return UITableViewCell()
           }
           cell.groupId.text = groupList[indexPath.row].name
        DispatchQueue.global().async {
            let image = self.vkApi.getImageByURL(imageUrl: self.groupList[indexPath.row].photo)
            DispatchQueue.main.async {
                cell.groupAva.image = image
            }
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


