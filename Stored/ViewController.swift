import UIKit
import FSCalendar

class ViewController : UIViewController, FSCalendarDelegate, FSCalendarDataSource{
    
    @IBOutlet var calender: FSCalendar!
    var data = UserData.getInstance().users[0].streak
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calender.dataSource = self
        calender.delegate = self
    }
    




    
}
