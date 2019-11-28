/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import UIKit
import OpenWhisk

class ViewController: UIViewController {

    @IBOutlet weak var whiskButton: WhiskButton!
    @IBOutlet weak var outputText: UITextView!
    @IBOutlet weak var statusLabel: UILabel!

    /** Please replace the values as it is described in the Serverless Swift book
            in chapte 4,
            in the section 'Calling Serverless function from a mobile iOS app in Swift'
        
        let WhiskAppKey = "Your Whisk App Key"
        let WhiskAppSecret = "Your Whisk App Secret"

        // the URL for Whisk backend
        let baseUrl: String? = "https://openwhisk.ng.bluemix.net"

        let MyNamespace: String = "Your Namespace Id"
        let MyPackage: String? = "hello-world-serverless-swift-cli"
        let MyWhiskAction: String = "helloworld"
    */
    
    // Change to your whisk app key and secret.
    let WhiskAppKey = "Your Whisk App Key"
    let WhiskAppSecret = "Your Whisk App Secret"

    // the URL for Whisk backend
    let baseUrl: String? = "https://openwhisk.ng.bluemix.net"

    // Choice: specify components
    let MyNamespace: String = "Your Namespace Id"
    let MyPackage: String? = "hello-world-serverless-swift-cli"
           
    // The action to invoke.
    let MyWhiskAction: String = "helloworld"

    var MyActionParameters: [String:AnyObject]? = nil
    let HasResult: Bool = true // true if the action returns a result

    var session: URLSession!

    override func viewDidLoad() {
        super.viewDidLoad()

        // create custom session that allows self-signed certificates
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: SelfSignedNetworkDelegate(), delegateQueue:OperationQueue.main)

        // create whisk credentials token
        let creds = WhiskCredentials(accessKey: WhiskAppKey,accessToken: WhiskAppSecret)

        // Setup action using components
        whiskButton.setupWhiskAction(MyWhiskAction, package: MyPackage, namespace: MyNamespace, credentials: creds, hasResult: HasResult, parameters: MyActionParameters, urlSession: session, baseUrl: baseUrl)

        navigationItem.title = "Serverless Swift - Hello World"

    }

    @IBAction func whiskButtonPressed(sender: AnyObject) {
        MyActionParameters = ["name": "Serverless Swift" as AnyObject]
                
        // Invoke action with parameters.
        whiskButton.invokeAction(parameters: MyActionParameters, actionCallback: { reply, error in
            if let error = error {
                print("Oh no! \(error)")
                if case let WhiskError.httpError(description, statusCode) = error {
                    print("HttpError: \(description) statusCode:\(statusCode)")
                    self.statusLabel.text = "Action \(self.MyWhiskAction) returned an error: \(description)"
                }
            } else if let reply = reply {
                let str = "\(reply)"
                print("reply: \(str)")
                self.statusLabel.text = "Action \(self.MyWhiskAction) returned \(str.count) characters"
                if let result = reply["result"] as? [String:AnyObject] {
                    self.displayOutput(reply: result)
                }
            } else {
                print("Success")
            }
        })
    }


    func displayOutput(reply: [String:AnyObject]) {
        if let message = reply["message"] as? String{
            self.outputText.text = message
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

