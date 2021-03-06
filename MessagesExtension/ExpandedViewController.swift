//
//  ExpandedViewController.swift
//  FollowUp
//
//  Created by Spencer Brown on 4/15/17.
//  Copyright © 2017 Spencer Brown. All rights reserved.
//

import UIKit
import EventKit


class ExpandedViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate{
    
    //MARK: Properties
    var viewState: MessagesViewController.AppState = MessagesViewController.AppState.detailView
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var reminderContentLabel: UILabel!
    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var reminderTimeLabel: UILabel!
    @IBOutlet weak var createReminder: UIButton!
    
    let eventStore = EKEventStore()
    
    var pickerKeys: [String] = [String]()
    
    var pickerValues: [MessagesViewController.PickerValue] = []
    
    var pickerIndex: Int = 0
    
    //Identifier
    static let storyboardIdentifier = "ExpandedVC"


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Get a reference to the parent view
        guard let messageController = self.parent as? MessagesViewController else {
            fatalError("can't open")
        }
        
        //Set up picker
        picker.delegate = self
        picker.dataSource = messageController
        pickerKeys = messageController.pickerKeys
        pickerValues = messageController.pickerValues
        pickerIndex = messageController.pickerIndex
        
        picker.selectRow(messageController.pickerIndex, inComponent: 0, animated: true)
        
        setDateString(index: pickerIndex)
        
        //Set up text field
        reminderTextField.delegate = self
        
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        
//        reminderTextField.becomeFirstResponder()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Picker Delegate Functions
    //When naming the picker rows
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String?{
        
        return pickerKeys[row]
    }
    
    //When a value is selected in the picker
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int){
    
        setDateString(index: row)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Actions
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        
        checkCalendarAccess()

        
        //Create calendar event
        let event = EKEvent(eventStore: self.eventStore)
        
        event.title = reminderContentLabel.text!
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do{
            try eventStore.save(event, span: EKSpan.thisEvent)
        } catch let error {
            print("Calendar failed with error \(error.localizedDescription)")
        }
        
    }
    

    //MARK: - Private Functions
    //Value of the text field changed
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        
        let message = "\"Follow up with " + sender.text! + "\""
        reminderContentLabel.text = message
    
    }
    
    //Get) rid of the keyboard when editing done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    private func setDateString(index: Int){
        
        reminderTimeLabel.text = pickerValues[index].string
        
    }
    
    //Check if the user has given access to the calendar
    private func checkCalendarAccess(){
        
        print("here")
        
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        print("here")
        
        switch status{
        case EKAuthorizationStatus.notDetermined:
            //On first time through
            print("here")
            requestAccessToCalendar()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            print("Access Denied")
        default:
            print("Access Available")
        }
        
    }
    
    //request access to calendar
    private func requestAccessToCalendar(){
        
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            //Eventually this will print access granted
            if !accessGranted{
                print("Access to store not granted")
            }
        }) //completion
    }//requestAccess...

}
