import UIKit

enum PokeError: Error {
    case invalidURL
    case requestError
    case decodedError
    case invalidData
}

class ViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!

    private var pokemonID = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepper.value = 0
        stepper.minimumValue = 1
        stepper.maximumValue = 100
        
        pokemonID = Int(stepper.value)

        idLabel.text = "Pokemon ID: \(pokemonID)"

        makeRequest { [weak self] result in
            switch result {
            case .success(let pokemon):
                self?.handleSuccess(pokemon)
            case .failure:
                self?.showAlert()
            }
        }
    }

    func makeRequest(completion: @escaping (Result<Pokemon, PokeError>) -> Void) {
        guard let url = URL(
            string: "https://pokeapi.co/api/v2/pokemon/\(pokemonID)/"
        ) else {
            return completion(.failure(.invalidURL))
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    return completion(.failure(.requestError))
                }
                
                if let data = data {
                    guard let pokemon = try? JSONDecoder().decode(Pokemon.self, from: data) else {
                        return completion(.failure(.decodedError))
                    }
                    
                    completion(.success(pokemon))
                } else {
                    completion(.failure(.invalidData))
                }
            }
        }.resume()
    }
    
    func showAlert() {
        let alertController = UIAlertController(
            title: "Error",
            message: "Aconteceu algo de errado na requisição!!!",
            preferredStyle: .alert
        )
        
        alertController.addAction(.init(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        pokemonID = Int(sender.value)
        idLabel.text = "Pokemon ID: \(pokemonID)"
        
        makeRequest { [weak self] result in
            switch result {
            case .success(let pokemon):
                self?.handleSuccess(pokemon)
            case .failure:
                self?.showAlert()
            }
        }
    }

    func handleSuccess(_ pokemon: Pokemon) {
        name.text = pokemon.name.uppercased()
        
        guard let urlImage = URL(string: pokemon.sprites.other.official.urlImage) else { return }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: urlImage),
                  let imagePokemon = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.image.image = imagePokemon
            }
        }
    }
}

