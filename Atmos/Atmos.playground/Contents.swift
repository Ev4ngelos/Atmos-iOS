//: Playground - noun: a place where people can play
/*
import UIKit
import XCPlayground
var str = "Hello, playground"

XCPSetExecutionShouldContinueIndefinitely()

class RemoteAPI {
    func getData(completionHandler: ((NSArray!, NSError!) -> Void)!) -> Void {
        let url: NSURL = NSURL(string: "http://itunes.apple.com/search?term=Turistforeningen&media=software")!
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                return completionHandler(nil, error)
            }
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    print(jsonResult)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}

var api = RemoteAPI()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    var items: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        self.tableView = UITableView(frame:self.view!.frame)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view?.addSubview(self.tableView)
        
        api.getData({data, error -> Void in
            if (data != nil) {
                self.items = NSMutableArray(array: data)
                self.tableView!.reloadData()
                self.view
            } else {
                print("api.getData failed")
                print(error)
            }
        })
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        if let navn = self.items[indexPath.row]["trackName"] as? NSString {
            cell.textLabel!.text = navn as String
        } else {
            cell.textLabel!.text = "No Name"
        }
        
        if let desc = self.items[indexPath.row]["description"] as? NSString {
            cell.detailTextLabel!.text = desc as String
        }
        
        return cell
    }
}

ViewController().view
*/
import UIKit

NSLog("Hello")

let currentDate = NSDate()
let dateFormatter = NSDateFormatter()
//dateFormatter.locale = NSLocale.currentLocale()
dateFormatter.locale = NSLocale(localeIdentifier: "el_GR")
dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
var convertedDate = dateFormatter.stringFromDate(currentDate)


NSLog(String(currentDate))
NSLog(convertedDate)
/*
let localTimestampFormatter: NSDateFormatter = NSDateFormatter()
//        localTimestampFormatter.timeZone = NSTimeZone(name: getLocalTimeZone())
//localTimestampFormatter.timeZone = NSTimeZone(name: "Europe/Athens")
localTimestampFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
localTimestampFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//        let localDate: NSDate = localTimestampFormatter.dateFromString(getLocalTimestamp())!
let localDate: NSDate = localTimestampFormatter.dateFromString("2016-01-30 19:10:55 GMT+2")!
NSLog("***Local (Lugano) time: \(localDate)")

let serverTimestampFormatter: NSDateFormatter = NSDateFormatter()
serverTimestampFormatter.timeZone = NSTimeZone(name: "US/Pacific")
serverTimestampFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
let serverDate: NSDate = serverTimestampFormatter.dateFromString(localTimestampFormatter.stringFromDate(localDate))!
NSLog("***Server (Seattle) time: \(serverDate)")

*/
NSLog("______________________________________________")


var now = NSDate()
let nowComponents = NSDateComponents()
let calendar = NSCalendar.currentCalendar()
nowComponents.year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: now)
nowComponents.month = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: now)
nowComponents.day = NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: now)
nowComponents.hour = NSCalendar.currentCalendar().component(NSCalendarUnit.Hour, fromDate: now)
nowComponents.minute = NSCalendar.currentCalendar().component(NSCalendarUnit.Minute, fromDate: now)
nowComponents.second = NSCalendar.currentCalendar().component(NSCalendarUnit.Second, fromDate: now)
nowComponents.timeZone = NSTimeZone(abbreviation: "GMT")
now = calendar.dateFromComponents(nowComponents)!
NSLog("\(now)")


let localTimestampFormatter: NSDateFormatter = NSDateFormatter()
//        localTimestampFormatter.timeZone = NSTimeZone(name: getLocalTimeZone())
//localTimestampFormatter.timeZone = NSTimeZone(name: "Europe/Athens")
localTimestampFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
localTimestampFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//        let localDate: NSDate = localTimestampFormatter.dateFromString(getLocalTimestamp())!
let localDate: NSDate = localTimestampFormatter.dateFromString("2016-01-30 19:10:55 GMT+2")!
NSLog("***Local (Lugano) time: \(localDate)")

let serverTimestampFormatter: NSDateFormatter = NSDateFormatter()
serverTimestampFormatter.timeZone = NSTimeZone(name: "US/Pacific")
serverTimestampFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
let serverDate: NSDate = serverTimestampFormatter.dateFromString(localTimestampFormatter.stringFromDate(localDate))!
NSLog("***Server (Seattle) time: \(serverDate)")

