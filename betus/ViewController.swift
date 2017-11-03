//
//  ViewController.swift
//  betus
//
//  Created by amr Elshendidy on 10/7/17.
//  Copyright © 2017 amr Elshendidy. All rights reserved.
//

import UIKit
import AWSAuthCore
import AWSAuthUI
import AWSFacebookSignIn
import FacebookShare
import FBSDKShareKit
import FacebookCore
import AWSDynamoDB

class ViewController: UITableViewController {

    var demoFeatures: [DemoFeature] = []
    var willEnterForegroundObserver: AnyObject!
    fileprivate let loginButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
    
    // MARK: - View lifecycle
    //amr
    func onSignIn (_ success: Bool) {
        // handle successful sign in
        if (success) {
            self.setupRightBarButtonItem()
            self.updateTheme()
        } else {
            // handle cancel operation from user
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupRightBarButtonItem()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        // You need to call `- updateTheme` here in case the sign-in happens before `- viewWillAppear:` is called.
        updateTheme()
        willEnterForegroundObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.current) { _ in
            self.updateTheme()
        }
        
        presentSignInViewController()
        
        var demoFeature = DemoFeature.init(
            name: NSLocalizedString("User Sign-in",
                                    comment: "Label for demo menu option."),
            detail: NSLocalizedString("Enable user login with popular 3rd party providers.",
                                      comment: "Description for demo menu option."),
            icon: "UserIdentityIcon", storyboard: "UserIdentity")
        
        demoFeatures.append(demoFeature)
        
        demoFeature = DemoFeature.init(
            name: NSLocalizedString("User Data Storage",
                                    comment: "Label for demo menu option."),
            detail: NSLocalizedString("Save user files in the cloud and sync user data in key/value pairs.",
                                      comment: "Description for demo menu option."),
            icon: "UserFilesIcon", storyboard: "UserDataStorage")
        
        demoFeatures.append(demoFeature)
        
        demoFeature = DemoFeature.init(
            name: NSLocalizedString("User Engagement",
                                    comment: "Label for demo menu option."),
            detail: NSLocalizedString("Analyze app usage, define segments, create and measure campaign metrics.",
                                      comment: "Description for demo menu option."),
            icon: "Engage", storyboard: "Engage")
        
        demoFeatures.append(demoFeature)
        
        demoFeature = DemoFeature.init(
            name: NSLocalizedString("NoSQL",
                                    comment: "Label for demo menu option."),
            detail: NSLocalizedString("Store data in the cloud.",
                                      comment: "Description for demo menu option."),
            icon: "NoSQLIcon", storyboard: "NoSQLDatabase")
        
        demoFeatures.append(demoFeature)
        demoFeature = DemoFeature.init(
            name: NSLocalizedString("save post and share ",
                                    comment: "save post and share" ),
            detail: NSLocalizedString("save post and share ",
                                      comment: "save post and share "),
            icon: "savepostandshare", storyboard: "savepostandshare")
        
        demoFeatures.append(demoFeature)
        saveFacebookData()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(willEnterForegroundObserver)
    }
    func saveFacebookData() {
  
        struct FBProfileRequest: GraphRequestProtocol {
            typealias Response = GraphResponse
            
            var graphPath = "/me"
            var parameters: [String : Any]? = ["fields": "id,about,name,first_name,last_name,birthday, religion,email, relationship_status,significant_other, work,currency,devices,cover,education, website, viewer_can_send_gift, video_upload_limits, verified, updated_time ,test_group, sports  , third_party_id, security_settings, quotes ,public_key, payment_pricepoints, political, name_format ,middle_name ,link , location ,languages,  is_verified, is_shared_login, interested_in, installed ,install_type ,favorite_athletes,favorite_teams,inspirational_people ,gender,hometown" ,"limit":"2" as AnyObject]
            var accessToken = AccessToken.current
            var httpMethod: GraphRequestHTTPMethod = .GET
            var apiVersion: GraphAPIVersion = 2.10
        }
        let request = FBProfileRequest()
        var accessToken = AccessToken.current
        print("accessToken : " + (accessToken?.authenticationToken)!)
        //print(accessToken?.authenticationToken)
        request.start { (httpResponse, result) in
            switch result {
            case .success(let response):
                print("Graph Request Succeeded: \(response)")
                let jsonDecoder = JSONDecoder()
                print("response.stringValue")
                let name = response.dictionaryValue!["name"]
                print(name)
            
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        //Create data object using data models you downloaded from Mobile Hub
                var userItem: Users = Users();
        userItem._id = response.dictionaryValue?["id"] as? String
        userItem._birthday = response.dictionaryValue?["birthday"] as! String
              //  userItem._cover = response.dictionaryValue?["cover"]
                let resd = response.dictionaryValue!
                
             //   print (resd["id"]10.)
//        print(userItem._cover)
//                print(userItem._cover!["id"])
        let identityManager = AWSIdentityManager.default()
        dynamoDbObjectMapper.save(userItem, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
                
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
    }
    func setupRightBarButtonItem() {
        navigationItem.rightBarButtonItem = loginButton
        navigationItem.rightBarButtonItem!.target = self
        
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            navigationItem.rightBarButtonItem!.title = NSLocalizedString("Sign-Out", comment: "Label for the logout button.")
            navigationItem.rightBarButtonItem!.action = #selector(ViewController.handleLogout)
        }
    }
    
    func presentSignInViewController() {
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            let config = AWSAuthUIConfiguration()
            config.enableUserPoolsUI = false
            config.logoImage = UIImage(named: "betus1.jpg")
            config.addSignInButtonView(class: AWSFacebookSignInButton.self)
            config.canCancel = false
            
            AWSAuthUIViewController.presentViewController(with: self.navigationController!,
                                                          configuration: config,
                                                          completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                                            if error != nil {
                                                                print("Error occurred: \(error)")
                                                            } else {
                                                                self.onSignIn(true)
                                                            }
            })
        }
    }
    
    // MARK: - UITableViewController delegates
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainViewCell")!
        let demoFeature = demoFeatures[indexPath.row]
        print("**************************")
        print(demoFeature.icon)
        print(demoFeature.displayName)
        print(demoFeature.detailText)
        cell.imageView!.image = UIImage(named: demoFeature.icon)
        cell.textLabel!.text = demoFeature.displayName
        cell.detailTextLabel?.text = demoFeature.detailText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoFeatures.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let demoFeature = demoFeatures[indexPath.row]
        let storyboard = UIStoryboard(name: demoFeature.storyboard, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: demoFeature.storyboard)
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func updateTheme() {
        let settings = ColorThemeSettings.sharedInstance
        settings.loadSettings { (themeSettings: ColorThemeSettings?, error: Error?) -> Void in
            guard let themeSettings = themeSettings else {
                print("Failed to load color: \(error)")
                return
            }
            DispatchQueue.main.async(execute: {
                let titleTextColor: UIColor = themeSettings.theme.titleTextColor.UIColorFromARGB()
                self.navigationController!.navigationBar.barTintColor = themeSettings.theme.titleBarColor.UIColorFromARGB()
                self.view.backgroundColor = themeSettings.theme.backgroundColor.UIColorFromARGB()
                self.navigationController!.navigationBar.tintColor = titleTextColor
                self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleTextColor]
            })
        }
    }
    
    
    func handleLogout() {
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            ColorThemeSettings.sharedInstance.wipe()
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, error: Error?) in
                self.navigationController!.popToRootViewController(animated: false)
                self.setupRightBarButtonItem()
                self.updateTheme()
                self.presentSignInViewController()
            })
            // print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            assert(false)
        }
    }
}

class FeatureDescriptionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
    }


}

