//
//  ViewController.swift
//  BioAuth
//
//  Created by Bear Cahill on 7/8/19.
//  Copyright © 2019 Bear Cahill. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
	var context = LAContext()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		context.localizedCancelTitle = "My Cancel"
		context.localizedFallbackTitle = "Fallback!"
		context.localizedReason = "The app needs your authentication."
		context.touchIDAuthenticationAllowableReuseDuration = LATouchIDAuthenticationMaximumAllowableReuseDuration
		evaluatePolicy()
    }

	func evaluatePolicy() {
		var errorCanEval: NSError?
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &errorCanEval) {
			switch context.biometryType {
			case .touchID:
				print("Touch")
			case .faceID:
				print("Face")
			case .none:
				print("None")
			@unknown default:
				print("Unknown")
			}

			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Fallback title - override reason") { (success, error) in
				print(success)
				if let err = error {
					let evalErrCode = LAError(_nsError: err as NSError)
					switch evalErrCode.code {
					case LAError.Code.userCancel:
						print("user cancelled")
					case LAError.Code.userFallback:
						print("fallback")
						self.promptForCode()
					case LAError.Code.appCancel:
						print("App cancelled")
					case LAError.Code.authenticationFailed:
						print("failed")
					default:
						print("other error")
					}
				}
			}
//			Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { t in
//				self.context.invalidate()
//			}

		} else {
			print("can't evaluate")
			print(errorCanEval?.localizedDescription ?? "no error description")
			if let err = errorCanEval {
				let evalErrCode = LAError(_nsError: err as NSError)
				switch evalErrCode.code {
				case LAError.biometryNotEnrolled:
					print("not enrolled")
				default:
					print("other error")
				}
			}
		}
	}

	func promptForCode() {
		let ac = UIAlertController(title: "Enter Code", message: "Enter your user code", preferredStyle: .alert)
		DispatchQueue.main.async {
			ac.addTextField { tf in
				tf.placeholder = "Enter user code"
				tf.keyboardType = .numberPad
				tf.isSecureTextEntry = true
			}
			ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { aa in
				print(ac.textFields?.first?.text ?? "no value")
			}))
			self.present(ac, animated: true, completion: nil)
		}
	}


}

