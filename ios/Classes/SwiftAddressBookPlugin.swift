import Flutter
import UIKit
import Contacts
import ContactsUI

public class SwiftAddressBookPlugin: NSObject, FlutterPlugin, CNContactViewControllerDelegate, CNContactPickerDelegate {

  private var pendingResult: FlutterResult? = nil
  private var localizedLabels: Bool = true

  static let FORM_OPERATION_CANCELED:Int = 1

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.gsshop.mobile.flutter.address_book", binaryMessenger: registrar.messenger())
    let instance = SwiftAddressBookPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  // UIScene 대응: register 시점 캡처 제거, 호출 시점에 keyWindow에서 lazy 획득
  private var currentRootViewController: UIViewController? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })?.rootViewController
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "openAddressBook":
        self.pendingResult = result

        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        DispatchQueue.main.async {
          guard let vc = self.currentRootViewController else {
            result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "rootViewController not available", details: nil))
            return
          }
          vc.present(contactPicker, animated: true, completion: nil)
        }
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    if let result = self.pendingResult {
      result(contactToDictionary(contact: contact, localizedLabels: localizedLabels))
      self.pendingResult = nil
    }
  }

  public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    if let result = self.pendingResult {
      result(nil)
      self.pendingResult = nil
    }
  }
  
  func contactToDictionary(contact: CNContact, localizedLabels: Bool) -> [String:Any]{
    var result = [String:Any]()

    // name
    let famliyName  = contact.familyName;
    let givenName = contact.givenName;

    result["name"] = famliyName + givenName
    result["familyName"] = contact.familyName ?? ""
    result["givenName"] = contact.givenName ?? ""
    result["middleName"] = contact.middleName ?? ""

    // phoneNumber
    var phoneNumber = ""
    if (contact.phoneNumbers.count > 0) {
      phoneNumber = contact.phoneNumbers[0].value.stringValue
    }

    result["phoneNumber"] = phoneNumber
    return result
  }
}