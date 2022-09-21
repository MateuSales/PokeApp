import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!

    private var pokemonID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.backgroundColor = .lightGray
        
        stepper.value = 1
        stepper.minimumValue = 1
        stepper.maximumValue = 100
        
        pokemonID = Int(stepper.value)
        idLabel.text = "Pokemon ID: \(pokemonID)"
    }
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        pokemonID = Int(sender.value)
        idLabel.text = "Pokemon ID: \(pokemonID)"
    }
}

