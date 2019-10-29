//
//  FoodTrackViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/29/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FoodTrackCell: UITableViewCell {
    @IBOutlet weak var lblFoodName: UILabel!
    @IBOutlet weak var lblCal: UILabel!
    @IBOutlet weak var lblServings: UILabel!
    @IBOutlet weak var lblTotalCals: UILabel!
}

class FoodTrackViewController: UIViewController,
    SimpleBarChartDataSource,
    SimpleBarChartDelegate,
    UIActionSheetDelegate,
    UINavigationBarDelegate,
    UITableViewDataSource,
UITableViewDelegate {
    //MARK: - Properties
    
    @IBOutlet weak var lblTotalCal: UILabel!
    @IBOutlet weak var lblGoalCal: UILabel!
    @IBOutlet weak var lblAverageCal: UILabel!
    @IBOutlet weak var simplechart: SimpleBarChart!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationbar: UINavigationBar!
    @IBOutlet weak var btn1Wk: UIButton!
    @IBOutlet weak var btn1M: UIButton!
    @IBOutlet weak var btn3M: UIButton!
    @IBOutlet weak var btn6M: UIButton!
    @IBOutlet weak var btn1Yr: UIButton!
    
    private var values: [CGFloat] = []
    private var x_values: [String] = []
    
    private var barColors: [UIColor]!
    private var currentBarColor: Int = 0
    private var chart: SimpleBarChart!
    private var thresholdValue: Bool = false
    private var foodObjectArray: [Food] = []
    private var servingsArray: [UserFoodRecords] = []
    private var timeFrames: Int = 0
    private var finalFoodArray: [[Food]] = []
    private var finalServingsArray: [[UserFoodRecords]] = []
    private var finalSectionNameArray: [String] = []
    
    private var chartBorderColor = UIColor(red: 0.74, green: 0.76, blue: 0.78, alpha: 1)
    
    private var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    }
    
    //MARK: - Methods
    
    override func loadView() {
        super.loadView()
        
        //    _values                            = @[@30, @45, @44, @60, @95, @2, @8, @9];
        //    _newvalues = [NSMutableArray arrayWithObjects:@"Sunday",@"Monday",@"Monday",@"Monday",@"Monday",@"Monday",@"Monday",@"Monday",nil];
        barColors = [
            UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1),
            UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1),
            UIColor(red: 0.61, green: 0.35, blue: 0.71, alpha: 1),
            UIColor(red: 0.90, green: 0.49, blue: 0.13, alpha: 1)
        ]
        currentBarColor = 0
        
        //    CGRect chartFrame                = CGRectMake(0.0,
        //                                                 0.0,
        //                                                 300.0,
        //                                                 300.0);
        
        chart = SimpleBarChart(frame: simplechart.frame)
        
        chart.delegate = self
        chart.dataSource = self
        chart.barShadowOffset = CGSize(width: 2, height: 1)
        chart.animationDuration = 0
        chart.barShadowColor = UIColor.gray
        chart.barShadowAlpha = 0.1
        chart.barShadowRadius = 1.0
        chart.barWidth = 28.0
        chart.chartBorderColor = chartBorderColor
        chart.xLabelType = SimpleBarChartXLabelTypeAngled
        chart.incrementValue = 400
        chart.barTextType = SimpleBarChartBarTextTypeRoof
        chart.barTextColor = UIColor.black
        chart.gridColor = UIColor.gray
        chart.yLabelColor = UIColor(red: 0.74, green: 0.76, blue: 0.78, alpha: 1)
        chart.xLabelColor = UIColor(red: 0.74, green: 0.76, blue: 0.78, alpha: 1)
        chart.barTextColor = UIColor(red: 0.50, green: 0.55, blue: 0.55, alpha: 1)
        
        view.addSubview(chart)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    private func changeClicked() {
        if chart.xLabelType == SimpleBarChartXLabelTypeVerticle {
            chart.xLabelType = SimpleBarChartXLabelTypeHorizontal
        } else {
            chart.xLabelType = SimpleBarChartXLabelTypeVerticle
        }
        
        currentBarColor = (currentBarColor + 1) % barColors.count
        chart.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationbar.delegate = self
        title = "Food Tracker"
        
        //self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey.png"]];
        AppDelegate.setCornerRadiusofUIButton(btn1Wk)
        AppDelegate.setCornerRadiusofUIButton(btn1M)
        AppDelegate.setCornerRadiusofUIButton(btn3M)
        AppDelegate.setCornerRadiusofUIButton(btn6M)
        AppDelegate.setCornerRadiusofUIButton(btn1Yr)
        
        //    [_btn1Wk sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        btn1Wk.backgroundColor = UIColor(red: 0.74, green: 0.76, blue: 0.78, alpha: 0.5)
        timeFrames = 7
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.5 //seconds
        tableView.addGestureRecognizer(lpgr)
        
        btn1Wk.setTitleColor(.white, for: .highlighted)
        btn1M.setTitleColor(.white, for: .highlighted)
        btn3M.setTitleColor(.white, for: .highlighted)
        btn6M.setTitleColor(.white, for: .highlighted)
        btn1Yr.setTitleColor(.white, for: .highlighted)
        
        // Set Background Color of UIStatusBar
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarHeight))
        statusBarView.backgroundColor  = UIColor(red: 0.32, green: 0.66, blue: 0.82, alpha: 1)
        view.addSubview(statusBarView)
        
        let insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        if insets.top > 0 {
            // We're running on an iPhone with a notch.
            
            // Set Background Color of UIStatusBar
            let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarHeight))
            statusBarView.backgroundColor = UIColor(red: 0.32, green: 0.66, blue: 0.82, alpha: 1)
            view.addSubview(statusBarView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buildView()
    }
    
    private func buildView() {
        AppDelegate.showLoader()
        
        setData()
        
        chart.reloadData()
        tableView.reloadData()
        AppDelegate.hideLoader()
    }
    
    private func getNumberOfDays(_ frame: Int) -> Int {
        //    NSDate *today = [[NSDate alloc] init];
        //    NSLog(@"%@", today);
        //    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        //    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        //
        //    [offsetComponents setMonth:-frame]; // note that I'm setting it to -1
        //    NSDate *endOfWorldWar3 = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
        //    NSLog(@"%@", endOfWorldWar3);
        //
        //
        //
        //
        //    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        //    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
        //                                                        fromDate:[NSDate date]
        //                                                          toDate:endOfWorldWar3
        //                                                         options:0];
        //
        //    NSLog(@"Total Number Of Days : %ld", [components day]);
        //
        //    return labs([components day]) ;
        
        var totalDays = getDaysInCurrentMonth()
        
        for iCount in 1 ..< max(1, frame) {
            //        NSCalendar *calendar = [NSCalendar currentCalendar];
            //        NSDateComponents *comps = [NSDateComponents new];
            //        comps.month = -1;
            //        comps.day   = -1;
            //        NSDate *date = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
            //        NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date]; // Get necessary date components
            //        NSLog(@"Previous month: %d",[components month]);
            //        NSLog(@"Previous day  : %d",[components day]);
            
            //        NSDate *today = [NSDate date];
            //        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            //
            //        NSDateComponents *components = [gregorian components:(NSCalendarUnitEra | NSCalendarUnitYear| NSCalendarUnitMonth) fromDate:today];
            //        components.day = 1;
            //        components.month = -1 * iCount ;
            //
            //        NSDate *dayOneInCurrentMonth = [gregorian dateFromComponents:components];
            
            let today = Date()
            let gregorian = Calendar(identifier: .gregorian)
            var offsetComponents = DateComponents()
            offsetComponents.month = -iCount
            let dateStr = gregorian.date(byAdding: offsetComponents, to: today) ?? Date(timeIntervalSince1970: 0)
            
            let range = gregorian.range(of: .day, in: .month, for: dateStr)
            let numberOfDaysInMonth = range?.count ?? 0
            print(numberOfDaysInMonth)
            
            //        NSCalendar *calendar = [NSCalendar currentCalendar];
            //        NSDateComponents *components = [[NSDateComponents alloc] init];
            //
            //        // Set your year and month here
            //        [components setMonth:-1 * iCount];
            //
            //        NSDate *date = [calendar dateFromComponents:components];
            //        NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
            
            totalDays = totalDays + numberOfDaysInMonth
        }
        
        return totalDays
    }
    
    private func getDaysInCurrentMonth() -> Int {
        let date_Format = DateFormatter()
        date_Format.dateFormat = "dd"
        let strng = date_Format.string(from: Date())
        return Int(strng) ?? 0
    }
    
    private func getDaysInPreviousMonth(_ month: Int) -> Int {
        //    NSCalendar *calendar = [NSCalendar currentCalendar];
        //    NSDateComponents *components = [[NSDateComponents alloc] init];
        //
        //    // Set your year and month here
        //    [components setMonth:-month ];
        //
        //    NSDate *date = [calendar dateFromComponents:components];
        //    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
        //
        //    NSLog(@"%d", (int)range.length);
        
        //    NSCalendar *calendar = [NSCalendar currentCalendar];
        //    NSDateComponents *comps = [NSDateComponents new];
        //    comps.month = -month;
        //
        //    NSDate *_date = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
        //    NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:_date]; // Get necessary date components
        //    NSLog(@"Previous month: %ld",(long)[components month]);
        //    NSLog(@"Previous day  : %ld",(long)[components day]);
        //
        //
        //    components = [[NSDateComponents alloc] init] ;
        //
        //
        //    NSDate *date = [NSDate dateWithNaturalLanguageString:@"January"];
        //    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
        //
        //    NSLog(@"%d", (int)range.length);
        //
        //    return range.length ;
        
        let calendar = Calendar.current
        let date = Date(timeIntervalSinceNow: -(Constants.secondsPerDay * 31 * Double(month)))
        let range = calendar.range(of: .day, in: .month, for: date)
        let numberOfDaysInMonth = range?.count ?? 0
        return numberOfDaysInMonth
    }
    
    private func setData() {
        let recommended = UserDefaults.standard.string(forKey: "recommended-name").flatMap { Float($0) } ?? 0
        lblGoalCal.text = String(format: "Goal\n%ld Cal", Int(recommended))
        lblTotalCal.text = "Today\n0 Cal"
        x_values.removeAll(keepingCapacity: true)
        values.removeAll(keepingCapacity: true)
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy-EEEE"
        
        var totalNumberOfDays = 0
        
        switch timeFrames {
        case 7:
            for iCount in 0 ..< timeFrames {
                let dateStr = dateFormat.string(from: Date(timeIntervalSinceNow: -(Constants.secondsPerDay * Double(iCount))))
                let arr = dateStr.components(separatedBy: "-")
                
                if arr.count > 1 {
                    x_values.append(arr[1])
                }
            }
            
            totalNumberOfDays = 7
            
        case 4:
            for iCount in 0 ..< timeFrames {
                x_values.append(String(format: "Week %ld", (timeFrames - iCount)))
            }
            totalNumberOfDays = 31
            //totalNumberOfDays = [self GetDaysInCurrentMonth];
            
        case 3:
            //            for (int iCount = 0; iCount< timeFrames; iCount ++)
            //            {
            //                [x_values addObject:[NSString stringWithFormat:@"Month %ld",(timeFrames - iCount)]];
            //            }
            
            totalNumberOfDays = getNumberOfDays(timeFrames)
            
        case 6:
            //            for (int iCount = 0; iCount< timeFrames; iCount ++)
            //            {
            //                [x_values addObject:[NSString stringWithFormat:@"Month %ld",(timeFrames - iCount)]];
            //            }
            
            totalNumberOfDays = getNumberOfDays(timeFrames)
            
        case 12:
            //            for (int iCount = 0; iCount< timeFrames; iCount ++)
            //            {
            //                [x_values addObject:[NSString stringWithFormat:@"Month %ld",(timeFrames - iCount)]];
            //            }
            
            totalNumberOfDays = getNumberOfDays(timeFrames)
            
        default:
            break
        }
        
        print("xvalues:", x_values)
        finalFoodArray = []
        finalSectionNameArray = []
        finalServingsArray = []
        foodObjectArray = []
        servingsArray = []
        
        var grossCal: Int = 0
        var totalCal: Int = 0
        let frameWindow: Int = totalNumberOfDays / timeFrames
        var valueStoredCounter: Int = 0
        var matchMonth = ""
        var testMonth = ""
        let daysInCurrentMonth = getDaysInCurrentMonth()
        print(daysInCurrentMonth)
        
        for iCount in 0 ..< max(0, totalNumberOfDays) {
            let format = DateFormatter()
            format.dateFormat = "MM/dd/yyyy-EEEE-MMMM-dd"
            
            let dateStr = format.string(from: Date(timeIntervalSinceNow: -(Constants.secondsPerDay * Double(iCount))))
            let arr = dateStr.components(separatedBy: "-")
            if testMonth.isEmpty {
                testMonth = arr[2]
            }
            
            //        [x_values addObject:arr[1]];
            
            let food_record: [UserFoodRecords] = getFoodItem(arr[0])
            var todaysItems = [Food]()
            
            for record in food_record {
                let foodSet = record.foodIntake
                let items = (foodSet?.allObjects as? [Food]) ?? []
                
                for food in items {
                    totalCal = totalCal + ((food.calories?.intValue ?? 0) * (record.servings?.intValue ?? 0))
                }
                
                servingsArray.append(record)
                todaysItems.append(contentsOf: items)
            }
            
            if iCount == 0 {
                lblTotalCal.text = String(format: "Today\n%ld Cal", totalCal)
            }
            
            grossCal = grossCal + totalCal
            foodObjectArray.append(contentsOf: todaysItems)
            
            if timeFrames == 7 {
                finalSectionNameArray.append(arr[0])
                finalFoodArray.append(foodObjectArray)
                finalServingsArray.append(servingsArray)
                foodObjectArray = []
                servingsArray = []
                values.append(CGFloat(totalCal))
                totalCal = 0
            } else if timeFrames == 4 {
                finalSectionNameArray.append(arr[0])
                finalFoodArray.append(foodObjectArray)
                finalServingsArray.append(servingsArray)
                foodObjectArray = []
                servingsArray = []
                
                if ((iCount+1) % frameWindow == 0 && valueStoredCounter < timeFrames - 1) || iCount == (totalNumberOfDays - 1) {
                    valueStoredCounter += 1
                    values.append(CGFloat(totalCal))
                    totalCal = 0
                }
            } else {
                //            if (![matchMonth isEqualToString:arr[2]] && finalSectionNameArray.count < timeFrames)
                //            {
                //                matchMonth = arr[2] ;
                //                [finalSectionNameArray addObject:arr[2]];
                //                if (timeFrames != 4 || timeFrames != 7)
                //                {
                //                    [x_values addObject:arr[2]];
                //                }
                //            }
                
                //            if (iCount + 1 == daysInCurrentMonth)
                
                if (Int(arr[3]) ?? 0) == 1 && matchMonth != arr[2] {
                    matchMonth = arr[2]
                    finalSectionNameArray.append(arr[2])
                    if timeFrames != 4 || timeFrames != 7 {
                        x_values.append(arr[2])
                    }
                    finalFoodArray.append(foodObjectArray)
                    finalServingsArray.append(servingsArray)
                    foodObjectArray = []
                    servingsArray = []
                    values.append(CGFloat(totalCal))
                    totalCal = 0
                    //                valueStoredCounter++ ;
                    //                daysInCurrentMonth = daysInCurrentMonth + [self GetDaysInPreviousMonth:valueStoredCounter];
                }
                //            else if (![testMonth isEqualToString:arr[2]])
                //            {
                //                testMonth = arr[2];
                //                [finalSectionNameArray addObject:testMonth];
                //                if (timeFrames != 4 || timeFrames != 7)
                //                {
                //                    [x_values addObject:arr[2]];
                //                }
                //                [finalFoodArray addObject:foodObjectArray];
                //                [finalServingsArray addObject:servingsArray];
                //                foodObjectArray = [[NSMutableArray alloc] init];
                //                servingsArray= [[NSMutableArray alloc] init];
                //                [_values addObject:[NSNumber numberWithInteger:totalCal]];
                //                totalCal = 0 ;
                //            }
                
                //            if (((iCount+1) % frameWindow == 0 && valueStoredCounter < timeFrames - 1) || iCount == (totalNumberOfDays -1))
                //            {
                ////                [finalSectionNameArray addObject:arr[2]];
                //                [finalFoodArray addObject:foodObjectArray];
                //                [finalServingsArray addObject:servingsArray];
                //                foodObjectArray = [[NSMutableArray alloc] init];
                //                servingsArray= [[NSMutableArray alloc] init];
                //            }
            }
            
            
            //        if (((iCount+1) % frameWindow == 0 && valueStoredCounter < timeFrames - 1) || iCount == (totalNumberOfDays -1))
            //        {
            //            valueStoredCounter ++ ;
            //            [_values addObject:[NSNumber numberWithInteger:totalCal]];
            //            totalCal = 0 ;
            //        }
        }
        
        lblAverageCal.text = String(format: "Average\n%ld Cal", grossCal / totalNumberOfDays)
        
        x_values.reverse()
        values.reverse()
    }
    
    //MARK: - SimpleBarChartDataSource
    
    func numberOfBars(in barChart: SimpleBarChart!) -> UInt {
        return UInt(values.count)
    }
    
    func barChart(_ barChart: SimpleBarChart!, valueForBarAt index: UInt) -> CGFloat {
        return values[Int(index)]
    }
    
    func barChart(_ barChart: SimpleBarChart!, textForBarAt index: UInt) -> String! {
        return String(format: "%f", values[Int(index)])
    }
    
    func barChart(_ barChart: SimpleBarChart!, xLabelForBarAt index: UInt) -> String! {
        return x_values[Int(index)]
    }
    
    func barChart(_ barChart: SimpleBarChart!, colorForBarAt index: UInt) -> UIColor! {
        let recommended = UserDefaults.standard.string(forKey: "recommended-name").flatMap { Float($0) } ?? 0
        
        switch timeFrames {
        case 7:
            if Int(values[Int(index)]) < Int(recommended) {
                currentBarColor = 1
            } else {
                currentBarColor = 0
            }
            
        default:
            let averageCal = lblAverageCal.text.flatMap { Float($0) } ?? 0
            if Int(averageCal) < Int(recommended) {
                currentBarColor = 1
            } else {
                currentBarColor = 0
            }
        }
        
        return barColors[currentBarColor]
    }
    
    private func getFoodItem(_ dateStr: String) -> [UserFoodRecords] {
        guard let context = managedObjectContext else {
            assertionFailure()
            return []
        }
        
        let request = UserFoodRecords.fetchRequest() as NSFetchRequest<UserFoodRecords>
        request.predicate = NSPredicate(format: "date LIKE[c] %@", dateStr)
        
        return (try? context.fetch(request)) ?? []
    }
    
    //MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return finalSectionNameArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalFoodArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FoodTrackCell
        cell.accessoryView = nil
        
        let foodArr = finalFoodArray[indexPath.section]
        let ServingsArr = finalServingsArray[indexPath.section]
        let food = foodArr[indexPath.row]
        cell.lblFoodName.text = food.name
        let rec = ServingsArr[indexPath.row]
        let totalCals = rec.servings?.intValue ?? 0
        cell.lblCal.text = String(format: "%ld Cal", food.calories?.intValue ?? 0)
        cell.lblTotalCals.text = String(format: "Total Calories: %ld Cals", (food.calories?.intValue ?? 0) * totalCals)
        cell.lblServings.text = String(format: "Total Servings: %ld", rec.servings?.intValue ?? 0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return finalSectionNameArray[section]
    }
    
    //MARK: - Methods
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: tableView)
        
        guard let indexPath = tableView.indexPathForRow(at: p) else {
            print("long press on table view but not on a row")
            return
        }
        
        if gestureRecognizer.state == .began {
            let actionSheet = UIAlertController(title: "Befit", message: "What would you like to do?", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            
            actionSheet.addAction(UIAlertAction(title: "Edit Servings", style: .destructive) { [weak self] _ in
                let alert = UIAlertController(title: "Befit", message: "Please enter servings", preferredStyle: .alert)
                alert.addTextField(configurationHandler: {
                    $0.placeholder = NSLocalizedString("Qty", comment: "Qty")
                })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .default) { [weak alert] _ in
                    alert?.dismiss(animated: true)
                })
                
                alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
                    let txtServings = alert.textFields?.first
                    txtServings?.keyboardType = .numberPad
                    
                    guard let text = txtServings?.text, !text.isEmpty else {
                        let alertController = UIAlertController(title: "Error", message: "Please enter servings", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self?.present(alertController, animated: true)
                        
                        //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter servings" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] ;
                        //[alert show];
                        return
                    }
                    
                    guard let me = self, let context = me.managedObjectContext else {
                        return
                    }
                    
                    let foodArr = me.finalServingsArray[indexPath.section]
                    let record = foodArr[indexPath.row]
                    record.servings = NSNumber(value: Int(text) ?? 0)
                    
                    do {
                        try context.save()
                    } catch let error {
                        print("error while saving:", error.localizedDescription)
                        return
                    }
                    
                    let alertController = UIAlertController(title: "Success", message: "Food edited successfully.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    
                    me.present(alertController, animated: true)
                    //[[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food edited successfully." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
                    me.buildView()
                })
                
                alert.view.tag = 100
                self?.present(alert, animated: true)
                
                //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Befit" message:@"Please enter servings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
                // [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                //alert.tag = 100;
                //[alert show];
            })
            
            actionSheet.addAction(UIAlertAction(title: "Delete Food", style: .default) { [weak self] _ in
                guard let me = self, let context = me.managedObjectContext else {
                    return
                }
                
                let foodArr = me.finalServingsArray[indexPath.section]
                let record = foodArr[indexPath.row]
                context.delete(record)
                
                do {
                    try context.save()
                } catch let error {
                    print("error while saving:", error.localizedDescription)
                    return
                }
                
                let alertController = UIAlertController(title: "Success", message: "Food deleted successfully.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                me.present(alertController, animated: true)
                me.buildView()
            })
            // Present action sheet.
            
            actionSheet.view.tag = 1;
            
            present(actionSheet, animated: true)
            // UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Befit" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle: @"Edit Servings"otherButtonTitles:@"Delete Food", nil];
            // popup.tag = 1;
            // [popup showInView:self.view];
        } else {
            print("gestureRecognizer.state = ", gestureRecognizer.state)
        }
    }
    
    //- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
    //{
    //
    //    switch (buttonIndex)
    //    {
    //        case 0:
    //        {
    //
    //
    //        }
    //            break;
    //        case 1:
    //        {
    //
    //            }
    //
    //        }
    //            break;
    //        default:
    //            break;
    //    }
    //}
    //- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    //{
    //    if (buttonIndex == 1)
    //    {
    //
    //    }
    //}
    
    @IBAction func TimeFrameValueChanged(_ sender: AnyObject) {
        btn1Wk.backgroundColor = .clear
        btn1M.backgroundColor = .clear
        btn3M.backgroundColor = .clear
        btn6M.backgroundColor = .clear
        btn1Yr.backgroundColor = .clear
        
        guard let btn = sender as? UIButton else {
            return
        }
        
        btn.backgroundColor = UIColor(red: 0.74, green: 0.76, blue: 0.78, alpha: 0.5)
        
        switch btn.tag {
        case 1:
            timeFrames = 7
        case 2:
            timeFrames = 4
        case 3:
            timeFrames = 3
        case 4:
            timeFrames = 6
        case 5:
            timeFrames = 12
        default:
            break
        }
        
        buildView()
    }
}
