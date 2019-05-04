//
//  Pokemon.swift
//  PokedexMVC
//
//  Created by Naoki Arakawa on 2019/04/19.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit

struct EvolutionChain {
  
  var evolutionArray : [[String : AnyObject]]?
  var evolutionIds = [Int]()
  
  init(evolutionArray: [[String : AnyObject]]) {
    self.evolutionArray = evolutionArray
    self.evolutionIds = setEvolutionIds()
    
  }
  
  func setEvolutionIds() -> [Int]{
    var results = [Int]()
    evolutionArray?.forEach({ (dictionary) in
      if let idString = dictionary["id"] as? String {
        
        guard let id = Int(idString) else { return }
        
        if id <= 151 {
          
          results.append(id)
          
        }
      }
    })
    
    return results
  }
}

//Firebasejからデータを取得する際のjsong型の型を作成する
class Pokemon {
  
  var name : String?
  var imageUrl : String?
  var image : UIImage?
  var id : Int?
  var weight : Int?
  var height: Int?
  var defense : Int?
  var attack : Int?
  var description: String?
  var type : String?
  var baseExperience : Int?
  var evolutionChain: [[String : AnyObject]]?
  var evoArray : [Pokemon]?
  
  //型のクラスを初期化して、プログラム実行前に整合性をチェックして、安全に動くようにしている
  init(id: Int, dictionary: [String : Any]){
    
    
    self.id = id
   
    if let name = dictionary["name"] as? String {
      
      self.name = name
      
    }
    if let imageUrl = dictionary["imageUrl"] as? String {
      
      self.imageUrl = imageUrl
      
      
    }
    if let weight = dictionary["weight"] as? Int {
      
      self.weight = weight
      
      
    }
    if let height = dictionary["height"] as? Int {
      
      self.height = height
      
      
    }
    if let defense = dictionary["defense"] as? Int {
      
      self.defense = defense
      
      
    }
    if let attack = dictionary["attack"] as? Int {
      
      self.attack = attack
      
      
    }
    if let description = dictionary["description"] as? String {
      
      self.description = description
      
      
    }
    if let type = dictionary["type"] as? String {
      
      self.type = type
      
      
    }
    if let baseExperience = dictionary["baseExperience"] as? Int {
      
      self.baseExperience = baseExperience
      
      
    }
    
    if let evolutionChain = dictionary["evolutionChain"] as? [[String : AnyObject]]{
    self.evolutionChain = evolutionChain
      
    }
  }
}
