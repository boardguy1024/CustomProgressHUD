import SwiftUI

public enum AnimationType {
	case systemActivityIndicator
	case circleRotate
}

public extension ProgressHUD {

    // MARK: - Properties
    class var animationType: AnimationType {
        get { shared.animationType }
        set { shared.animationType = newValue }
    }
    
    // MARK: - Methods
    class func dismiss(completion: (() -> Void)? = nil) {
		DispatchQueue.main.async {
            shared.dismissHUD(completion: completion)
		}
	}

	class func remove() {
		DispatchQueue.main.async {
			shared.removeHUD()
		}
	}

	class func show(interaction: Bool = true) {
		DispatchQueue.main.async {
			shared.setup(interaction: interaction)
		}
	}
}

public class ProgressHUD: UIView {
    static let shared: ProgressHUD = {
        let instance = ProgressHUD()
        return instance
    }()

	private var viewBackground: UIView?
	private var toolbarHUD: UIToolbar?
	private var viewAnimation: UIView?

	private var animationType = AnimationType.systemActivityIndicator

	private let keyboardWillShow = UIResponder.keyboardWillShowNotification
	private let keyboardWillHide = UIResponder.keyboardWillHideNotification
	private let keyboardDidShow	= UIResponder.keyboardDidShowNotification
	private let keyboardDidHide	= UIResponder.keyboardDidHideNotification
	private let orientationDidChange = UIDevice.orientationDidChangeNotification

    private let toolbarHUDWidth: CGFloat = 120
    private let toolbarHUDHeight: CGFloat = 120
    
	convenience private init() {
		self.init(frame: UIScreen.main.bounds)
		self.alpha = 0
	}

	required internal init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override private init(frame: CGRect) {
		super.init(frame: frame)
	}

	private func setup(interaction: Bool) {
		setupNotifications()
		setupBackground(interaction)
		setupToolbar()
        setupAnimation()
		setupSize()
		setupPosition()
		displayHUD()
	}

	private func setupNotifications() {
		if (viewBackground == nil) {
			NotificationCenter.default.addObserver(self, selector: #selector(setupPosition(_:)), name: keyboardWillShow, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(setupPosition(_:)), name: keyboardWillHide, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(setupPosition(_:)), name: keyboardDidShow, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(setupPosition(_:)), name: keyboardDidHide, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(setupPosition(_:)), name: orientationDidChange, object: nil)
		}
	}

	private func setupBackground(_ interaction: Bool) {
		if (viewBackground == nil) {
			let mainWindow = UIApplication.shared.windows.first ?? UIWindow()
			viewBackground = UIView(frame: self.bounds)
			mainWindow.addSubview(viewBackground!)
		}

		viewBackground?.backgroundColor = interaction ? .clear : UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
		viewBackground?.isUserInteractionEnabled = (interaction == false)
	}

	private func setupToolbar() {

		if (toolbarHUD == nil) {
			toolbarHUD = UIToolbar(frame: CGRect.zero)
			toolbarHUD?.isTranslucent = true
			toolbarHUD?.clipsToBounds = true
			toolbarHUD?.layer.cornerRadius = 10
			toolbarHUD?.layer.masksToBounds = true
			viewBackground?.addSubview(toolbarHUD!)
		}

		toolbarHUD?.backgroundColor = .systemGray
	}

	private func setupAnimation() {

		if (viewAnimation == nil) {
            switch animationType {
            case .systemActivityIndicator:
                viewAnimation = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            case .circleRotate:
                viewAnimation = UIView(frame: CGRect(x: 0, y: 0, width: toolbarHUDWidth, height: toolbarHUDHeight))
            }
		}

		if (viewAnimation?.superview == nil) {
			toolbarHUD?.addSubview(viewAnimation!)
		}

		viewAnimation?.subviews.forEach {
			$0.removeFromSuperview()
		}

		viewAnimation?.layer.sublayers?.forEach {
			$0.removeFromSuperlayer()
		}

        switch animationType {
        case .systemActivityIndicator:
            animationSystemActivityIndicator(viewAnimation!)
        case .circleRotate:
            animationCircleRotateIndicator(viewAnimation!)
        }
	}

	private func setupSize() {

		toolbarHUD?.bounds = CGRect(x: 0, y: 0, width: toolbarHUDWidth, height: toolbarHUDHeight)

		let centerX = toolbarHUDWidth / 2
		let centerY = toolbarHUDHeight / 2

		viewAnimation?.center = CGPoint(x: centerX, y: centerY)
	}

	@objc private func setupPosition(_ notification: Notification? = nil) {

		var heightKeyboard: CGFloat = 0

		if let notification = notification {
			let frameKeyboard = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero

			if (notification.name == keyboardWillShow) || (notification.name == keyboardDidShow) {
				heightKeyboard = frameKeyboard.size.height
			} else if (notification.name == keyboardWillHide) || (notification.name == keyboardDidHide) {
				heightKeyboard = 0
			} else {
				heightKeyboard = keyboardHeight()
			}
		} else {
			heightKeyboard = keyboardHeight()
		}

		let mainWindow = UIApplication.shared.windows.first ?? UIWindow()
		let screen = mainWindow.bounds
        
        // animationを表示するベースである、toolBarの位置を画面の中央に設定、 keyboardが表示されているのであれば、その分上に表示される
		let center = CGPoint(x: screen.size.width / 2, y: (screen.size.height - heightKeyboard) / 2)
        
        // 画面中央にポジショニング
        self.toolbarHUD?.center = center
        self.viewBackground?.frame = screen

	}

	private func keyboardHeight() -> CGFloat {

		if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"),
			let inputSetContainerView = NSClassFromString("UIInputSetContainerView"),
			let inputSetHostView = NSClassFromString("UIInputSetHostView") {

			for window in UIApplication.shared.windows {
				if window.isKind(of: keyboardWindowClass) {
					for firstSubView in window.subviews {
						if firstSubView.isKind(of: inputSetContainerView) {
							for secondSubView in firstSubView.subviews {
								if secondSubView.isKind(of: inputSetHostView) {
									return secondSubView.frame.size.height
								}
							}
						}
					}
				}
			}
		}
		return 0
	}

	private func displayHUD() {

		if (self.alpha == 0) {
			self.alpha = 1
			toolbarHUD?.alpha = 0
			toolbarHUD?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)

			UIView.animate(withDuration: 0.13, delay: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {
				self.toolbarHUD?.transform = CGAffineTransform(scaleX: 1/1.4, y: 1/1.4)
				self.toolbarHUD?.alpha = 1
			}, completion: nil)
		}
	}

    private func dismissHUD(completion: (() -> Void)? = nil) {

		if (self.alpha == 1) {
			UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {
				self.toolbarHUD?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
				self.toolbarHUD?.alpha = 0
			}, completion: { isFinished in
				self.destroyHUD()
				self.alpha = 0
                completion?()
			})
		}
	}

	private func removeHUD() {

		if (self.alpha == 1) {
			toolbarHUD?.alpha = 0
			destroyHUD()
			self.alpha = 0
		}
	}

	private func destroyHUD() {

		NotificationCenter.default.removeObserver(self)
		viewAnimation?.removeFromSuperview()
        viewAnimation = nil
        
		toolbarHUD?.removeFromSuperview()
        toolbarHUD = nil
        
		viewBackground?.removeFromSuperview()
        viewBackground = nil
	}

	// MARK: - Animation
	private func animationSystemActivityIndicator(_ view: UIView) {

		let spinner = UIActivityIndicatorView(style: .medium)
		spinner.frame = view.bounds
		spinner.color = UIColor.lightGray
		spinner.hidesWhenStopped = true
		spinner.startAnimating()
		spinner.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
		view.addSubview(spinner)
	}
	
	private func animationCircleRotateIndicator(_ view: UIView) {

        let rootView = CustomLoadingView()
        let hostingVC = UIHostingController(rootView: rootView)
        view.addSubview(hostingVC.view)
        
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        hostingVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        hostingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}
}


// MARK: - SwiftUI

struct CustomLoadingView: View {
  
    @State var animate: Bool = false
    var body: some View {
        
        VStack(spacing: 28) {
            
            GeometryReader { proxy in
                Circle()
                    .stroke(AngularGradient(gradient: .init(colors: [Color.primary.opacity(0), Color.black]), center: .center), lineWidth: 2)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .rotationEffect(.init(degrees: animate ? 360 : 0))
            }
        }
        .background(Color.clear)
        .padding(20)
        .onAppear {
            withAnimation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                // 設定した durationの間隔で  Circle.rotationEffect( 360 -> 0 -> 360 -> 0 ... のように toggleで Circleが回るアニメーションになる
                self.animate.toggle()
            }
        }
    }
}
