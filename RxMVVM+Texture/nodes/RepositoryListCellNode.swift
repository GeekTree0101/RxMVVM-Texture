import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa
import GTTexture_RxExtension

class RepositoryListCellNode: ASCellNode {
    typealias Node = RepositoryListCellNode
    
    struct Attribute {
        static let placeHolderColor: UIColor = UIColor.gray.withAlphaComponent(0.2)
    }
    
    // nodes
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
        node.maximumNumberOfLines = 1
        node.truncationAttributedText = NSAttributedString(string: " ...More",
                                                           attributes: Node.moreSeeAttributes)
        node.delegate = self
        node.isUserInteractionEnabled = true
        return node
    }()
    
    lazy var statusNode = { () -> ASTextNode in
        let node = ASTextNode()
        node.placeholderColor = Attribute.placeHolderColor
        return node
    }()
    
    let disposeBag = DisposeBag()
    
    init(viewModel: RepositoryViewModel) {
        super.init()
        self.selectionStyle = .none
        self.backgroundColor = .white
        self.automaticallyManagesSubnodes = true
        self.neverShowPlaceholders = false
        
        // bind viewmodel
        userProfileNode.rx
            .tap(to: viewModel.didTapUserProfile)
            .disposed(by: disposeBag)
        
        viewModel.profileURL.asObservable()
            .bind(to: userProfileNode.rx.url)
            .disposed(by: disposeBag)
        
        viewModel.username.asObservable()
            .map { NSAttributedString(string: $0 ?? "Unknown",
                                      attributes: Node.usernameAttributes) }
            .bind(to: usernameNode.rx.attributedText,
                  setNeedsLayout: self)
            .disposed(by: disposeBag)
        
        viewModel.desc.asObservable()
            .map { NSAttributedString(string: $0 ?? "",
                                      attributes: Node.descAttributes) }
            .bind(to: descriptionNode.rx.attributedText,
                  setNeedsLayout: self)
            .disposed(by: disposeBag)
        
        viewModel.status.asObservable()
            .map { NSAttributedString(string: $0 ?? "",
                                      attributes: Node.statusAttributes)
            }.bind(to: statusNode.rx.attributedText,
                   setNeedsLayout: self)
            .disposed(by: disposeBag)
    }
}

extension RepositoryListCellNode: ASTextNodeDelegate {
    func textNodeTappedTruncationToken(_ textNode: ASTextNode) {
        textNode.maximumNumberOfLines = 0
        textNode.setNeedsLayout()
    }
}

extension RepositoryListCellNode {
    // layout spec
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let contentLayout = contentLayoutSpec()
        contentLayout.style.flexShrink = 1.0 // block text overflow on screen
        
        let stackLayout = ASStackLayoutSpec(direction: .horizontal,
                                            spacing: 10.0,
                                            justifyContent: .start,
                                            alignItems: .center,
                                            children: [userProfileNode,
                                                       contentLayout])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10.0,
                                                      left: 10.0,
                                                      bottom: 10.0,
                                                      right: 10.0),
                                 child: stackLayout)
    }
    
    private func contentLayoutSpec() -> ASLayoutSpec {
        let elements = [self.usernameNode,
                        self.descriptionNode,
                        self.statusNode].filter { $0.attributedText?.length ?? 0 > 0 }
        
        return ASStackLayoutSpec(direction: .vertical,
                                 spacing: 5.0,
                                 justifyContent: .spaceAround,
                                 alignItems: .stretch,
                                 children: elements)
    }
}

extension RepositoryListCellNode {
    static var usernameAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: UIColor.black,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20.0)]
    }
    
    static var descAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0)]
    }

    static var statusAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: UIColor.gray,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0)]
    }
    
    static var moreSeeAttributes: [NSAttributedStringKey: Any] {
        return [NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0, weight: .medium)]
    }
}
