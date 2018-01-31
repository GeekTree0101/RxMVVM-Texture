# RxMVVM-Texture best practice 

## RxSwift MVVM pattern best practice built on Texture(AsyncDisplayKit) and written in Swift

### [ Model ]

// RxModel is convenience protocol for JSON parsing
```swift
class Repository: RxModel {
    var id: Int
    var user: User?
    var repositoryName: String?
    var desc: String?
    var isPrivate: Bool = false
    var isForked: Bool = false
```

### [ ViewModel ]

```swift
class RepositoryViewModel {

    // input
    let didTapUserProfile = PublishSubject<Void>()

    // output
    var openUserProfile: Observable<Void>?
    var username: Observable<String?>?

    init(repository: Repository) {

	self.username = repoObserver.map { $0?.user?.username }
        self.openUserProfile = self.didTapUserProfile.asObservable()
```

### [ View ]

```swift
class RepositoryListCellNode: ASCellNode {

    lazy var usernameNode = { () -> ASTextNode in
        let node = ASTextNode()
        node.maximumNumberOfLines = 1
        node.placeholderColor = Attribute.placeHolderColor
        return node
    }()

    weak var viewModel: RepositoryViewModel?

    Init(viewModel: RepositoryViewModel) {
	self.bindViewModel()
    }
    
    func bindViewModel() { … } 
```

``` swift
func bindViewModel() {

        self.viewModel?.openUserProfile?
            .subscribe(onNext: { [weak self] _ in
                let viewController = self?.closestViewController as? RepositoryViewController
                viewController?.openUserProfile(indexPath: self?.indexPath)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.username?.subscribe(onNext: { [weak self] username in
            self?.usernameNode.attributedText = NSAttributedString(string: username ?? "Unknown",
                                                                   attributes: Node.usernameAttributes)
        }).disposed(by: self.disposeBag)

	…
```

### [ ViewController ]

```swift
class RepositoryViewController: ASViewController<ASTableNode> {

    …

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            guard self.items.count > indexPath.row else { return ASCellNode() }
            return RepositoryListCellNode(viewModel: self.items[indexPath.row])
        }
    }

    …

    func openUserProfile(indexPath: IndexPath?) {
        guard let `indexPath` = indexPath, items.count > indexPath.row else { return }
        let viewModel = self.items[indexPath.row]
        let viewController = UserProfileViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
```
