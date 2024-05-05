import UIKit
import FSCalendar

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let calendarWidth: CGFloat = 200
        let calendarHeight: CGFloat = 150
        let calendarX = (view.frame.width - calendarWidth) / 2
        calendar = FSCalendar(frame: CGRect(x: calendarX, y: 100, width: calendarWidth, height: calendarHeight))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        
        // Set appearance
        calendar.backgroundColor = .white
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 15)
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 12)
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 12)
        calendar.appearance.headerTitleColor = UIColor.black
        calendar.appearance.weekdayTextColor = UIColor.darkGray
        calendar.appearance.titleDefaultColor = UIColor.black
        //        calendar.appearance.titleSelectionColor = UIColor.white
        calendar.appearance.selectionColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.5)
        calendar.appearance.todayColor = UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0)
        calendar.appearance.borderRadius = 1 // Set this to 0 to remove rounded corners
        
        // Set calendar scope
        calendar.scope = .month
    }
    
    
    // MARK: - FSCalendarDelegate
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // Handle date selection
        print("Selected date: \(date)")
    }
    
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        let firstDayOfMonth = calendar.currentPage.startOfMonth()
        let lastDayOfMonth = calendar.currentPage.endOfMonth()
            
        if date < firstDayOfMonth || date > lastDayOfMonth {
            cell.titleLabel.textColor = .red
        }else{
            cell.titleLabel.textColor = .blue
        }
    }
    
    
}

extension Date {
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        let components = DateComponents(month: 1, day: -1)
        return calendar.date(byAdding: components, to: self.startOfMonth())!
    }
}
