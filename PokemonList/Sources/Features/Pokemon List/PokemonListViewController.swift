//
//  PokemonListViewController.swift
//  PokemonList
//
//  Created by Bruno Luiz on 02/07/18.
//  Copyright © 2018 Bruno Luiz. All rights reserved.
//

import UIKit

class PokemonListViewController: UIViewController {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    var pokemons: [PokemonResult] = []
    
    let activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.color = .black
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        
        self.tableViewOutlet.tableFooterView = UIView(frame: .zero)
        
        self.loadData()
    }
    
    func loadData() {
        self.activityIndicator.startAnimating()
        let offset = self.pokemons.count == 0 ? 0 : self.pokemons.count - 1
        PokemonListProvider.getAll(fromOffSet: offset) { (pokemonResults, isSuccess, error) in
            self.pokemons.append(contentsOf: pokemonResults)
            self.activityIndicator.stopAnimating()
            self.tableViewOutlet.reloadData()
            if isSuccess == false {
                let alertController: UIAlertController = UIAlertController(title: "Access Error!", message: "Can't connect to database.", preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}

extension PokemonListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pokemonResultCell = tableView.dequeueReusableCell(withIdentifier: "PokemonResultCell", for: indexPath)
        pokemonResultCell.textLabel?.text = pokemons[indexPath.row].name?.capitalized
        
        return pokemonResultCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.pokemons.count - 1 {
            self.loadData()
        }
    }
    
}

extension PokemonListViewController: UITableViewDelegate {
    
}
