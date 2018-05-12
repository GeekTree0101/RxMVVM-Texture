import Foundation
import RxSwift
import RxCocoa

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
        RepoProvider.release(id: id)
    }
    
    init(repository: Repository) {
        self.id = repository.id
        
        RepoProvider.addAndUpdate(repository)
        
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
        
        self.status = repoObserver
            .map { item -> String? in
                var statusArray: [String] = []
                if let isForked = item?.isForked, isForked {
                    statusArray.append("Forked")
                }
                
                if let isPrivate = item?.isPrivate, isPrivate {
                    statusArray.append("Private")
                }
                
                return statusArray.isEmpty ? nil: statusArray.joined(separator: " · ")
            }.asDriver(onErrorJustReturn: nil)
        
        self.openUserProfile = self.didTapUserProfile.asObservable()
        
        self.updateRepository.subscribe(onNext: { newRepo in
            RepoProvider.update(newRepo)
        }).disposed(by: disposeBag)
        
        updateUsername.withLatestFrom(repoObserver) { ($0, $1) }
            .subscribe(onNext: { text, repo in
                guard let repo = repo else { return }
                repo.user?.username = text ?? ""
                RepoProvider.update(repo)
            }).disposed(by: disposeBag)
        
        updateDescription.withLatestFrom(repoObserver) { ($0, $1) }
            .subscribe(onNext: { text, repo in
                guard let repo = repo else { return }
                repo.desc = text
                RepoProvider.update(repo)
            }).disposed(by: disposeBag)
    }
}
