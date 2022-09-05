import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    private let pokemonNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.maximumValue = 100
        stepper.minimumValue = 1
        stepper.value = 1
        return stepper
    }()
    
    private let pokemonIDLabel: UILabel = {
        let label = UILabel()
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
        pokemonNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(80)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        pokemonImageView.snp.makeConstraints {
            $0.top.equalTo(pokemonNameLabel.snp.bottom).offset(40)
            $0.size.equalTo(280)
            $0.centerX.equalToSuperview()
        }
        
        stepper.snp.makeConstraints {
            $0.top.equalTo(pokemonImageView.snp.bottom).offset(40)
            $0.leading.equalTo(pokemonImageView.snp.leading).offset(20)
        }
        
        pokemonIDLabel.snp.makeConstraints {
            $0.leading.equalTo(stepper.snp.trailing).offset(30)
            $0.trailing.equalTo(pokemonImageView.snp.trailing)
            $0.centerY.equalTo(stepper.snp.centerY)
        }
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
