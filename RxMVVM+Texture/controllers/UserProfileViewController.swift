import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

class UserProfileViewController: ASViewController<ASDisplayNode> {
    typealias Node = UserProfileViewController
    
    weak var viewModel: RepositoryViewModel?
    private let disposeBag = DisposeBag()
    
    struct Attribute {
        static let placeHolderColor: UIColor = UIColor.gray.withAlphaComponent(0.2)
    }
    
    lazy var userProfileNode = { () -> ASNetworkImageNode in
        let node = ASNetworkImageNode()
        node.style.preferredSize = CGSize(width: 50.0, height: 50.0)
        node.cornerRadius = 25.0
        node.clipsToBounds = true
        node.placeholderColor = Attribute.placeHolderColor
        node.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        node.borderWidth = 0.5
        
        return node
    }()
    
    lazy var usernameNode = { () -> ASTextNode in
        let node = ASTextNode()
        node.maximumNumberOfLines = 1
        node.placeholderColor = Attribute.placeHolderColor
        return node
    }()
    
    lazy var descriptionNode = { () -> ASTextNode in
        let node = ASTextNode()
        node.placeholderColor = Attribute.placeHolderColor
        return node
    }()
    
    lazy var statusNode = { () -> ASTextNode in
        let node = ASTextNode()
        node.placeholderColor = Attribute.placeHolderColor
        return node
    }()
    
    init(viewModel: RepositoryViewModel) {
        super.init(node: ASDisplayNode())
        self.viewModel = viewModel
        
        node.backgroundColor = .white
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { (_, _) -> ASLayoutSpec in
            
            self.userProfileNode.style.spacingAfter = 10.0
            self.usernameNode.style.spacingAfter = 30.0
            self.descriptionNode.style.spacingAfter = 10.0
            
            let profileStackLayout = ASStackLayoutSpec(direction: .vertical,
                                                       spacing: 0.0,
                                                       justifyContent: .center,
                                                       alignItems: .center,
                                                       children: [
                                                        self.userProfileNode,
                                                        self.usernameNode,
                                                        self.descriptionNode,
                                                        self.statusNode])
            
            return ASInsetLayoutSpec(insets: .init(top: 100.0,
                                                   left: 15.0,
                                                   bottom: .infinity,
                                                   right: 15.0),
                                     child: profileStackLayout)
        }
        
        // bind viewmodel
        
        self.viewModel?.profileURL?.subscribe(onNext: { [weak self] url in
            self?.userProfileNode.setURL(url, resetToDefault: true)
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.username?.subscribe(onNext: { [weak self] username in
            self?.title = username
            self?.usernameNode.attributedText = NSAttributedString(string: username ?? "Unknown",
                                                     attributes: Node.usernameAttributes)
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.desc?.subscribe(onNext: { [weak self] desc in
            guard let `desc` = desc else { return }
            self?.descriptionNode.attributedText = NSAttributedString(string: desc,
                                                     attributes: Node.descAttributes)
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.status?.subscribe(onNext: { [weak self] status in
            guard let `status` = status else { return }
            self?.statusNode.attributedText = NSAttributedString(string: status,
                                                     attributes: Node.statusAttributes)
        }).disposed(by: self.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserProfileViewController {
    static var usernameAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: UIColor.black,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20.0)]
    }
    
    static var descAttributes: [NSAttributedStringKey: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0),
                NSAttributedStringKey.paragraphStyle: paragraphStyle]
    }
    
    static var statusAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: UIColor.gray,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0)]
    }
}
