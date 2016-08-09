//
//  ViewController.swift
//  testing-dropbox
//
//  Created by Mengying Feng on 6/08/2016.
//  Copyright © 2016 Mengying Feng. All rights reserved.
//

import UIKit
import SwiftyDropbox

class ViewController: UIViewController, UITextFieldDelegate {
    //========================================
    // MARK: - Properties
    //========================================
    var filenames: Array<String>?
    
    //========================================
    // MARK: - Outlets
    //========================================
    @IBOutlet weak var textField: UITextField!
    
    //========================================
    // MARK: - View Life Cycle
    //========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        textField.delegate = self
        
        self.filenames = []
        
        
    }
    
    
    
    
    //========================================
    // MARK: - Actions
    //========================================
    @IBAction func linkBtnPressed(sender: AnyObject) {
        
        
        
        if let client = Dropbox.authorizedClient {
            client.users.getCurrentAccount().response({ (accountResult, error) in
                print("*** Get current account ***")
                if let userAccount = accountResult {
                    print("Hello \(userAccount.name.givenName)!")
                } else {
                    print("User Account error: \(error)")
                }
            })
            /*
            client.files.listFolder(path: "/EMINEM").response({ (folderResult, folderError) in
                print("*** List folder ***")
                if let result = folderResult {
                    
                    print("Folder contents:")

                    print(result)
                    
//                    for entry in result.entries {
//                        
//                        print(entry.name)
//                        print(entry.description)
//                        print(entry.pathDisplay)
//                        print(entry.pathLower)
//                        
//                    }
                    
                    
                } else {
                    
                    print("entry error: \(folderError)")
                }
            })
            */
            
            
            client.files.listFolder(path: "", recursive: true, includeMediaInfo: true, includeDeleted: true, includeHasExplicitSharedMembers: true).response({ (result, error) in
                print("*** List folder ***")
                if let myresult = result {
                    
                    print("Folder contents:")
                    
                    print(myresult)
                    
                    //                    for entry in result.entries {
                    //
                    //                        print(entry.name)
                    //                        print(entry.description)
                    //                        print(entry.pathDisplay)
                    //                        print(entry.pathLower)
                    //
                    //                    }
                    
                    
                } else {
                    
                    print("entry error: \(error)")
                }
            })
            
            
            
            
            client.files.getMetadata(path: "/diesel copy.jpg", includeMediaInfo: true, includeDeleted: true, includeHasExplicitSharedMembers: true).response({ (metadata, error) in
                print("*** Metadata ***")
                
                if let result = metadata {
                    print(result.name)
                    print(result.description)
                    
                    
                }
                
            })
            
            
            
            
            /*
            //========================================
            // MARK: - Reference
            //========================================
            /// Create a shared link with custom settings. If no settings are given then the default visibility is public_ in
            /// RequestedVisibility (The resolved visibility, though, may depend on other aspects such as team and shared folder
            /// settings).
            ///
            /// - parameter path: The path to be shared by the shared link
            /// - parameter settings: The requested settings for the newly created shared link
            ///
            ///  - returns: Through the response callback, the caller will receive a `Sharing.SharedLinkMetadata` object on
            /// success or a `Sharing.CreateSharedLinkWithSettingsError` object on failure.
            public func createSharedLinkWithSettings(path path: String, settings: Sharing.SharedLinkSettings? = nil) -> RpcRequest<Sharing.SharedLinkMetadataSerializer, Sharing.CreateSharedLinkWithSettingsErrorSerializer> {
                let route = Sharing.createSharedLinkWithSettings
                let serverArgs = Sharing.CreateSharedLinkWithSettingsArg(path: path, settings: settings)
                return client.request(route, serverArgs: serverArgs)
            
            */
            
            
            
            
            
        } else {
            Dropbox.authorizeFromController(self)
        }
        
        
        
        
    }

    
    @IBAction func logout(sender: AnyObject) {
        
        print("*** Unlink User ***")
        Dropbox.unlinkClient()
        
    }
    
 
    
    @IBAction func saveText(sender: AnyObject) {
    
        let tmpURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = tmpURL.URLByAppendingPathComponent("\(textField.text!).txt")
        do {
            try textField.text?.writeToURL(fileURL, atomically: true, encoding: NSUTF8StringEncoding)
            print("Save text file")
        } catch {
            print("saveText failed")
        }
    
    }
    
    @IBAction func upload(sender: AnyObject) {
        
        
        let tmpURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = tmpURL.URLByAppendingPathComponent("\(textField.text!).txt")
        
        if let client = Dropbox.authorizedClient {
            client.files.upload(path: "/\(textField.text!).txt", mode: Files.WriteMode.Overwrite, autorename: true, clientModified: NSDate(), mute: false, input: fileURL).response { response, error in
                if let metadata = response {
                    print("Uploaded file name: \(metadata.name)")
                } else {
                    print(error!)
                }
            }
        }
    }
    
    @IBAction func download(sender: AnyObject) {
        if let client = Dropbox.authorizedClient {
            
            
            let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
                let directoryURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let pathComponent = "\(NSUUID().UUIDString)-\(response.suggestedFilename!)"
                return directoryURL.URLByAppendingPathComponent(pathComponent)
            }
            
            client.files.download(path: "/\(textField.text!).txt", destination: destination).response { response, error in
                if let (metadata, url) = response {
                    print("Downloaded file name: \(metadata.name)")
                    print(metadata.description)
                    
                } else {
                    print(error!)
                }
            }
        }
        
        
    }
    
    @IBAction func deleteBtnPressed(sender: AnyObject) {
        
        if let client = Dropbox.authorizedClient {
            client.files.delete(path: "/\(textField.text!).txt").response { response, error in
                if let metadata = response {
                    print("Deleted file name: \(metadata.name)")
                } else {
                    print(error!)
                }
            }
        }
        
    }
    
    @IBAction func share(sender: AnyObject) {
        
        if let client = Dropbox.authorizedClient {
            
            client.sharing.createSharedLinkWithSettings(path: "/diesel copy.jpg", settings: nil).response({ (result, error) in
                if let link = result {
                print("*** Sharing ***")
                print(link)
                } else {
                    print("share error: \(error)")
                }
            })
            
        }
        
        
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

