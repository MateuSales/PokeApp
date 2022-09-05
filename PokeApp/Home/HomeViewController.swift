import UIKit

final class HomeViewController: UIViewController {
    private let pokemonNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.maximumValue = 100
        stepper.minimumValue = 1
        stepper.value = 1
        return stepper
    }()
    
    private let pokemonIDLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let presenter: HomePresenting
    
    init(presenter: HomePresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        presenter.fetchPokemon()
    }
}

// MARK: - Layout

private extension HomeViewController {
    func initialSetup() {
        view.backgroundColor = .white
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        addViewsInHierarchy()
        setupConstraints()
    }

    func addViewsInHierarchy() {
        [
            pokemonNameLabel,
            pokemonImageView,
            stepper,
            pokemonIDLabel
        ].forEach {
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            pokemonNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            pokemonNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pokemonNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pokemonImageView.topAnchor.constraint(equalTo: pokemonNameLabel.bottomAnchor, constant: 40),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 280),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 280),
            pokemonImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stepper.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 40),
            stepper.leadingAnchor.constraint(equalTo: pokemonImageView.leadingAnchor, constant: 20),
            
            pokemonIDLabel.leadingAnchor.constraint(equalTo: stepper.trailingAnchor, constant: 30),
            pokemonIDLabel.trailingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor),
            pokemonIDLabel.centerYAnchor.constraint(equalTo: stepper.centerYAnchor)
        ])
    }
}

// MARK: - Privat Methods

private extension HomeViewController {
    func showAlert() {
        let alertController = UIAlertController(
            title: "Error",
            message: "Aconteceu algo de errado na requisição!!!",
            preferredStyle: .alert
        )
        
        alertController.addAction(.init(title: "OK", style: .default))
        present(alertController, animated: true)
    }
        
    @objc func stepperChanged(_ sender: UIStepper) {
        presenter.updateID(Int(sender.value))
    }
}

// MARK: - HomePresenterDelegate

extension HomeViewController: HomePresenterDelegate {
    func displayImage(with image: UIImage) {
        pokemonImageView.image = image
    }
    
    func displayPokemon(with viewModel: HomeViewModel) {
        pokemonNameLabel.text = viewModel.pokemonName
        pokemonIDLabel.text = viewModel.pokemonIDText
    }
    
    func displayError() {
        showAlert()
    }
}
