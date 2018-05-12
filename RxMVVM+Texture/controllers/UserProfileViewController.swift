import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa
import GTTexture_RxExtension

class UserProfileViewController: ASViewController<ASDisplayNode> {
    typealias Node = UserProfileViewController
    
    struct Attribute {
        static let placeHolderColor: UIColor = UIColor.gray.withAlphaComponent(0.2)
    }
    
    lazy var userProfileNode = { () -> ASNetworkImageNode in
        let node = ASNetworkImageNode()
        node.style.preferredSize = CGSize(width: 100.0, height: 100.0)
        node.cornerRadius = 50.0
        node.clipsToBounds = true
        node.placeholderColor = Attribute.placeHolderColor
        node.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        node.borderWidth = 0.5
        return node
    }()
    
    lazy var usernameNode = { () -> ASEditableTextNode in
        let node = ASEditableTextNode()
        node.style.flexGrow = 1.0
        node.attributedPlaceholderText =
            NSAttributedString(string: "Insert description",
                               attributes: Node.usernamePlaceholderAttributes)
        node.typingAttributes =
            Node.convertTypingAttribute(Node.usernameAttributes)
        return node
    }()
    
    lazy var descriptionNode = { () -> ASEditableTextNode in
        let node = ASEditableTextNode()
        node.style.flexGrow = 1.0
        node.attributedPlaceholderText =
            NSAttributedString(string: "Insert description",
                               attributes: Node.descPlaceholderAttributes)
        node.typingAttributes =
            Node.convertTypingAttribute(Node.descAttributes)
        return node
    }()
    
    lazy var statusNode = { () -> ASTextNode in
        let node = ASTextNode()
        node.placeholderColor = Attribute.placeHolderColor
        return node
    }()
    
    let viewModel: RepositoryViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: RepositoryViewModel) {
        self.viewModel = viewModel
        super.init(node: ASDisplayNode())
        
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
        viewModel.profileURL.asObservable()
            .bind(to: userProfileNode.rx.url)
            .disposed(by: disposeBag)
        
        viewModel.username
            .map { NSAttributedString(string: $0 ?? "Unknown",
                                      attributes: Node.usernameAttributes)
            }
            .drive(onNext: { [weak self] text in
                self?.usernameNode.attributedText = text
                self?.node.setNeedsLayout()
            }).disposed(by: disposeBag)

        viewModel.desc
            .map { NSAttributedString(string: $0 ?? "",
                                      attributes: Node.descAttributes)
            }
            .drive(onNext: { [weak self] text in
                self?.descriptionNode.attributedText = text
                self?.node.setNeedsLayout()
            }).disposed(by: disposeBag)
        
        viewModel.status.asObservable()
            .bind(to: statusNode.rx.text(Node.statusAttributes),
                  setNeedsLayout: node)
            .disposed(by: disposeBag)
        
        node.onDidLoad({ [weak self] _ in
            guard let `self` = self else { return }

            self.descriptionNode.textView.rx.text
                .bind(to: self.viewModel.updateDescription,
                      setNeedsLayout: self.node)
                .disposed(by: self.disposeBag)

            self.usernameNode.textView.rx.text
                .bind(to: self.viewModel.updateUsername,
                      setNeedsLayout: self.node)
                .disposed(by: self.disposeBag)
        })
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
    
    static var usernamePlaceholderAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: UIColor.black.withAlphaComponent(0.5),
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20.0)]
    }
    
    static var descPlaceholderAttributes: [NSAttributedStringKey: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [NSAttributedStringKey.foregroundColor: UIColor.darkGray.withAlphaComponent(0.5),
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0),
                NSAttributedStringKey.paragraphStyle: paragraphStyle]
    }
    
    static var statusAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: UIColor.gray,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0)]
    }
    
    static func convertTypingAttribute(_ attributes: [NSAttributedStringKey: Any]) -> [String: Any] {
        var typingAttribute: [String: Any] = [:]
        
        for key in attributes.keys {
            guard let attr = attributes[key] else { continue }
            typingAttribute[key.rawValue] = attr
        }
        
        return typingAttribute
    }
}
