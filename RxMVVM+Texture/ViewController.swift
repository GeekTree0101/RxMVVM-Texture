import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        Network.shared.get(url: "https://api.github.com/repositories", params: nil)
          .generateArrayModel(type: Repository.self).subscribe(onSuccess: { list in
        
          }, onError: nil)
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
