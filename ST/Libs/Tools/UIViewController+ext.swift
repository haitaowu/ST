
import UIKit
extension UIViewController{
    
    @objc func axViewDidLoad(){
        self.axViewDidLoad()
    }
    class func hook(){
        let originViewDidLoadMethod = class_getInstanceMethod(self, #selector(viewDidLoad))
        let newViewDidLoadMethod = class_getInstanceMethod(self, #selector(axViewDidLoad))
        method_exchangeImplementations(originViewDidLoadMethod!, newViewDidLoadMethod!)
    }
}
