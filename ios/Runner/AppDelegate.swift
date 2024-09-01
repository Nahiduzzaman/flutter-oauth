import UIKit
import Flutter
import GoogleSignIn

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "41888637828-35l1d6t3itu753epb6harfl8cjbsa6a8.apps.googleusercontent.com")
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let googleSignInChannel = FlutterMethodChannel(name: "com.sso.oauthapp/google_signin",
                                                   binaryMessenger: controller.binaryMessenger)
    googleSignInChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "signIn" {
        self?.signIn(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func signIn(result: @escaping FlutterResult) {
    guard let rootViewController = self.window?.rootViewController else {
      result(FlutterError(code: "ERROR",
                          message: "RootViewController is not available.",
                          details: nil))
      return
    }

    GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
      guard error == nil else {
        result(FlutterError(code: "ERROR",
                            message: error?.localizedDescription,
                            details: nil))
        return
      }
      
      guard let signInResult = signInResult else {
        result(FlutterError(code: "ERROR",
                            message: "Sign-in result is nil",
                            details: nil))
        return
      }
      
      let user = signInResult.user
      let userId = user.userID
      let userEmail = user.profile?.email
      let userName = user.profile?.name
      
      let userData: [String: Any] = [
        "id": userId ?? "",
        "email": userEmail ?? "",
        "displayName": userName ?? ""
      ]
      
      do {
        let jsonData = try JSONSerialization.data(withJSONObject: userData, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)
        result(jsonString)
      } catch {
        result(FlutterError(code: "ERROR",
                            message: "Failed to serialize user data",
                            details: nil))
      }
    }
  }
}


// import Flutter
// import UIKit

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }