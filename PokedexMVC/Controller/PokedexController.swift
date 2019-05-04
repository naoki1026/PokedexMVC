//
//  PokedexController.swift
//  PokedexMVC
//
//  Created by Naoki Arakawa on 2019/04/18.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import UIKit

//ここにreuseIdentifierとして定義しておくことでヒューマンエラーを防ぐことができる
private let reuseIdentifier = "PokedexCell"

class PokedexController : UICollectionViewController {
  
//MARK:Properties
var pokemon = [Pokemon]()
var filteredPokemon = [Pokemon]()
var inSearchMode = false
var searchBar: UISearchBar!
  
  let infoView : InfoView = {
    
    let view = InfoView()
    view.layer.cornerRadius = 5
    return view
    
  }()
  
  let visualEffectView : UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: .dark)
    let view = UIVisualEffectView(effect: blurEffect)
    return view
    
  }()
  
//MARK:Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
  configureViewConponents()
  fetchPokemon()
    
  }
  
  //MARK: Selectors
  @objc func showSearchBar(){
    
   configureSearchBar(shouldShow: true)
  
  }
  
  @objc func handleDismissal(){
    
     dismissInfoView(pokemon: nil)
    
  }
  
  //MARK: API
  func fetchPokemon(){
    
    Service.shared.fetchPokemon { (pokemon) in
      DispatchQueue.main.async {
        self.pokemon = pokemon
        self.collectionView.reloadData()
        
      }
    }
  }
  
  //MARK: HelperFunctions
  func showPokemonInfoController(withPokemon pokemon : Pokemon){
    
    let controller = PokemonInfoController()
    controller.pokemon = pokemon
    self.navigationController?.pushViewController(controller, animated: true)
    
  }
  
  //画面上部にsearchBarが表示される
  func configureSearchBar(shouldShow: Bool){
    
    if shouldShow {
      
      searchBar = UISearchBar()
      searchBar.delegate = self
      searchBar.sizeToFit()
      searchBar.showsCancelButton = true
      searchBar.becomeFirstResponder()
      searchBar.tintColor = .white
      
      navigationItem.rightBarButtonItem = nil
      navigationItem.titleView = searchBar
      
    } else {
      
      navigationItem.titleView = nil
      configureSearchBarButton()
      inSearchMode = false
      collectionView.reloadData()
      
    }
  }
  
  func configureSearchBarButton(){
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchBar))
    navigationItem.rightBarButtonItem?.tintColor = .white
    
  }
  
  func dismissInfoView(pokemon: Pokemon?){
    
    UIView.animate(withDuration: 0.5, animations: {
      self.visualEffectView.alpha = 0
      self.infoView.alpha = 0
      self.infoView.transform = .identity
      self.infoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    }) { (_) in
      self.infoView.removeFromSuperview()
      self.navigationItem.rightBarButtonItem?.isEnabled = true
      guard let pokemon = pokemon else {return}
      self.showPokemonInfoController(withPokemon: pokemon)
      
    }
    
  }
  
  func configureViewConponents(){
    
    //ViewControllerの場合はviewで、collectionViewの場合はcollectionViewとなる
    collectionView.backgroundColor = .white
    navigationController?.navigationBar.barTintColor = .mainPink()
    navigationController?.navigationBar.barStyle = .black
    navigationController?.navigationBar.isTranslucent = true
    
    navigationItem.title = "Pokedex"
    configureSearchBarButton()
    collectionView.register(PokedexCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    //infoViewが表示される際の黒い部分
    view.addSubview(visualEffectView)
    visualEffectView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    visualEffectView.alpha = 0
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
    visualEffectView.addGestureRecognizer(gesture)
    
  }
}

extension PokedexController {
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
//    return pokemon.count
    return inSearchMode ? filteredPokemon.count : pokemon.count
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PokedexCell
    
    // inserachModeがtrueであればfilteredPokemonになり、falseであればpokemonの方になる
    cell.pokemon = inSearchMode ? filteredPokemon[indexPath.item] : pokemon[indexPath.item]
  
    //cell.pokemon = pokemon[indexPath.item]
    cell.delegate = self
    return cell
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let poke = inSearchMode ? filteredPokemon[indexPath.item] : pokemon[indexPath.item]
    
    var pokemonEvoArray = [Pokemon]()
    
    if let  evoChain  = poke.evolutionChain {
      
      let evolutionChain = EvolutionChain(evolutionArray: evoChain)
      let evoIds = evolutionChain.evolutionIds
      
      evoIds.forEach {(id) in
        pokemonEvoArray.append(pokemon[id - 1])
   
    }
      
      poke.evoArray = pokemonEvoArray
    
  }
    
    showPokemonInfoController(withPokemon: poke)
    
  }
}

//MARK: -UISearchBarDelegate

extension PokedexController: UISearchBarDelegate {
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

    configureSearchBar(shouldShow: false)
    
  }
  
  //サーチバーに文字が入力されるたびに呼び出される
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    if searchText == "" || searchBar.text == nil {
      
      inSearchMode = false
      collectionView.reloadData()
      view.endEditing(true)
      
    } else {
      
      //サーチバーに入力された文字をもとに抽出している
      inSearchMode = true
      filteredPokemon = pokemon.filter({ $0.name?.range(of: searchText.lowercased()) != nil })
      collectionView.reloadData()
//      filteredPokemon.forEach { (pokemon) in
//        print(pokemon.name)
//      }
      
    }
  }
}

//MARK: -UICollectionViewDataSource
extension PokedexController : UICollectionViewDelegateFlowLayout {
  
  //セルとセルの間隔を定義
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
    return UIEdgeInsets(top: 32  , left: 8, bottom: 8, right: 8)
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let width = (view.frame.width - 36) / 3
    return CGSize(width: width, height: width)
    
  }
}

extension PokedexController : PokedexCellDelegate {
  
  
  func presentInfoView(withPokemon pokemon: Pokemon) {
    
    configureSearchBar(shouldShow: false)
    navigationItem.rightBarButtonItem?.isEnabled = false
    
    view.addSubview(infoView)
    infoView.configureViewComponents()
    infoView.delegate = self
    infoView.pokemon = pokemon
    infoView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width - 64, height: 350)
    infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    infoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -44).isActive = true
    
    //infoViewがゆっくり表示される、結果を表示する時に使えそう
    infoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    infoView.alpha = 0
    
    UIView.animate(withDuration: 0.5) {
      self.visualEffectView.alpha = 1
      self.infoView.alpha = 1
      self.infoView.transform = .identity
      
    }
  }
}

extension PokedexController: InfoViewDelegate {
  
  //黒い部分をクリックするとinfoViewが閉じる
  func dismissInfoView(withPokemon pokemon: Pokemon?) {
    
     dismissInfoView(pokemon: pokemon)
    
  }
}
