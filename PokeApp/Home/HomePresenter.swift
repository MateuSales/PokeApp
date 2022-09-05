import Foundation
import UIKit

protocol HomePresenting {
    func fetchPokemon()
    func updateID(_ pokemonID: Int)
}

protocol HomePresenterDelegate: AnyObject {
    func displayPokemon(with viewModel: HomeViewModel)
    func displayImage(with image: UIImage)
    func displayError()
}

class HomePresenter {
    private let service: HomeServicing
    private var pokemonID: Int
    weak var delegate: HomePresenterDelegate?
    
    init(service: HomeServicing, pokemonID: Int) {
        self.service = service
        self.pokemonID = pokemonID
    }
}

extension HomePresenter: HomePresenting {
    func fetchPokemon() {
        getPokemon()
    }
    
    func updateID(_ pokemonID: Int) {
        self.pokemonID = pokemonID
        getPokemon()
    }
}

private extension HomePresenter {
    func getPokemon() {
        service.getPokemon(id: pokemonID) { [weak self] result in
            switch result {
            case .success(let pokemon):
                self?.handleSuccessGetPokemon(with: pokemon)
            case .failure:
                self?.delegate?.displayError()
            }
        }
    }
    
    func handleSuccessGetPokemon(with pokemon: Pokemon) {
        delegate?.displayPokemon(
            with: .init(
                pokemonName: pokemon.name.uppercased(),
                pokemonIDText: "Pokemon ID: \(pokemonID)")
        )

        getImage(with: pokemon.sprites.other.official.urlImage)
    }
    
    func getImage(with url: String) {
        service.getImage(urlImage: url) { [weak self] result in
            switch result {
            case .failure:
                self?.delegate?.displayError()
            case .success(let data):
                self?.handleSuccessGetImage(with: data)
            }
        }
    }
    
    func handleSuccessGetImage(with data: Data) {
        guard let image = UIImage(data: data) else {
            delegate?.displayError()
            return
        }
        
        delegate?.displayImage(with: image)
    }
}
