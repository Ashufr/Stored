import UIKit


// MARK: - ViewController
class ViewController: UIViewController {
    
    var calendarView: UICalendarView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instantiate UICalendarView
        calendarView = UICalendarView(frame: CGRect(x: 0, y: 200, width: view.bounds.width, height: 150))
        

        
        // Add calendar to the view hierarchy
        if let calendarView = calendarView {
            view.addSubview(calendarView)
        }
        
        let headerView = calendarView?.subviews[0].subviews[0]
        let weekdayView = calendarView?.subviews[0].subviews[1]
        let collectionView = calendarView?.subviews[0].subviews[2] as! UICollectionView
        
    }
    
   
}
