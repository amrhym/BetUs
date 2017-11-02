//
//  11ViewController.swift
//  betus
//
//  Created by amr Elshendidy on 10/29/17.
//  Copyright © 2017 amr Elshendidy. All rights reserved.
//

import UIKit
import AWSCore
import AWSDynamoDB
import AWSAuthCore
import FacebookShare
import FBSDKShareKit
import FacebookCore

class _1ViewController: UIViewController {

  
    override func viewDidLoad() {
        super.viewDidLoad()
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        var text : [String] = []
//        scanExpression.filterExpression = "contains(#postId, :postId)"
//        scanExpression.expressionAttributeNames = ["#postId": "postId"]
//        scanExpression.expressionAttributeValues = [":postId": "s"]
//
//
//        objectMapper.scan(Posts.self, expression: scanExpression).continueWith(block: { (task:AWSTask!) -> AnyObject! in
//
//            if task.result != nil {
//                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
//                print(paginatedOutput.items.count )
//
//                //use the results
//
//                for item in paginatedOutput.items as! [Posts] {
//                    print(item)
//                    print(item._text)
//                    text.append(item._text!)
//                    print(text)
//                }
//                print("text")
//                print(text)
//                let preferences = UserDefaults.standard
//                preferences.set( text, forKey: "session")
//                print(text)
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
       
        
        struct FBProfileRequest: GraphRequestProtocol {
            typealias Response = GraphResponse
            
            var graphPath = "/me/taggable_friends"
            var parameters: [String : Any]? = ["fields": "id, name" ,"limit":"9999" as AnyObject]
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
                let data = response.dictionaryValue!["data"] as? [Any]
                print(data)
                print(data?.count)
                for item in data! {
                    let res = item as? [String:Any]
                    let name = res!["name"]
                    text.append(name as! String)
                    print(name)
                }
                let preferences = UserDefaults.standard
                preferences.set( text, forKey: "session")
                let res = data![0] as? [String:Any]
                print(res)
                let name = res!["name"]
                //text.append(name)
                print(name)
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
            
            //   self.presentAlertControllerFor(result)
        }
        
        
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
