//
//  HomeViewController.swift
//  coinb
//
//  Created by Hieu Nguyen on 3/13/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import UIKit
import MBProgressHUD
import Charts

class HomeViewController: UIViewController {

    @IBOutlet weak var priceLabel: UITextView!
    @IBOutlet weak var priceSublabel: UITextView!
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var weekModeBtn: UIButton!
    @IBOutlet weak var monthModeBtn: UIButton!
    @IBOutlet weak var yearModeBtn: UIButton!
    @IBOutlet weak var allModeBtn: UIButton!
    var modeButtons = [UIButton]()
    
    @IBOutlet weak var divider1: UIView!
    @IBOutlet weak var divider2: UIView!
    @IBOutlet weak var divider3: UIView!
    
    var currency = "USD"
    
    let backgroundQueue = DispatchQueue(label: "com.hugohn.coinb",
                                        qos: .background,
                                        target: nil)
    
    private var spinner: MBProgressHUD?
    private let formatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        NotificationCenter.default.addObserver(self, selector: #selector(onNewHomeData(notification:)), name: NSNotification.Name(rawValue: Constants.kNewHomeData), object: nil)
        
        showSpinner()
        backgroundQueue.async {
            // Background thread
            ApiClient.sharedInstance.getSpotPrice(withCurrency: self.currency) { (price: String?) in
                DispatchQueue.main.async {
                    // UI Updates
                    self.hideSpinner()
                    guard price != nil else { return }
                    if let priceDouble = Double(price!) {
                        let priceNumber = NSNumber(value: priceDouble)
                        self.priceLabel.text = Constants.currencyFormatter.string(from: priceNumber)
                    }
                }
            }
            
            ApiClient.sharedInstance.getHistoricalPrice(withRouter: CoindeskRouter.Week(self.currency))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupViews() {
        view.backgroundColor = Constants.primaryColor
        divider1.backgroundColor = Constants.grayColor
        divider2.backgroundColor = Constants.grayColor
        divider3.backgroundColor = Constants.grayColor
        
        modeButtons.append(weekModeBtn)
        modeButtons.append(monthModeBtn)
        modeButtons.append(yearModeBtn)
        modeButtons.append(allModeBtn)
        
        for (index, button) in modeButtons.enumerated() {
            button.setTitleColor(Constants.grayColor, for: UIControlState.normal)
            button.setTitleColor(UIColor.white, for: UIControlState.selected)
            button.tag = index
            button.addTarget(self, action: #selector(onModeBtnTapped(sender:)), for: UIControlEvents.touchUpInside)
        }
        setButtonSelected(index: 0)
        
        priceLabel.backgroundColor = UIColor.clear
        priceLabel.textColor = UIColor.white
        priceSublabel.backgroundColor = UIColor.clear
        priceSublabel.textColor = UIColor.white
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = false
        chartView.highlightPerDragEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        
        chartView.backgroundColor = UIColor.clear
        chartView.legend.enabled = false
        chartView.tintColor = UIColor.white
    }
    
    func onModeBtnTapped(sender: UIButton) {
        setButtonSelected(index: sender.tag)
        switch sender.tag {
        case 0:
            ApiClient.sharedInstance.getHistoricalPrice(withRouter: CoindeskRouter.Week(self.currency))
            break
        case 1:
            ApiClient.sharedInstance.getHistoricalPrice(withRouter: CoindeskRouter.Month(self.currency))
            break
        case 2:
            ApiClient.sharedInstance.getHistoricalPrice(withRouter: CoindeskRouter.Year(self.currency))
            break
        case 3:
            ApiClient.sharedInstance.getHistoricalPrice(withRouter: CoindeskRouter.All(self.currency))
            break
        default:
            break
        }
    }
    
    func setButtonSelected(index: Int) {
        for (i, button) in modeButtons.enumerated() {
            if index == i {
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
                button.setTitleColor(Constants.grayColor, for: UIControlState.selected)
            } else {
                button.setTitleColor(Constants.grayColor, for: UIControlState.normal)
                button.setTitleColor(UIColor.white, for: UIControlState.selected)
            }
        }
    }
    
    func showSpinner() {
        spinner = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinner?.color = UIColor.clear
    }
    
    func hideSpinner() {
        self.spinner?.hide(animated: true)
    }
    
    func onNewHomeData(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let beginningDate = userInfo["beginningDate"] as? Date,
            let endDate = userInfo["endDate"] as? Date else { return }
        
        updateChartWithData(beginningDate: beginningDate, endDate: endDate)
    }
    
    func updateChartWithData(beginningDate: Date?, endDate: Date?) {
        guard beginningDate != nil, endDate != nil else { return }
        var dataEntries: [ChartDataEntry] = []
        let pricePoints = PricePoint.getPricePoints(beginningDate: beginningDate, endDate: endDate)
        for i in 0..<pricePoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: pricePoints[i].price)
            debugPrint("[CHART] date = \(pricePoints[i].date); price = \(pricePoints[i].price)")
            dataEntries.append(dataEntry)
        }
        debugPrint("pricePoints.count = \(pricePoints.count)")
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Price")
//        chartDataSet.colors = ChartColorTemplates.vordiplom()
        chartDataSet.drawCubicEnabled = true
        let chartData = LineChartData(dataSet: chartDataSet)
        
        DispatchQueue.main.async {
            self.chartView.data = chartData
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

