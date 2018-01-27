import Foundation
import RxSwift
import RxCocoa

class RepositoryViewModel {
    
    // input
    let didTapUserProfile = PublishSubject<Void>()
    let updateRepository = PublishSubject<Repository>()
    
    // output
    var openUserProfile: Observable<Void>?
    
    var username: Observable<String?>?
    var profileURL: Observable<URL?>?
    var desc: Observable<String?>?
    var status: Observable<String?>?
    
    let id: Int
    private let disposeBag = DisposeBag()
    private let localRepositoryVariable: Variable<Repository?>
    weak var repository: Repository?
    
    init(repository: Repository) {
        self.repository = repository
        self.id = self.repository?.id ?? -1
        self.localRepositoryVariable = Variable<Repository?>(self.repository)
        
        let repoObserver = self.localRepositoryVariable.asObservable()
        
        self.username = repoObserver.map { $0?.user?.username }
        self.profileURL = repoObserver.map { $0?.user?.profileImageAbsoluteURL }
            .map { [weak self] path -> URL? in
                guard self != nil else { return nil }
                guard let `path` = path else {
                    return nil
                }
                return URL(string: path)
        }
        
        self.desc = repoObserver.map { $0?.desc }
  
        self.status = repoObserver.map { [weak self] item -> String? in
            guard self != nil else { return nil }
            var statusArray: [String] = []
            if let isForked = item?.isForked, isForked {
                statusArray.append("Forked")
            }
            
            if let isPrivate = item?.isPrivate, isPrivate {
                statusArray.append("Private")
            }
            
            return statusArray.isEmpty ? nil: statusArray.joined(separator: " · ")
        }
        
        self.updateRepository.subscribe(onNext: { [weak self] newRepo in
            self?.localRepositoryVariable.value = newRepo
        }).disposed(by: disposeBag)
        
        self.openUserProfile = self.didTapUserProfile.asObservable()
    }
}
