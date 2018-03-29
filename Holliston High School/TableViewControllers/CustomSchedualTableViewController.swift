//
//  CustomSchedualTableViewController.swift
//  Holliston High School
//
//  Created by HSimage HSimage on 3/15/18.
//  Copyright © 2018 Tom Reeve. All rights reserved.
//

import UIKit
import SWRevealViewController


class CustomSchedualTableViewController: UIViewController, SWRevealViewControllerDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var blockA: UITextField!
    @IBOutlet weak var blockB: UITextField!	
    @IBOutlet weak var blockC: UITextField!
    @IBOutlet weak var blockD: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var useClassNames: UISwitch!
    @IBOutlet weak var testTxt: UITextField!
    @IBOutlet weak var textAfter: UITextField!
    
    @IBAction func saveButtonClick(_ sender: Any) {
        let defaults = `UserDefaults`.standard
        
        defaults.set(blockA.text, forKey: "BlockA")
        defaults.set(blockB.text, forKey: "BlockB")
        defaults.set(blockC.text, forKey: "BlockC")
        defaults.set(blockD.text, forKey: "BlockD")
        defaults.set(useClassNames.isOn, forKey: "Switch")
        defaults.synchronize()
        
        print("bA=\(String(describing: blockA.text)), bB=\(String(describing: blockB.text)), bC=\(String(describing: blockC.text)), bD =\(String(describing: blockD.text))" )
    }
    @IBAction func clearButtonClick(_ sender: Any) {
        if(blockA.text == ""){
            loadDefaults()
            clearButton.setTitle("Clear", for: [])
        }
        else {
            blockA.text = ""
            blockB.text = ""
            blockC.text = ""
            blockD.text = ""
            textAfter.text = ""
            clearButton.setTitle("Load", for: [])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            useClassNames.addTarget(self, action: Selector(("replacing:")), for: UIControlEvents.valueChanged)
            useClassNames.setOn(true, animated: true)
            let toolBar = UIToolbar()
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
            toolBar.sizeToFit()
            blockA.inputAccessoryView = toolBar
            blockB.inputAccessoryView = toolBar
            blockC.inputAccessoryView = toolBar
            blockD.inputAccessoryView = toolBar
            toolBar.setItems([doneButton], animated: false)
        }
        
        loadDefaults()
    }
    @objc func doneClicked(){
        view.endEditing(true)
    }
    func loadDefaults() {
        let defaults = `UserDefaults`.standard
        blockA.text = (defaults.object(forKey: "BlockA") as! String)
        blockB.text = (defaults.object(forKey: "BlockB") as! String)
        blockC.text = (defaults.object(forKey: "BlockC") as! String)
        blockD.text = (defaults.object(forKey: "BlockD") as! String)
    }
    static func switchGet()->Bool{let defaults = `UserDefaults`.standard;
        if defaults.object(forKey: "Switch") == nil{
            return false
        }else{
            return defaults.object(forKey: "Switch") as! Bool
        }
    }
   static func blockAGet()->String{let defaults = `UserDefaults`.standard;
    if defaults.object(forKey: "BlockA") == nil {
        return "A Block"
    }else{
    return (defaults.object(forKey: "BlockA") as! String)}
    }
    static func blockBGet()->String{let defaults = `UserDefaults`.standard;
        if defaults.object(forKey: "BlockB") == nil {
            return "B Block"
        }else{
            return (defaults.object(forKey: "BlockB") as! String)}
    }
    static func blockCGet()->String{let defaults = `UserDefaults`.standard;
        if defaults.object(forKey: "BlockC") == nil {
            return "C Block"
        }else{
            return (defaults.object(forKey: "BlockC") as! String)}
        
    }
    static func blockDGet()->String{let defaults = `UserDefaults`.standard;
        if defaults.object(forKey: "BlockD") == nil {
            return "D Block"
        }else{
            return (defaults.object(forKey: "BlockD") as! String)}
    }
     func testStringGet()->String{ return testTxt.text!}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func replacing(text: String) -> String {
        var returntext: String = ""
        if switchGet() == true {
        returntext = text.replacingOccurrences(of: "A Block", with: blockAGet())
            .replacingOccurrences(of: "B Block", with: blockBGet())
            .replacingOccurrences(of: "C Block", with: blockCGet())
            .replacingOccurrences(of: "D Block", with: blockDGet())
        }
        return returntext
        
    }
  //  static func replacing (text: String)-> String{
    //    return replacing(text: text, UseClassNames: UISwitch!.none)
    //}
}
