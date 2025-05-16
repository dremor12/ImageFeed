import UIKit

enum ShimmerLayer {
    
    static func add(to views: [UIView], cornerRadius: CGFloat = 4) -> Set<CALayer> {
        var layers = Set<CALayer>()
        for view in views {
            let layer = gradient(for: view, cornerRadius: cornerRadius)
            view.layer.addSublayer(layer)
            layers.insert(layer)
        }
        return layers
    }
    
    static func remove(layers: Set<CALayer>) {
        layers.forEach { $0.removeFromSuperlayer() }
    }
    
    private static func gradient(for view: UIView,
                                 cornerRadius: CGFloat) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors    = shimmerColors
        gradient.locations = [0, 0.1, 0.3]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue    = [0, 0.1, 0.3]
        animation.toValue      = [0, 0.8, 1]
        animation.duration     = 1
        animation.repeatCount  = .infinity
        gradient.add(animation, forKey: "shimmer")
        return gradient
    }
    
    private static let shimmerColors: [CGColor] = [
        UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
        UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
        UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
    ]
}
