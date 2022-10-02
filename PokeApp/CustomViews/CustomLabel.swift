import UIKit

final class CustomLabel: UILabel {
    init(fontSize: CGFloat, weight: UIFont.Weight, textAlignment: NSTextAlignment) {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        numberOfLines = 0
        self.textAlignment = textAlignment
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
