import Foundation
import AsyncDisplayKit

class ASActivityIndicatorNode: ASDisplayNode {
    private let indicatorNode = ASDisplayNode(viewBlock: {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activity.hidesWhenStopped = true
        activity.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        return activity
    })
    
    override init() {
        super.init()
        self.indicatorNode.isHidden = true
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASCenterLayoutSpec(centeringOptions: .XY,
                                  sizingOptions: [],
                                  child: self.indicatorNode)
    }
    
    func showActivityIndicoator() {
        guard !self.isVisible else { return }
        DispatchQueue.main.async {
            guard let activityIndicatorView = self.indicatorNode.view as? UIActivityIndicatorView else { return }
            UIView.animate(withDuration: 0.5, animations: {
                activityIndicatorView.startAnimating()
            }, completion: nil)
        }
    }
    
    func hideActivityIndicator() {
        guard self.isVisible else { return }
        DispatchQueue.main.async {
            guard let activityIndicatorView = self.indicatorNode.view as? UIActivityIndicatorView else { return }
            UIView.animate(withDuration: 0.5, animations: {
                activityIndicatorView.stopAnimating()
            }, completion: { complete in
                guard complete else { return }
                self.isHidden = true
            })
        }
    }
}
