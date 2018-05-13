# RxMVVM-Texture best practice 

## RxSwift MVVM pattern best practice built on Texture(AsyncDisplayKit) and written in Swift


![alt text](https://github.com/GeekTree0101/RxMVVM-Texture/blob/master/resource/resource1.png)

### [ Model ]

```swift
class Repository: Decodable {
    var id: Int
    var user: User?
    var repositoryName: String?
    var desc: String?
    var isPrivate: Bool = false
    var isForked: Bool = false

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case user = "owner"
        case repositoryName = "full_name"
        case desc = "description"
        case isPrivate = "private"
        case isForked = "fork"
    }

    func merge(_ repo: Repository?) {
        guard let repo = repo else { return }
        user?.merge(repo.user)
        repositoryName = repo.repositoryName
        desc = repo.desc
        isPrivate = repo.isPrivate
        isForked = repo.isForked
    }
```

### [ ViewModel ]

```swift
class RepositoryViewModel {

    // @INPUT
    let didTapUserProfile = PublishRelay<Void>()
    let updateRepository = PublishRelay<Repository>()
    let updateUsername = PublishRelay<String?>()
    let updateDescription = PublishRelay<String?>()
    
    // @OUTPUT
    var openUserProfile: Observable<Void>
    var username: Driver<String?>
    var profileURL: Driver<URL?>
    var desc: Driver<String?>
    var status: Driver<String?>
    
    let id: Int
    
    private let disposeBag = DisposeBag()
    
    deinit {
        // release Model from DataProvider
        RepoProvider.release(id: id)
    }
    
    init(repository: Repository) {
        self.id = repository.id
        
        // retain Model to DataProvider
        RepoProvider.addAndUpdate(repository)
        
        // load Model Observer from ModelProvider
        let repoObserver = RepoProvider.observable(id: id)
            .asObservable()
            .share(replay: 1, scope: .whileConnected)
        
        self.username = repoObserver
            .map { $0?.user?.username }
            .asDriver(onErrorJustReturn: nil)
        
        self.profileURL = repoObserver
            .map { $0?.user?.profileURL }
            .asDriver(onErrorJustReturn: nil)
        
        self.desc = repoObserver
            .map { $0?.desc }
            .asDriver(onErrorJustReturn: nil)
```

### [ View ]

```swift
class RepositoryListCellNode: ASCellNode {

    init(viewModel: RepositoryViewModel) {

        ... 

        // ViewModel Binding

        userProfileNode.rx
            .tap(to: viewModel.didTapUserProfile)
            .disposed(by: disposeBag)
        
        viewModel.profileURL.asObservable()
            .bind(to: userProfileNode.rx.url)
            .disposed(by: disposeBag)
        
        viewModel.username.asObservable()
            .bind(to: usernameNode.rx.text(Node.usernameAttributes),
                  setNeedsLayout: self)
            .disposed(by: disposeBag)
        
        viewModel.desc.asObservable()
            .bind(to: descriptionNode.rx.text(Node.descAttributes),
                  setNeedsLayout: self)
            .disposed(by: disposeBag)
        
        viewModel.status.asObservable()
            .bind(to: statusNode.rx.text(Node.statusAttributes),
                  setNeedsLayout: self)
            .disposed(by: disposeBag)
    }
    
```

![alt text](https://github.com/GeekTree0101/RxMVVM-Texture/blob/master/resource/resource2.png)

### Open Profile

```swift
class RepositoryListCellNode: ASCellNode {

    ...

    init(viewModel: RepositoryViewModel) {

        ... 

        // HERE!
        userProfileNode.rx
            .tap(to: viewModel.didTapUserProfile)
            .disposed(by: disposeBag)
    }
    
```

```swift
class RepositoryViewModel {
    // @INPUT
    let didTapUserProfile = PublishRelay<Void>()
    
    // @OUTPUT
    var openUserProfile: Observable<Void>

    ... 

    init(repository: Repository) {

        ... 

        // HERE!
        self.openUserProfile = self.didTapUserProfile.asObservable()   
    }

}

```

```swift

class RepositoryViewController: ASViewController<ASTableNode> {

    ...

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) 
    -> ASCellNodeBlock {
        return {
            guard self.items.count > indexPath.row else { return ASCellNode() }
            let viewModel = self.items[indexPath.row]
            let cellNode = RepositoryListCellNode(viewModel: viewModel)
            
            // HERE!
            viewModel.openUserProfile
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] _ in
                    self?.openUserProfile(indexPath: indexPath)
                }).disposed(by: self.disposeBag)
            
            return cellNode
        }
    }

}

```

![alt text](https://github.com/GeekTree0101/RxMVVM-Texture/blob/master/resource/resource3.png)


### Update description
```swift 

class UserProfileViewController: ASViewController<ASDisplayNode> {
    
    ...


    init(viewModel: ...) {
        
        ... 


        // HERE!
        self.descriptionNode.textView.rx.text
            .bind(to: self.viewModel.updateDescription,
                  setNeedsLayout: self.node)
            .disposed(by: self.disposeBag)
    }
}

```

```swift

class RepositoryViewModel {

    // @INPUT
    let updateDescription = PublishRelay<String?>()
    
    // @OUTPUT
    var desc: Driver<String?>
    
    init( ... ) {

        ...

        let repoObserver = RepoProvider.observable(id: id)
            .asObservable()
            .share(replay: 1, scope: .whileConnected)

        self.desc = repoObserver
            .map { $0?.desc }
            .asDriver(onErrorJustReturn: nil)

        updateDescription.withLatestFrom(repoObserver) { ($0, $1) }
            .subscribe(onNext: { text, repo in
                guard let repo = repo else { return }
                repo.desc = text
                RepoProvider.update(repo)
            }).disposed(by: disposeBag)
    }
}
```

![alt text](https://github.com/GeekTree0101/RxMVVM-Texture/blob/master/resource/resource4.png)

### Example Video
[Example Video Link](https://youtu.be/qFu2hJG-OyE)