import Flutter
import UIKit
import Contacts
import ContactsUI

public class SwiftAddressBookPlugin: NSObject, FlutterPlugin, CNContactViewControllerDelegate, CNContactPickerDelegate {

  private var pendingResult: FlutterResult? = nil
  private let rootViewController: UIViewController
  private var localizedLabels: Bool = true

  static let FORM_OPERATION_CANCELED:Int = 1

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.gsshop.mobile.flutter.address_book", binaryMessenger: registrar.messenger())
    let rootViewController = UIApplication.shared.delegate!.window!!.rootViewController!;

    let instance = SwiftAddressBookPlugin(rootViewController)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  init(_ rootViewController: UIViewController) {
    self.rootViewController = rootViewController
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "openAddressBook":
        //var dic4 : Dictionary<String, String> = ["name":"zedd", "phoneNumber":"phoneNumber"]

        self.pendingResult = result

        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        //contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        DispatchQueue.main.async {
          self.rootViewController.present(contactPicker, animated: true, completion: nil)
        }
        //result(dic4)
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

    result["name"] = famliyName + " " + givenName
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