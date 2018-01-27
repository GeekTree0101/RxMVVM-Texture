import Foundation
import RxSwift

class RxModel: NSObject, Decodable { }

extension PrimitiveSequence where Element == Data {
    // .generateArrayModel(type: MODEL_CLASS_NAME.self).subscribe ... TODO
    func generateArrayModel<T: RxModel>(type: T.Type) -> Single<[T]> {
        return self.asObservable()
            .flatMap({ type.rx.parseArray(data: $0) })
            .asSingle()
    }
    
    func generateObjectModel<T: RxModel>(type: T.Type) -> Single<T> {
        return self.asObservable()
            .flatMap({ type.rx.parseObject(data: $0) })
            .asSingle()
    }
}

extension Reactive where Base: RxModel {
    static func parseArray(data: Data) -> Single<[Base]> {
        return Observable.create({ operation in
            if let array = try? JSONDecoder().decode([Base].self, from: data) {
                operation.onNext(array)
                operation.onCompleted()
            } else {
                let error = NSError.init(domain: "Failed", code: 0, userInfo: nil)
                operation.onError(error)
            }

            return Disposables.create()
        }).asSingle()
    }
    
    static func parseObject(data: Data) -> Single<Base> {
        return Observable.create({ operation in
            if let array = try? JSONDecoder().decode(Base.self, from: data) {
                operation.onNext(array)
                operation.onCompleted()
            } else {
                let error = NSError.init(domain: "Failed", code: 0, userInfo: nil)
                operation.onError(error)
            }
            
            return Disposables.create()
        }).asSingle()
    }
}
