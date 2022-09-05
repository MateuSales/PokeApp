import UIKit

enum HomeFactory {
    static func make() -> UIViewController {
        let service = HomeService(urlString: "https://pokeapi.co/api/v2/pokemon/", session: URLSession.shared)
        let presenter = HomePresenter(service: service, pokemonID: 1)
        let viewController = HomeViewController(presenter: presenter)
        presenter.delegate = viewController
        
        return viewController
    }
}
