# RxMVVM-Texture best practice 

## RxSwift MVVM pattern best practice built on Texture(AsyncDisplayKit) and written in Swift


![alt text](https://github.com/GeekTree0101/RxMVVM-Texture/blob/master/resource/resource1.png)

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
    let updateDescription = PublishSubject<String?>()
    var desc: Observable<String?>?

    init(repository: Repository) {
        self.localRepositoryVariable = Variable<Repository?>(self.repository)
        let repoObserver = self.localRepositoryVariable.asObservable()

        // update description publisher 
        updateDescription.subscribe(onNext: { [weak self] text in
            let repository = self?.localRepositoryVariable.value
            repository?.desc = text
            self?.localRepositoryVariable.value = repository
        }).disposed(by: disposeBag)
        
        // description observer
        self.desc = repoObserver.map { $0?.desc }

        // open user profile
        self.openUserProfile = self.didTapUserProfile.asObservable()
```

### [ View ]

```swift
class RepositoryListCellNode: ASCellNode {

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

                // open user profile
                viewController?.openUserProfile(indexPath: self?.indexPath)
            }).disposed(by: self.disposeBag)
        
        self.viewModel?.desc?.subscribe(onNext: { [weak self] desc in
            guard let `desc` = desc else { return }
            // ...
        }).disposed(by: self.disposeBag)

	…
```

#### Push UserProfileViewController
![alt text](https://github.com/GeekTree0101/RxMVVM-Texture/blob/master/resource/resource2.png)


### [ ViewController ]

```swift
class UserProfileViewController: ASViewController<ASDisplayNode> {


    weak var viewModel: RepositoryViewModel?

    lazy var descriptionNode = { () -> ASEditableTextNode in
        let node = ASEditableTextNode()
        node.style.flexGrow = 1.0

        // ...

        node.onDidLoad({ [weak self] textNode in
            guard let `self` = self,
                let `textNode` = textNode as? ASEditableTextNode else { return }
            textNode.textView.rx.text.subscribe(onNext: { text in

                // update description
                self.viewModel?.updateDescription.onNext(text)
                textNode.setNeedsLayout()
            }).disposed(by: self.disposeBag)
        })
        return node
    }()


    init(viewModel: RepositoryViewModel) {

        // don't need continuous update, cuz, descriptionNode is EditableTextNode
        self.viewModel?.desc?.single().subscribe(onNext: { [weak self] desc in
            guard let `desc` = desc else { return }
            self?.descriptionNode.attributedText = NSAttributedString(string: desc,
                                                     attributes: Node.descAttributes)
        }).disposed(by: self.disposeBag)
    }
```

### Update description
![alt text](https://github.com/GeekTree0101/RxMVVM-Texture/blob/master/resource/resource3.png)

### Example Video
[Example Video Link](https://youtu.be/qFu2hJG-OyE)