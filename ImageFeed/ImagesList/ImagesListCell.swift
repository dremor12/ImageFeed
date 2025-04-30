import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    private var animationLayer: CAGradientLayer?
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        hideAnimation()
    }
    
    @IBAction func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "favorites_active" : "favorites_no_active"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func showAnimation() {
        guard animationLayer == nil else { return }
        
        let gradient = CAGradientLayer()
        gradient.frame = cellImage.bounds
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.locations  = [0, 0.1, 0.3]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.fromValue   = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue     = [0, 0.8, 1]
        gradientChangeAnimation.duration    = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradient.add(gradientChangeAnimation, forKey: "shimmer")
        
        cellImage.layer.addSublayer(gradient)
        animationLayer = gradient
    }
    
    func hideAnimation() {
        animationLayer?.removeFromSuperlayer()
        animationLayer = nil
    }
}
