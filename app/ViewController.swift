
import UIKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ViewController: UITableViewController {

	@IBOutlet var cellText: UITableViewCell!

	private var types: [String] = []
	
	private var timer: Timer?
	private var status: String?

	private let textShort	= "Please wait..."
	private let textLong	= "Please wait. We need some more time to work out this situation."

	private let textSuccess	= "That was awesome!"
	private let textError	= "Something went wrong."

	private let textSucceed	= "That was awesome!"
	private let textFailed	= "Something went wrong."
	private let textAdded	= "Successfully added."

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "ProgressHUD"

		types.append("System Activity Indicator")
		types.append("Horizontal Circles Pulse")
		

	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ViewController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return 2
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 4				}
		if (section == 1) { return types.count    	}
	
		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellText	}

		if (indexPath.section == 0) && (indexPath.row == 1) { return self.tableView(tableView, cellWithText: "Dismiss Keyboard")	}
		if (indexPath.section == 0) && (indexPath.row == 2) { return self.tableView(tableView, cellWithText: "Dismiss HUD")			}
		if (indexPath.section == 0) && (indexPath.row == 3) { return self.tableView(tableView, cellWithText: "Remove HUD")			}

		if (indexPath.section == 1) { return self.tableView(tableView, cellWithText: types[indexPath.row])	}
		
		return UITableViewCell()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellWithText text: String) -> UITableViewCell {

		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .default, reuseIdentifier: "cell") }
		cell.textLabel?.text = text

		return cell
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		if (section == 1) { return "Animation Types"			}
		
		return nil
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ViewController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) && (indexPath.row == 1) { view.endEditing(true) 			}
		if (indexPath.section == 0) && (indexPath.row == 2) { ProgressHUD.dismiss()				}
		if (indexPath.section == 0) && (indexPath.row == 3) { ProgressHUD.remove()				}

		if (indexPath.section == 1)	{
			if (indexPath.row == 0)	 { ProgressHUD.animationType = .systemActivityIndicator		}
            if (indexPath.row == 1)  { ProgressHUD.animationType = .circleRotate             }
			
            
            
            // Animationが5秒間表示されるように
            let isEnabled = false
            
            ProgressHUD.show(interaction: isEnabled)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                ProgressHUD.dismiss()
            }
		}
	}
}
