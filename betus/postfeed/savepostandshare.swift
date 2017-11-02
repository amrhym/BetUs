//
//  savepostandshare.swift
//  betus
//
//  Created by amr Elshendidy on 10/24/17.
//  Copyright © 2017 amr Elshendidy. All rights reserved.
//

import UIKit
import AWSCore
import AWSDynamoDB
import AWSAuthCore
import FacebookShare
import FBSDKShareKit
import FacebookCore
class savepostandshare: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        //Create data object using data models you downloaded from Mobile Hub
        let postItem: Posts = Posts();
        let identityManager = AWSIdentityManager.default()
        // Use AWSIdentityManager.default().identityId here to get the user identity id.
        postItem._text = "amooor #amrhym"
        postItem._dateTime = "29/09/1987"
        postItem._imageurl?["1"] = "https://static.pexels.com/photos/5390/sunset-hands-love-woman.jpg"
        postItem._postType = "hidden"
        postItem._userId = identityManager.identityId
      //  postItem._taggedusers?.append("none")
       // postItem._videourl?["1"] = "none"
        
        postItem._postId = "aaaaaasaaaaa"
        var content = LinkShareContent(url: URL(string: "https://static.pexels.com/photos/5390/sunset-hands-love-woman.jpg")!,
                                       title: "Name: Facebook News Room",
                                       description: "Description: The Facebook Swift SDK helps you develop Facebook integrated iOS apps.",
                                       quote : "amr",
                                       imageURL: URL(string: "https://static.pexels.com/photos/5390/sunset-hands-love-woman.jpg"))
       // content.taggedPeopleIds = ["AaLLudkKCF6sFl59bAR7I5rxrnqJfbSzbNxXB801b5GZ9sKVqO5robtOuGdddjlj_bTf4Aito9UJStZdutc9eSUFQYw8vw6TtYk3epyVl7_L_w"]
        let message = "amooor #amrhym"
        content.hashtag = Hashtag("#amrhym")
        // share(content , message2 : message)


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
//                let data = response.dictionaryValue!["data"] as? [Any]
//                print(data)
//                let res = data![0] as? [String:Any]
//                print(res)
                let name = response.dictionaryValue!["name"]
                print(name)
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
      
        
        
        
        //Save a new item
        dynamoDbObjectMapper.save(postItem, completionHandler: {
            (error: Error?) -> Void in

            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
        let dynamoDbObjectMapperread = AWSDynamoDBObjectMapper.default()

        //Create data object using data models you downloaded from Mobile Hub
        var newsItem: Posts = Posts();

        dynamoDbObjectMapperread.load(
            // Use AWSIdentityManager.default().identityId here to get the user identity id.

           Posts.self,
           hashKey: "aaaaaasaaaa",
            rangeKey: nil,
            completionHandler: {
                (AWSDynamoDBObjectModel, error: Error?) -> Void in

                if let error = error {
                    print("Amazon DynamoDB Save Error: \(error)")
                    return
                }
                print("sdsdsdsdsds")
                newsItem = AWSDynamoDBObjectModel as! Posts
                print(newsItem._text)
                })
       
        
        
        //****************************************************
        let queryExpression = AWSDynamoDBQueryExpression()

        queryExpression.keyConditionExpression = "#postId = :postId"

        queryExpression.filterExpression = "#postType = :postType"
        queryExpression.expressionAttributeNames = [
            "#postId": "postId",
            "#postType": "postType"
        ]
        queryExpression.expressionAttributeValues = [
            ":postId": "s",
            ":postType": "hidden"
        ]

        // 2) Make the query
         print("sssssssss")
        let dynamoDbObjectMapperr = AWSDynamoDBObjectMapper.default()
         print("sssssssss")
        dynamoDbObjectMapperr.query(Posts.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            if error != nil {
                print("The request failed. Error: \(String(describing: error))")
            }
            print(output?.items)
            if output != nil {
                for Posts in output!.items {
                    let newsItem = Posts as? Posts
                    print("\(newsItem!._text!)")
                }
            }
        }
    /************************************************************/
//        let objectMapper = AWSDynamoDBObjectMapper.default()
//        let scanExpression = AWSDynamoDBScanExpression()
//
//        scanExpression.filterExpression = "contains(#postId, :postId)"
//        scanExpression.expressionAttributeNames = ["#postId": "postId"]
//        scanExpression.expressionAttributeValues = [":postId": "s"]
//        objectMapper.scan(Posts.self, expression: scanExpression).continueWith(block: { (task:AWSTask!) -> AnyObject! in
//
//            if task.result != nil {
//                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
//                  print(paginatedOutput.items.count as! [Posts])
//                //use the results
//                for item in paginatedOutput.items as! [Posts] {
//                    print(item)
//                }
//
//                if ((task.error) != nil) {
//                    print("Error: \(task.error)")
//                }
//                //self.queryInProgress = false
//                return nil
//
//            }
//
//            //self.queryInProgress = false
//            return nil
//        })
 
 
        //Create data object using data models you downloaded from Mobile Hub
    }
    func getItemWithCompletionHandler(_ completionHandler: @escaping (_ response: AWSDynamoDBObjectModel?, _ error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(Posts.self, hashKey: "demo-postId-500000", rangeKey: nil) { (response: AWSDynamoDBObjectModel?, error: Error?) in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error as NSError?)
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func share<C: ContentProtocol>(_ content: C , message2 : String) {
        var title: String = ""
        var message: String = ""
        
        do {
            try GraphSharer.share(content ,message : message2) { result in
                switch result {
                case .success(let contentResult):
                    title = "Share Success"
                    message = "Succesfully shared: \(contentResult)"
                case .cancelled:
                    title = "Share Cancelled"
                    message = "Sharing was cancelled by user."
                case .failed(let error):
                    title = "Share Failed"
                    message = "Sharing failed with error \(error)"
                }
                // let alertController = UIAlertController(title: title, message: message)
                //  self.present(alertController, animated: true, completion: nil)
            }
        } catch (let error) {
            title = "Share API Fail"
            message = "Failed to invoke share API with error: \(error)"
            //  let alertController = UIAlertController(title: title, message: message)
            // present(alertController, animated: true, completion: nil)
        }
    }

}
