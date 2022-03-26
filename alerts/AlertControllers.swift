//
//  AlertControllers.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//


import Foundation
import UIKit
import RxSwift
import Photos

/*
public protocol TitledItem {
    var title : String { get }
    
    var icon : Icon? { get }
}

public class AlertControllers {

    public enum EditDeleteActions {

        case edit
        case delete
        case cancel
    }

    public enum PrintSize : Int {
        case full = 0
        case half = 1
        
        public static var all : [PrintSize] = [.full, .half]
        
        public static func from(int: Int) -> PrintSize? {
            return PrintSize.all.first(where: { $0.rawValue == int })
        }
    }
    
    public enum FontSize : Int {
        case small  = 0
        case medium = 1
        case large  = 2
        
        public static var selected : FontSize = .medium
        
        public static var all : [FontSize] = [.small, .medium, .large]
        
        public static func from(int: Int) -> FontSize? {
            return FontSize.all.first(where: {$0.rawValue == int})
        }
        
        public var setting : CGFloat {
            switch(self){
            case .small :
                return 10
            case .medium:
                return 14
            case .large:
                return 16
            }
        }
        
        public var lineSpacing : CGFloat {
            switch self {
            case .small:
                return 3
            case .medium:
                return 5
            case .large:
                return 10
            }
        }
        
        public var minimumLineHeight : CGFloat {
            switch self {
            case .small:
                return 8
            case .medium:
                return 10
            case .large:
                return 12
            }
        }
        
        public var footerLineSpacing : CGFloat {
            switch self {
            case .small:
                return 1
            case .medium:
                return 3
            case .large:
                return 5
            }
        }
    }

    /**
     Creates an alert message.
     - Parameter at: The view controller that will present this alert.
     - Parameter title: The title of the alert message.
     - Parameter body: The content body or the message describing the alert.
     - Parameter defaultActions: An array that specifies the choices for the alerts. By not specifying this array, the default action is `Okay`.
     - Returns: An observable operation that emits the choice of the user as a String.
     */
    
    public static func  create                  (at: UIViewController, title: String, body: String? = nil, defaultActions: [String]? = []) -> Observable<String> {
        
        return .create { obx in
            
            let body = body ?? "" // "I need a proper message. (AlertControllers.create)"
            
            let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertController.Style.alert)
            
            var actions = defaultActions ?? []
            
            if actions.count == 0 {
                actions.append("Okay")
            }
            
            let choices = actions.map { (option: String) -> UIAlertAction in
                return UIAlertAction(title: option, style: .default, handler: { (action: UIAlertAction) in
                    obx.onNext(option)
                    obx.onCompleted()
                })
            }
            
            choices.forEach(alert.addAction)
            
            //IS THIS A PROPER SOLUTION -- thread issue on opening view
            DispatchQueue.main.async {
                at.present(alert, animated: true, completion: nil)
            }
            
            return Disposables.create()
        }
    }
    
    public static func showLoading (at: UIViewController, title: String? = nil ) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: title ?? "Loading...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        
        at.present(alert, animated: true, completion: nil)
        
        return alert
    }
    
    /**
        alert panel with delay
     */
    public static func  createDelay (at: UIViewController,
                                     title: String,
                                     body: String? = nil,
                                     defaultActions: [String]? = [],
                                     delay: DispatchTime = .now() + 0) -> Observable<String> {
        
        return .create { obx in
            
            let body = body ?? "" // "I need a proper message. (AlertControllers.create)"
            
            let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertController.Style.alert)
            
            var actions = defaultActions ?? []
            
            if actions.count == 0 {
                actions.append("Okay")
            }
            
            let choices = actions.map { (option: String) -> UIAlertAction in
                return UIAlertAction(title: option, style: .default, handler: { (action: UIAlertAction) in
                    obx.onNext(option)
                    obx.onCompleted()
                })
            }
            
            choices.forEach(alert.addAction)
            
            //IS THIS A PROPER SOLUTION -- thread issue on opening view
            DispatchQueue.main.asyncAfter(deadline: delay) {
                at.present(alert, animated: true, completion: nil)
            }
            
            return Disposables.create()
        }
    }

    public static func  missingDataAlert        (at: UIViewController, title: String) -> Observable<UIAlertAction> {

        return .create { obx in

            let alert = UIAlertController(title: title, message: "I need a proper message. (AlertControllers.missingDataAlert)", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {

                obx.onNext      ($0)
                obx.onCompleted ()
            }))

            at.present(alert, animated: true, completion: nil)

            return Disposables.create()
        }
    }
    
    
    
    public static func  invalidDataAlert        (at: UIViewController, title: String, body: String) -> Observable<UIAlertAction> {
        
        return .create { obx in
            
            let alert = UIAlertController(title: title, message: body.isEmpty ? "I need a proper message. (AlertControllers.invalidDataAlert)" : body, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {
                
                obx.onNext      ($0)
                obx.onCompleted ()
            }))
            
            at.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }

    public static func  invalidDataAlert        (at: UIViewController, title: String, body: String?, error: Error) -> Observable<UIAlertAction> {
        
        return .create { obx in
            
            var errorMessage : String = ""
            var titleMessage : String = title
            if let error = error as? DisplayableError {
                titleMessage = error.title
                errorMessage = error.description
            } else {
                errorMessage = body ?? "Operation failed"
            }
            
            let alert = UIAlertController(title: titleMessage, message: errorMessage, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {
                
                obx.onNext      ($0)
                obx.onCompleted ()
            }))
            
            DispatchQueue.main.async {
                at.present(alert, animated: true, completion: nil)
            }
            
            return Disposables.create()
        }
    }

    /**
     Helper function for confirming if something will be deleted.
     
     It has two options in the alert: "Yes" which is colored red or `destructive` and "No" which
     is a default-colored alert button.
     */
    
    public static func  deleteDataAlert         (at: UIViewController, title: String, body: String? = nil, deleteText: String = "Delete") -> Observable<Bool> {

        return .create { obx in

            let alert = UIAlertController(title: title, message: body ?? "I need a proper message. (AlertControllers.deleteDataAlert)", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: deleteText, style: .destructive, handler: { _ in

                obx.onNext      (true)
                obx.onCompleted ()
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in

                obx.onNext      (false)
                obx.onCompleted ()
            }))

            at.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }

    /**
     Helper function  for confirming if something will be saved.
     
     It has three options in the alert: "Save changes" which is default-colored,
     "Keep editing" which is default-colored, and "Discard changes" which is colored red,
     or `destructive`.
     */
    
    public static func  saveDataAlert           (at: UIViewController, title: String, body: String? = nil) -> Observable<Bool> {

        return .create { obx in

            let alert = UIAlertController(title: title, message: body ?? "I need a proper message. (AlertControllers.saveDataAlert)", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Save changes", style: .default, handler: { _ in
                
                obx.onNext      (true)
                obx.onCompleted ()
            }))
            
            alert.addAction(UIAlertAction(title: "Keep editing", style: .default, handler: { _ in
                
                obx.onCompleted ()
            }))

            alert.addAction(UIAlertAction(title: "Discard changes", style: .destructive, handler: { _ in

                obx.onNext      (false)
                obx.onCompleted ()
            }))

            at.present(alert, animated: true, completion: nil)

            return Disposables.create()
        }
    }
    
    /**
     Helper function  for confirming if something will continue.
     
     It has two options in the alert: "Continue" which is default-colored,
     and "Cancel" which is colored red,
     or `destructive`.
     */
    
    public static func  confirmDataAlert           (at: UIViewController, title: String, body: String? = nil) -> Observable<Bool> {

        return .create { obx in

            let alert = UIAlertController(title: title, message: body ?? "I need a proper message. (AlertControllers.saveDataAlert)", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
                obx.onNext      (true)
                obx.onCompleted ()
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
                obx.onNext      (false)
                obx.onCompleted ()
            }))

            at.present(alert, animated: true, completion: nil)

            return Disposables.create()
        }
    }
    
    /**
     Helper function  for displaying option if the message failed
     
     It has three options in the alert: "Resend" which is default-colored,
     "Cancel" which is default-colored, and "Delete" which is colored red,
     or `destructive`.
     */
    public static func  failedMessageAlert           (at: UIViewController, title: String, body: String? = nil) -> Observable<Bool> {
        return .create { obx in
            let alert = UIAlertController(title: title, message: body ?? "I need a proper message. (AlertControllers.saveDataAlert)", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Resend", style: .default, handler: { _ in
                obx.onNext      (true)
                obx.onCompleted ()
            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                obx.onNext      (false)
                obx.onCompleted ()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
                obx.onCompleted ()
            }))
            
            DispatchQueue.main.async {
                at.present(alert, animated: true, completion: nil)
            }
            
            return Disposables.create()
        }
    }
    
    /**
     Helper function for confirming if something will be detached.

     It has two options in the alert: "Yes" which is colored red or `destructive` and "No" which
     is a default-colored alert button.
     */
    public static func  detachDataAlert         (at: UIViewController, title: String, body: String? = nil) -> Observable<Bool> {

        return .create { obx in

            let alert = UIAlertController(title: title, message: body ?? "I need a proper message. (AlertControllers.detachDataAlert)", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Detach", style: .destructive, handler: { _ in

                obx.onNext      (true)
                obx.onCompleted ()
            }))

            alert.addAction(UIAlertAction(title: "Cancel",  style: .default, handler: { _ in

                obx.onNext      (false)
                obx.onCompleted ()
            }))

            at.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    /**
    Helper function for confirming if something will be cancelled.

    It has two options in the alert: "Yes" which is colored red or `destructive` and "No" which
    is a default-colored alert button.
    */
    public static func promptCancelAlert        (at: UIViewController, title: String, body: String? = nil) -> Observable<Bool> {
        return .create { obx in

            let alert = UIAlertController(title: title, message: body ?? "I need a proper message. (AlertControllers.detachDataAlert)", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: { _ in
                obx.onNext      (true)
                obx.onCompleted ()
            }))

            alert.addAction(UIAlertAction(title: "Cancel",  style: .default, handler: { _ in
                obx.onCompleted ()
            }))

            at.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }


    public static func  promptSaveComplete      (at: UIViewController, pegged: UIView) -> Observable<Void> {

        return Observable<Void>.create({ [unowned at] obx in

                let alert = UIAlertController(title: "Changes Saved", message: nil, preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { _ in

                    obx.onNext      (())
                    obx.onCompleted ()
                }))

                alert.present(asAileron: alert, peg: pegged)

                at.present(alert, animated: true, completion: nil)

                return Disposables.create()
            })
    }


    public static func  editDeleteActionSheet   (at: UIViewController, pegged: UIView, title: String? = nil, body: String? = nil) -> Observable<EditDeleteActions> {

        return .create { obx in

            let slat                = SULSlat()

                slat.isCancellable  = true

                slat.items          = [

                    SULSlatItem(name: "Edit",   icon: ModuleResources.Icon.actionEdit.rawValue, destructive: false, action: {

                        obx.onNext      (.edit)
                        obx.onCompleted ()
                    }),
                    SULSlatItem(name: "Delete", icon: ModuleResources.Icon.actionDelete.rawValue, destructive: true, action: {

                        obx.onNext      (.delete)
                        obx.onCompleted ()
                    })
                ]

                slat.cancelled  = {

                    obx.onCompleted()
                }

            at.present(asAileron: slat, peg: pegged)

            return Disposables.create()
        }
    }


    /**
     Opens a media action sheet to show the user the options for selecting image picker type.
     - Parameter at: The UIViewController where the media action sheet will be presented
     - Parameter pegged: The UIView where the action sheet would be pegged if it were a dropdown.
     - Returns: An observable sequence emitting a single emission (either camera or photo library)
                or simply completing, if cancelled.
     */
    
    public static func  mediaActionSheet        (at: UIViewController, pegged: UIView) -> Observable<UIImagePickerController.SourceType> {

        return Observable.create { obx in

            var actions         : [ SULSlatItem ] = [ ]

            if  UIImagePickerController.isSourceTypeAvailable(.camera) {

                actions.append(SULSlatItem(name: "Camera", icon: ModuleResources.Icon.actionCamera.rawValue, action: {

                    obx.onNext      (.camera)
                    obx.onCompleted ()
                }))
            }

            if  UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {

                actions.append(SULSlatItem(name: "Photo Library", icon: ModuleResources.Icon.templateImage.rawValue, action: {

                    obx.onNext      (.photoLibrary)
                    obx.onCompleted ()
                }))
            }

            let slat                = SULSlat()

                slat.isCancellable  = true

                slat.items          = actions

                slat.message        = "Select Media Source"

                slat.cancelled      = {

                    obx.onCompleted ()
                }

            at.present(asAileron: slat, peg: pegged)

            return Disposables.create()
        }
    }

    
    /***
      action sheet that emits the name of selected StalItem
     */
    public static func  actionSheet        (at: UIViewController, pegged: UIView, message: String, items: [SULSlatItem]) -> Observable<String> {
        
        return Observable.create { obx in
            
            var actions         : [ SULSlatItem ] = [ ]
            
            items.forEach({ item in
                actions.append(SULSlatItem(name: item.name, icon: item.icon, action: {
                    obx.onNext      (item.name)
                    obx.onCompleted ()
                }))
            })
            
//            let slat                = SULSlat()
//
//            slat.isCancellable  = true
//
//            slat.items          = actions
//
//            slat.message        = message
//
//            slat.cancelled      = {
//
//                obx.onCompleted ()
//            }
            
            let slat = OptionSelector(items: actions)
            slat.message = message
            slat.view.backgroundColor = .white
            slat.rxSelected
                .subscribe(onNext: { selected in
                    obx.onNext(selected.1)
                    obx.onCompleted ()
                })
                .disposed(by: slat.disposeBag)
            
            //at.present(asAileron: slat, peg: pegged)
            DispatchQueue.main.async {
                at.present(asPopup: slat, sourceView: pegged)
            }
            
            
            
            return Disposables.create()
        }
    }
    
    /***
     action sheet that emits selected titled item
     */
    public static func  actionSheet        (at: UIViewController, pegged: UIView, message: String, titledItems: [TitledItem]) -> Observable<TitledItem> {
        
        return Observable.create { obx in
            
            var actions         : [ SULSlatItem ] = [ ]
            
            titledItems.forEach({ titled in
                actions.append(SULSlatItem(name: titled.title, icon: titled.icon?.rawValue, action: {
                    obx.onNext      (titled)
                    obx.onCompleted ()
                }))
            })
            
            let slat            = SULSlat()
            
            slat.isCancellable  = true
            
            slat.items          = actions
            
            slat.message        = message
            
            slat.cancelled      = {
                
                obx.onCompleted ()
            }
            
            at.present(asAileron: slat, peg: pegged)
            
            return Disposables.create()
        }
    }

    public static func  promptPrint             (at: UIViewController) -> Observable<PrintSize> {

        return .create { obx in

            let alert = UIAlertController(title: "Print", message: "Select Print size", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Half-Page",   style: .default, handler: { _ in

                obx.onNext      (PrintSize.half)
                obx.onCompleted ()
            }))

            alert.addAction(UIAlertAction(title: "Whole",       style: .default, handler: { _ in

                obx.onNext      (PrintSize.full)
                obx.onCompleted ()
            }))

            alert.addAction(UIAlertAction(title: "Cancel",      style: .cancel, handler: { _ in

                obx.onCompleted ()
            }))


            at.present(alert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    // check if authorized. ask for permission if needed. and emits if permission has been granted.
    public static func requestPhotoPermission   (at presenter: UIViewController) -> Observable<Void> {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        
        guard photoStatus == .authorized else {
            
            let publish = PublishSubject<Void>()
            
            if photoStatus == .notDetermined {
                
                PHPhotoLibrary
                    .requestAuthorization({ (currentStatus: PHAuthorizationStatus) -> Void in
                        if currentStatus == .authorized {
                            publish.onNext(())
                        }
                        publish.onCompleted()
                    })
            } else {
                AlertControllers
                    .create(at: presenter, title: "Warning", body: "Please turn ON photos permission in Settings", defaultActions: nil)
                    .subscribe(onNext: { _ in
                        publish.onCompleted()
                    })
            }
            return publish.asObservable()
        }
        
        return .just(())
    }
}


public extension UIAlertController {
    
    ///returns an observable called after the view was dismissed
    func dismissObx(animated: Bool = false) -> Observable<Void> {
        return .create { obx in
            self.dismiss(animated: animated) {
                obx.onNext(())
                obx.onCompleted()
            }
            return Disposables.create()
        }
    }
    
}

*/
