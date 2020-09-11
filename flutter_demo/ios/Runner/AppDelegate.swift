import UIKit
import Flutter
var flutterVc: FlutterViewController?
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    test()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func test(){
        
        flutterVc = window.rootViewController as? FlutterViewController
        
        let method = FlutterMethodChannel(name: "test", binaryMessenger: flutterVc!.binaryMessenger)
        method.setMethodCallHandler { (call: FlutterMethodCall , result: FlutterResult) in
            print(call.method)
            print(call.arguments as Any)
//            result("我是swift传过来的值")
            
            let vc1 = MyController.init()
            self.window.rootViewController = vc1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            method.invokeMethod("goback", arguments: ["name":"小王"]) { (result) in
                       print("我是\(String(describing: result))")
        }
        }
        
    }
}
