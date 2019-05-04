//
//  Service.swift
//  PokedexMVC
//
//  Created by Naoki Arakawa on 2019/04/19.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit

class Service {
  
   //型プロパティ
   static let shared = Service()
   let BASE_URL =  "https://pokedex-bb36f.firebaseio.com/pokemon.json"
  
  //指定したURLにアクセスして、データを取得してくる
  func fetchPokemon(completion: @escaping ([Pokemon]) -> ()) {
    var pokemonArray = [Pokemon]()
  
    
    guard let url = URL(string: BASE_URL) else {return}
    URLSession.shared.dataTask(with: url) {(data, response, error) in
      
      //handle error
      if let error = error {
        
        print("Falied to fetch fata with error...", error.localizedDescription)
        return
        
      }
      
      guard let data = data else {return}
      
      do {
        
        guard let resultArray = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyObject] else { return }
        
        
        //データの分だけ配列に追加している
        for (key, value) in resultArray.enumerated() {
          
          if let dictionary = value as? [String : AnyObject] {
            
            let pokemon = Pokemon(id: key, dictionary: dictionary)
            
            guard let imageUrl = pokemon.imageUrl else {return}
            self.fetchImage(withUrlString: imageUrl, completion: { (image) in
              pokemon.image =  image
              pokemonArray.append(pokemon)
              
              pokemonArray.sort(by: { (poke1, poke2) -> Bool in
                return poke1.id! < poke2.id!
                
              })
              
              
              completion(pokemonArray)
              
            })
            
          }
          
        }
        
      } catch let error {
        
       print("Falied to fetch fata with error...", error.localizedDescription)
        
      }
    }.resume()
  }
  
  private func fetchImage(withUrlString urlString : String, completion: @escaping(UIImage) -> ()){
    
    guard let url = URL(string: urlString) else {return}
    URLSession.shared.dataTask(with: url) {(data, response, error) in
      
      //handle error
      if let error = error {
        
        print("Falied to fetch fata with error...", error.localizedDescription)
        return
        
      }
      
      guard let data = data else {return}
      guard let image = UIImage(data: data) else {return}
      completion(image)
    
    }.resume()
  }
}
