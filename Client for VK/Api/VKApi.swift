//
//  VKApi.swift
//  Client for VK
//
//  Created by Кирилл Харузин on 15.03.2020.
//  Copyright © 2020 Кирилл Харузин. All rights reserved.
//

//MARK: HW2 API vk.com
import Foundation
import Alamofire
import SwiftyJSON

//MARK: HW2 API vk.com


class VKApi {


    let vkURL = "https://api.vk.com/method/"
    
    func getFriends(token: String, completion: @escaping ([Friends]) -> Void) {
        
        let path = "friends.get"
        
        let params: Parameters = [
            "access_token" : token,
            "fields" : "photo_50",
            "v" : "5.103"
        ]
            
        let requestURL = vkURL + path
        
            AF.request(requestURL,
                              method: .post,
                              parameters: params).responseJSON { [completion] (response) in
                              if let error = response.error {
                                  print(error)
                              } else {
                                  guard let data = response.data else { return }
                                  
                                var friend = self.parseFriends(data: data)
                                print(friend)
                                completion(friend)
                                }

            }
        }
    
    
    func getGroups(token: String, completion: @escaping ([Groups]) -> Void) {
        
            let path = "groups.get"
        
            let params: Parameters = [
            "access_token" : token,
            "extended" : 1,
            "v" : "5.103"
        ]
        
        
        let requestURL = vkURL + path
            AF.request(requestURL,
                              method: .post,
                              parameters: params).responseJSON { [completion] (response) in
                              if let error = response.error {
                                  print(error)
                              } else {
                                  guard let data = response.data else { return }
                                  
                                let groups = self.parseGroups(data: data)
                                print(groups)
                                  
                                  completion(groups)
                              }
        }
    }
    
    func getPhotos(token: String, completion: @escaping ([Photos]) -> Void) {
        
        let path = "photos.get"
        
        let params: Parameters = [
            "access_token" : token,
            "owner_id" : -1,
            "v" : "5.103"
        ]
        
        let requestURL = vkURL + path
            AF.request(requestURL,
                              method: .post,
                              parameters: params).responseJSON { [completion] (response) in
                              if let error = response.error {
                                  print(error)
                              } else {
                                  guard let data = response.data else { return }
                                  
                                  let photos = self.parseFriends(data: data)
                                    print(photos)
                                      
                                      completion([])
                                  }
        }
    }
   
    func parseFriends(data: Data) -> [Friends] {
        do {
            let json = try JSON(data: data)
            let array = json["response"]["items"].arrayValue
            
            let result = array.map { item -> Friends in
                let friend = Friends()
                
                friend.id = item["id"].intValue
                friend.name = item["first_name"].stringValue
                friend.surname = item["last_name"].stringValue
                friend.photo = item["photo_50"].stringValue
                
                return friend
            }
            
            return result
            
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func parseGroups(data: Data) -> [Groups] {
        do {
            let json = try JSON(data: data)
            let array = json["response"]["items"].arrayValue
            
         let result = array.map { item -> Groups in
             let groups = Groups()
            
                 groups.name = item["name"].stringValue
                 groups.photo = item["photo_50"].stringValue
                 groups.type = item["activity"].stringValue
                 groups.id = item["id"].intValue
                
                return groups
            }
            
            return result
            
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

        func getImageByURL(imageUrl: String) -> UIImage? {
            let urlString = imageUrl
                guard let url = URL(string: urlString) else { return nil }
                
                if let imageData: Data = try? Data(contentsOf: url) {
                    return UIImage(data: imageData)
                }
                
                return nil
        }


        func parsePhotos(data: Data) -> [Photos] {
        do {
            let json = try JSON(data: data)
            let array = json["response"]["items"].arrayValue
            
            let result = array.map { item -> Photos in
                let photo = Photos()
                
                photo.id = item["id"].intValue
                photo.ownerID = item["owner_id"].intValue
                
                let sizeValues = item["sizes"].arrayValue
                if let first = sizeValues.first(where: { $0["type"].stringValue == "z" }) {
                    photo.imageURL = first["url"].stringValue
                }
                
                return photo
            }
            
            return result
            
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}

