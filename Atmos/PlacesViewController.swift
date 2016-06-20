//
//  FirstViewController.swift
//  Atmos
//
//  Created by Evangelos on 02/01/16.
//  Copyright © 2016 Evangelos. All rights reserved.
//

import UIKit
import CoreLocation
class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    //MARK: Properties
    var searchPlacesTableView = UITableView()
    var place: Place?
    var searchController = SearchPlacesTableViewController()
    var spinner = UIActivityIndicatorView()
    var noPlacesText = UITextView()
    
    
    struct variables { //MARK: put in here variables you wish to be accessible by the inner class
        static var varOne: Int = 1
        static var places = [Place]()
        static var availablePlaces = [Place]()
        static var searchPlacesTextField = UITextField()
        static var searchingForNewPlaces = false //this flag indicates whether a user is searching for a place using the dynamically generated search place text
        static var toolbox = Toolbox()
        static var newPlaceAdded = false //this flag indicates if a new place has been added to enable quickly getting crowd weather updates for it
        static var blurEffectView = UIVisualEffectView() //this view is added when search Text is shown to blur out the background and draw attention to the text field
    }//endVariables()
    
    @IBOutlet weak var addPlaceBarButton: UIBarButtonItem!
    @IBAction func addPlaceBarButton(sender: UIBarButtonItem) {
        if(variables.toolbox.isConnectedToNetwork()){
            //!!!ATTENTION HERE!!!: Consider limiting text input to only alphabetical characters for preventing MySQL injection attempts
            //Also deactivate copy paste
            let screen = UIScreen.mainScreen().bounds
            let screenWidth = screen.size.width
            //let screenHeight = screen.size.height
            let xpos = (screenWidth - 300)/2
            
            variables.searchPlacesTextField = UITextField(frame: CGRectMake(xpos, 100, 300, 40))
            variables.searchPlacesTextField.placeholder = "Type a place to search..."
            variables.searchPlacesTextField.font = UIFont.systemFontOfSize(15)
            variables.searchPlacesTextField.borderStyle = UITextBorderStyle.RoundedRect
            variables.searchPlacesTextField.autocorrectionType = UITextAutocorrectionType.No
            variables.searchPlacesTextField.keyboardType = UIKeyboardType.Default
            variables.searchPlacesTextField.returnKeyType = UIReturnKeyType.Done
            variables.searchPlacesTextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
            variables.searchPlacesTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
            variables.searchPlacesTextField.delegate = self
            dimBackground()
            self.view.addSubview(variables.searchPlacesTextField)
            variables.searchPlacesTextField.becomeFirstResponder()
            variables.searchingForNewPlaces = true
        } else {
            NSLog("-->No Internet connection")
            let title = "Internet Connection Unavailable"
            let msg = "An Internet connection is required for adding new places. Please connect to the Internet and try again."
            let alertController = UIAlertController (title: title, message: msg, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil);
        }//endElse
    }//endAddPlaceButton()
    
    
    @IBOutlet weak var testBarButton: UIBarButtonItem!
    //TEST BUTTON PRESS HERE FOR TESTING FUNCTIONS
    @IBAction func testBarButtonPress(sender: UIBarButtonItem) { //LAST UPDATE 27 Jan 17:22: Everything works fine. Make sure you put the following segments in a timer that updates places periodically also make sure you call save data afterwards. Then, call the updateWeather function also on start and also when a new place is added in the table. Then, have a look at the Now and Later tabs and see if you can use functions added in Toolbox for painting the UI based on night/day and slider selections - (fixed)
        
        
        //  NSLog("Test Button pressed")
        //  let url = NSURL(string: "http://beja.m-iti.org/web/?q=node/11")!
        //  UIApplication.sharedApplication().openURL(url)
        
    }//endTestButtonPress()
    
    func showNoPlacesTextView() {
        let screen = UIScreen.mainScreen().bounds
        let screenWidth = screen.size.width
        let screenHeight = screen.size.height
        let xpos = (screenWidth - 300)/2
        let ypos = (screenHeight - 300)/2
        noPlacesText = UITextView(frame: CGRectMake(xpos, ypos, 300, 40))
        noPlacesText.font = UIFont.systemFontOfSize(25)
        // noPlacesText.backgroundColor
        noPlacesText.text = "Testing..."
        self.view.addSubview(noPlacesText)
    }
    
    func showAvailablePlacesTable(){
        self.searchPlacesTableView.removeFromSuperview()//removing the searchPlacesTableView from superview everytime a new one is created
        let screen = UIScreen.mainScreen().bounds
        let screenWidth = screen.size.width
        //  let screenHeight = screen.size.height
        let xpos = (screenWidth - 300)/2 //positioning table always in the middle of the screen
        searchPlacesTableView = UITableView(frame: CGRectMake(xpos, 140, 300, CGFloat(50 * variables.availablePlaces.count)))//(y, x, width, height)//adjusting table's length depending on how many places are returned
        
        searchPlacesTableView.rowHeight = UITableViewAutomaticDimension
        searchPlacesTableView.rowHeight = 50
        searchPlacesTableView.delegate = self.searchController
        searchPlacesTableView.dataSource = self.searchController
        view.addSubview(searchPlacesTableView)
        //self.view.addSubview(self.searchPlacesTable)
    }//endAddPlaceList()
    
    @IBOutlet weak var placesTableView: UITableView!
    
    //MARK: VIEW DID LOAD <------------------------------>
    override  func viewDidLoad() {
        super.viewDidLoad()
        // variables.toolbox.savePlaces(variables.places)//this is
        placesTableView.delegate = self
        placesTableView.dataSource = self
        NSLog("-->Places Tab loaded")
        
        let savedPlaces = variables.toolbox.loadPlaces()
        if savedPlaces?.isEmpty == false  {
            variables.places += savedPlaces! as [Place]
        } else {
            loadSamplePlaces()
        }
        
        NSLog(" places length: " + String(variables.places.count))
        
        // let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        // view.addGestureRecognizer(tap)
        
        
        //MARK: Edit button here.
        // Use the edit button item provided by the table view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        variables.toolbox.initializeLocationManager()
        
        _ = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "refreshGUI", userInfo: nil, repeats: true)//this starts a timer for updating GUI
        
        _ = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "getCrowdWeatherUpdates", userInfo: nil, repeats: true)//this starts a timer for updating crowd weather periodically
        
        _ = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "reverseGeolocateCurrentLocation", userInfo: nil, repeats: true)//
        
        getCrowdWeatherUpdates() //Requesting Crowd Weather Updates
        
        if(variables.toolbox.isConnectedToNetwork() == false) { //notifying user once that Interent is not available
            NSLog("-->No Internet connection")
            let title = "Internet Connection Unavailable"
            let msg = "An Internet connection is required for retrieving crowd weather updates. Please connect to the Internet."
            let alertController = UIAlertController (title: title, message: msg, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil);
        }//endIF
    }//endViewDidLoad()
    
    //MARK: Update GUI loop for implicit GUI updates
    func refreshGUI(){
        //MARK: Here we perfom GUI refreshing related actions
        if placesTableView.editing == false { //Only update table when user is not editing it
            placesTableView.reloadData() //Activate again after debugg
        } else {
            // addPlaceBarButton.enabled = false
        }
        //MARK: request immediate updates if a new place has just been added and table is not empty
        if (variables.newPlaceAdded == true && variables.places.isEmpty == false) {
            getCrowdWeatherUpdates()
            variables.newPlaceAdded  = false //take down flag after update request has been filed
        }
        
        //MARK: When should the ADD (+) button be available?
        //When user is not editing the PlacestableView
        //When user is not searching for a new place
        if(placesTableView.editing == true) || (variables.searchingForNewPlaces == true) {
            addPlaceBarButton.enabled = false
        } else {
            addPlaceBarButton.enabled = true
        }
        //MARK: When should the EDIT button be available?
        //When user is not already editing the PlacesTableView
        //When user is not searching for a new place
        //When user PlacesTableView has places to edit (delete)
        if((variables.searchingForNewPlaces == true) || (variables.places.isEmpty == true)) {
            self.editButtonItem().enabled = false
        } else {
            self.editButtonItem().enabled = true
            
        }
        
        if (variables.places.isEmpty == true) && (isVisible(variables.blurEffectView) == false){
            dimBackground()
        } else if (variables.places.isEmpty == false) && (isVisible(variables.blurEffectView) == true) && (variables.searchingForNewPlaces == false) {
            variables.blurEffectView.removeFromSuperview()
        }
    }//endUpdate()
    func checkDaylight(){
        
    }//endCheckDaylight
    
    func getCrowdWeatherUpdates() {//Here you send requests for weather updates for the places you have in the tableView and you handle the reception of the actual updates
        if(variables.toolbox.isConnectedToNetwork()==true){ //if Internet connection available
            //MARK: Get CrowdReports Available for added places
            variables.toolbox.getCrowdReports(variables.places) { (crowdReports) -> () in
                if crowdReports.count > 0 {
                    for var i = 0; i < variables.places.count; i++ {
                        for cReport in crowdReports {
                            if (variables.places[i].getName() == cReport.getName() && variables.places[i].getCountry() == cReport.getCountry()) {
                                variables.places[i].setCrowdReport(cReport.getCrowdReport()) //loading Crowd Report
                                variables.places[i].setPosition(cReport.getPosition()) //loading position
                                NSLog("***Crowd Report for \(variables.places[i].getName()) with id \(variables.places[i].getCrowdReport().getId()) fetched")
                            } else {
                                // variables.places[i].getCrowdReport().setPool("No data")
                            }//endIf
                        }//endFor
                    }//endFor
                }//endIf
                variables.toolbox.savePlaces(variables.places)//saving CrowdReports
            }//endClosure
            //MARK: Get CrowdPredictions Available for added places
            variables.toolbox.getCrowdPredictions(variables.places) { (crowdPredictions) -> () in
                if crowdPredictions.count > 0 {
                    for var i = 0; i < variables.places.count; i++ {
                        for cPrediction in crowdPredictions {
                            if (variables.places[i].getName() == cPrediction.getName() && variables.places[i].getCountry() == cPrediction.getCountry()) {
                                variables.places[i].setCrowdPrediction(cPrediction.getCrowdPrediction())
                                NSLog("***Crowd Prediction for \(variables.places[i].getName()) with id \(variables.places[i].getCrowdPrediction().getId()) fetched")
                            } else {
                                // variables.places[i].getCrowdReport().setPool("No data")
                            }//endIf
                        }//endFor
                    }//endFor
                }//endIf
                NSLog("Size of CrowdPredictions: \(crowdPredictions.count)")
                variables.toolbox.savePlaces(variables.places)//saving CrowdPredictions
            }//endClosure
        }//endIfInternetCheck
    }//endGetWeatheUpdates()
    
    func reverseGeolocateCurrentLocation(){
        if(variables.toolbox.locationAvailable() == true) {
            variables.toolbox.actualPosition = variables.toolbox.locateActualPosition(variables.toolbox.actualPosition)
        } else {
            NSLog("--Can't reverse geolocate because location services are turned off or permissions are revoked")
        }
    }//endReverseGeolocateCurrentLocation()
    override  func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - PlacesTableView Delegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // NSLog("--> In numberOfSectionsInTableView() for placesTableView")
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // NSLog("--> In tableView(numberOfRowsInSection) for placesTableView")
        return variables.places.count
        
    }//endTableView()
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PlaceTableViewCell"
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PlaceTableViewCell
        // Fetches the appropriate place for the data source layout.
        var place = Place()
        place = variables.places[indexPath.row]
        cell.placeNameLabel.text = String(place.getName())
        cell.placeCountryNameLabel.text = place.getCountry()
        cell.placeTemperatureLabel.text = String(place.getCrowdReport().getTemperature()) + " °C"
        if(place.getCrowdReport().getPool() == "1") {
            cell.placeCrowdLabel.text = String(place.getCrowdReport().getPool())+" person"
        } else {
            cell.placeCrowdLabel.text = String(place.getCrowdReport().getPool())+" people"
        }
        cell.placeWeatherIconImageView.image = place.getCrowdReport().getWeatherIcon()
        return cell
    }//endTableView()
    
    // Supporting editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Editing tableView \(editingStyle)")
        if editingStyle == .Delete {
            // Delete the row from the data source
            variables.places.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            variables.toolbox.savePlaces(variables.places)//saving user changes
            setEditing(false, animated: true) //exiting editing state
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }//endElseIf
    }//endTableView
    
    //Makes edit buttons appear next to each cell i.e. puts all table into editing mode
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        placesTableView.setEditing(editing, animated: true)        // Toggles the actual editing actions appearing on a table view
        NSLog("Editing table: \(editing)")
    }//endSetEditing()
    
    func loadSamplePlaces(){
        NSLog("--> In loadSamplePlaces()")
        let weatherIcon1 = UIImage(named: "sun_clear")
        let creport1 = CrowdReport()
        let place1 = Place()
        place1.setName("Lugano")
        place1.setCountry("Switzerland")
        creport1.setTemperature("4.4")
        creport1.setWeatherIcon(weatherIcon1!)
        creport1.setPool("7")
        place1.setCrowdReport(creport1)
        
        // let place1=Place(name:"Lugano", countryName: "Switzerland", temperature: 4.3, crowdNumber: 6, weatherIcon: weatherIcon1)
        
        // let place2=Place(name:"Athens", countryName: "Greece", temperature: 12.7, crowdNumber: 79, weatherIcon: weatherIcon
        let weatherIcon2 = UIImage(named: "rain4")
        let creport2 = CrowdReport()
        let place2 = Place()
        place2.setName("Athens")
        place2.setCountry("Greece")
        creport2.setTemperature("12.8")
        creport2.setWeatherIcon(weatherIcon2!)
        creport2.setPool("81")
        place2.setCrowdReport(creport2)
        
        //  let place3=Place(name:"Valsamata", countryName: "Greece", temperature: 7.2, crowdNumber: 2, weatherIcon: weatherIcon3)
        let weatherIcon3 = UIImage(named: "sun_cloud2")
        let creport3 = CrowdReport()
        let place3 = Place()
        place3.setName("Valsamata")
        place3.setCountry("Greece")
        creport3.setTemperature("7.3")
        creport3.setWeatherIcon(weatherIcon3!)
        creport3.setPool("1")
        place3.setCrowdReport(creport3)
        
        variables.places += [place1, place2, place3]
    }//endLoadSamplePlaces()
    
    // MARK: Search Place Textfield Delegates
    func dismissKeyboard(textField: UITextField){
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        print("TextField did begin editing method called")
        //showPlacesList()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("TextField did end editing method called")
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("TextField should begin editing method called")
        return true;
    }//endTextFieldShouldBeginEditing()
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        print("TextField should clear method called")
        variables.availablePlaces.removeAll()
        searchPlacesTableView.removeFromSuperview()
        hideSpinner()
        
        return true;
    }//endTextFieldShouldClear()
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("TextField should end editing method called")
        return true;
    }//endTextFieldShouldEndEditing()
    
    //MARK: Text Field Input for Searching New Places
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("While entering the characters this method gets called")
        NSLog("Characters typed: \(textField.text!.characters.count)")
        let charsTyped = textField.text!.characters.count
        
        if  charsTyped > 2 {
            showSpinner()
            variables.toolbox.searchForPlaces(textField.text!) { (placesFound) -> () in
                if placesFound.count > 0 { //if places found
                    variables.availablePlaces = placesFound
                    NSLog("Places Found table size: \(variables.availablePlaces.count)")
                    self.showAvailablePlacesTable()
                    self.hideSpinner()
                }
                self.hideSpinner()
            }//endSearchForPlacesClosure
        } else {
            variables.availablePlaces.removeAll()
            searchPlacesTableView.removeFromSuperview()
            hideSpinner()
        }//endIf
        return true;
    }//endTextField()
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        removeSubviews()
        variables.searchingForNewPlaces = false
        return true;
    }//textFieldShouldReturn()
    
    // MARK: Textfield Delegates <---
    func removeSubviews() { //removes all subviews that were dynamically added on top of existing subviews i.e. place search text field and searchPlacesTable
        for subview in self.view.subviews {
            if !(subview is UILayoutSupport || subview.isEqual(placesTableView)) == true {
                print(subview)
                subview.removeFromSuperview()
            }//endIf
        }//endFor
    }//endRemoveSubviews()
    
    func removeSubview(subView: UITableView){// removes subview passed as parameter that were dynamically added on top of existing suviews.
        for subview in self.view.subviews {
            if subview.isEqual(subView) == true {
                print(subview)
                subview.removeFromSuperview()
            }//endIf
        }//endFor
        
    }//endRemoveSubview
    
    //MARK: Searh Place Table View Controller HERE: Takes care on handling and presenting content fetched on the fly during place search
    class SearchPlacesTableViewController: UITableViewController {
        
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
            cell.textLabel!.text = "ok"
            
            
            //let cell = tableView.dequeueReusableCellWithIdentifier("PlaceTableViewCell", forIndexPath: indexPath) as! PlaceTableViewCell
            
            NSLog(" places length: " + String(variables.availablePlaces.count))
            
            NSLog("index path: "+String(indexPath.row))
            
            //let place = variables.places[indexPath.row]
            let place = variables.availablePlaces[indexPath.row]
            cell.textLabel!.text = String(place.getName()) + ", " + String(place.getCountry())
            
            return cell
        }
        
        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return variables.availablePlaces.count
        }
        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let newPlace = variables.availablePlaces[indexPath.row]
            var placeExists = false
            for var i = 0; i < variables.places.count; i++ {
                if (newPlace.getName() == variables.places[i].getName() && newPlace.getCountry() == variables.places[i].getCountry()) {
                    placeExists = true
                }
            }
            if(placeExists == true) {
                let alert = UIAlertView()
                alert.delegate = self
                alert.title = "Place already exists!"
                alert.message = "\(newPlace.getName()), \(newPlace.getCountry()) is already in your Places list."
                alert.addButtonWithTitle("OK")
                alert.show()
            } else {
                let newCrowdReport = CrowdReport()
                newCrowdReport.setTemperature("?")
                newPlace.setCrowdReport(newCrowdReport)
                variables.places.append(newPlace)
                variables.newPlaceAdded = true //raising flag for requesting immediate crowd weather updates for newly added place
            }//endElse()
            tableView.removeFromSuperview()//remove searchPlacesTableView from view after place is selected
            variables.searchPlacesTextField.removeFromSuperview()////remove searchPlacesTextField from view after place is selected
            variables.searchingForNewPlaces = false //indicate that search for new places is done
            variables.blurEffectView.removeFromSuperview()
        }//endTableView
        
        
    }//endSearchPlacesTableViewController.swift
    
    //MARK: -- Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "ShowDetail"){
            let placeDetailsViewController = segue.destinationViewController as! PlaceDetailsViewController
            // Get the cell that generated this segue.
            if let selectedPlaceCell = sender as? PlaceTableViewCell { //choosing which place to pass to PlaceDetailsViewController.swift
                let indexPath = placesTableView.indexPathForCell(selectedPlaceCell)!
                let selectedPlace = variables.places[indexPath.row]
                placeDetailsViewController.place = selectedPlace
                NSLog("Sending selectedPlace with prediction: \(selectedPlace.getCrowdPrediction().getTemperature())")
            }//endIf
        }//endIf
    }//endPrepareForSegue()
    
    func showSpinner(){//This creates and shows the
        if spinner.isAnimating() {
            hideSpinner()
        }
        let screen = UIScreen.mainScreen().bounds
        let screenWidth = screen.size.width
        let xpos = (screenWidth - 300)/2
        //let sampleTextField = UITextField(frame: CGRectMake(xpos, 100, 300, 40))
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        self.spinner.frame = CGRectMake(xpos+240, 100, 40.0, 40.0);
        // indicator.center = view.center
        self.view.addSubview(spinner)
        self.spinner.bringSubviewToFront(view)
        //UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.spinner.startAnimating()
    }//endShowSpinner()
    
    func hideSpinner() {
        self.spinner.stopAnimating()
        self.spinner.removeFromSuperview()
    }//endHideSpinner()
    
    func dimBackground () {
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            if(isVisible(variables.blurEffectView) == false){ //if dimming not already present
                self.view.backgroundColor = UIColor.clearColor()
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                variables.blurEffectView = UIVisualEffectView(effect: blurEffect)
                //always fill the view
                variables.blurEffectView.frame = self.view.bounds
                variables.blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                self.view.addSubview(variables.blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
            } else {
                self.view.backgroundColor = UIColor.blackColor()
            }
        }
    }//endDimBackGround()
    func isVisible(view: UIView) -> Bool {
        var viewVisible = false
        for subview in self.view.subviews {
            if subview.isEqual(view) == true {
                viewVisible = true
                //subview.removeFromSuperview()
            }//endIf
        }//endFor
        return viewVisible
    }
}//endPlacesViewController.swift