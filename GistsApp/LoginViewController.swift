//
//  LoginViewController.swift
//  GistsApp
//
//  Created by Antonio Alves on 7/22/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

protocol LoginViewDelegate: class {
    func didTapLoginButton()
}

class LoginViewController: UIViewController {
    
    weak var delegate: LoginViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tappedLoginButton(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.didTapLoginButton()
        }
    }
}
