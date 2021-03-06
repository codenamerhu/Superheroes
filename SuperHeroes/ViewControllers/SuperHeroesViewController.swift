//
//  SuperHeroesViewController.swift
//  SuperHeroes
//
//  Created by SBI Admin on 2020/06/21.
//  Copyright © 2020 Rhulani Ndhlovu. All rights reserved.
//

import UIKit
import Kingfisher

class SuperHeroesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var heroes : [Superhero] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        super.viewDidLoad()
        setupSearchController()
        self.extendedLayoutIncludesOpaqueBars = true
        self.definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - Helpers
    
    func setupSearchController() {
        // Setup the Search Controller
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Superheroes"
        searchController.searchBar.tintColor = UIColor.white
        searchController.hidesNavigationBarDuringPresentation = false
        
        // Setting color of searchbar textfield text
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        // Setting attributes for search bar textfield
        let scb = self.searchController.searchBar
        if let textfield = scb.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = UIColor.white
                backgroundview.layer.cornerRadius = 13
                backgroundview.clipsToBounds = true
                
            }
        }
        self.navigationItem.searchController = searchController
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterHeroesForSearchText(_ searchText: String) {
        DispatchQueue.global(qos: .background).async {
            NetworkingLayer.requestGETURL(.search(nameString: searchText), success: { (data) in
                self.removeSpinner()
                let heroData = try? JSONDecoder().decode(Superheroes.self, from: data)
                if let heroes = heroData?.results{
                    self.heroes = heroes
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

}


extension SuperHeroesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() {
            if self.heroes.count > 0{
                return self.heroes.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "heroCell", for: indexPath) as! HeroCollectionViewCell
        
        if isFiltering() {
            if  self.heroes.count > 0{
                let hero = self.heroes[indexPath.item]
                let url = URL(string: hero.imageURL)
                cell.heroImage.kf.setImage(with: url)
                cell.heroName.text = hero.name
                cell.heroType.text = hero.biography?.alignment
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("clicked")
        let superheroVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "superheroVC") as! SuperheroViewController
        superheroVC.hero = heroes[indexPath.item]
        present(superheroVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
}

extension SuperHeroesViewController:  UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if searchBarIsEmpty(){
            self.heroes = []
            if collectionView != nil {
                collectionView.reloadData()
            }
            return
        } else {
            filterHeroesForSearchText(searchController.searchBar.text!)
        }
    }
}

class HeroCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var heroName: UILabel!
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var heroType: UILabel!
    
}
