import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

		window = UIWindow(frame: UIScreen.main.bounds)

		let viewController = ViewController(nibName: "ViewController", bundle: nil)
		let navController = UINavigationController(rootViewController: viewController)

		window?.rootViewController = navController
		window?.makeKeyAndVisible()

		return true
	}
}
