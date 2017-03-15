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

    @IBOutlet weak var priceBtn: UIButton!
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
    var spinner: MBProgressHUD?
    let backgroundQueue = DispatchQueue(label: "com.hugohn.coinb",
                                        qos: .background,
                                        target: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        NotificationCenter.default.addObserver(self, selector: #selector(onNewSpotData(notification:)), name: NSNotification.Name(rawValue: Constants.kNewSpotData), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNewHomeData(notification:)), name: NSNotification.Name(rawValue: Constants.kNewHomeData), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoadingHome(notification:)), name: NSNotification.Name(rawValue: Constants.kLoadingHomeData), object: nil)
        
        backgroundQueue.async {
            // Background thread
            ApiClient.sharedInstance.loadSpotPrice(withCurrency: self.currency)
            ApiClient.sharedInstance.loadHistoricalPrice(withRouter: CoindeskRouter.Year(self.currency))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        modeButtons.removeAll()
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
        setButtonSelected(index: 2)
        
        priceBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        priceBtn.setTitleColor(Constants.grayColor, for: UIControlState.selected)
        priceBtn.addTarget(self, action: #selector(onPriceBtnTapped), for: UIControlEvents.touchUpInside)
        
        priceSublabel.backgroundColor = UIColor.clear
        priceSublabel.textColor = UIColor.white
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = false
        chartView.highlightPerDragEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawBordersEnabled = false
        
        chartView.backgroundColor = UIColor.clear
        chartView.legend.enabled = false
        chartView.tintColor = UIColor.white
        
        chartView.rightAxis.enabled = false
        
        
        let xAxis = chartView.xAxis
        xAxis.drawAxisLineEnabled = false
//        xAxis.setLabelCount(3, force: true)
        xAxis.labelCount = 4
        xAxis.labelFont = UIFont(name: "GillSans", size: 12.0)!
        xAxis.labelTextColor = UIColor.white
        xAxis.labelPosition = XAxis.LabelPosition.top
        xAxis.drawGridLinesEnabled = false
        
        let leftAxis = chartView.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.spaceTop = 0.1
        leftAxis.labelCount = 4
        leftAxis.labelFont = UIFont(name: "GillSans", size: 12.0)!
        leftAxis.labelTextColor = UIColor.white
        leftAxis.drawGridLinesEnabled = true
        leftAxis.labelPosition = YAxis.LabelPosition.outsideChart
        leftAxis.valueFormatter = MyYAxisValueFormatter()
    }
    
    func onPriceBtnTapped() {
        ApiClient.sharedInstance.loadSpotPrice(withCurrency: self.currency)
    }
    
    func onModeBtnTapped(sender: UIButton) {
        setButtonSelected(index: sender.tag)
        ApiClient.sharedInstance.loadSpotPrice(withCurrency: self.currency)
        
        switch sender.tag {
        case 0:
            ApiClient.sharedInstance.loadHistoricalPrice(withRouter: CoindeskRouter.Week(self.currency))
            break
        case 1:
            ApiClient.sharedInstance.loadHistoricalPrice(withRouter: CoindeskRouter.Month(self.currency))
            break
        case 2:
            ApiClient.sharedInstance.loadHistoricalPrice(withRouter: CoindeskRouter.Year(self.currency))
            break
        case 3:
            ApiClient.sharedInstance.loadHistoricalPrice(withRouter: CoindeskRouter.All(self.currency))
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
        
        if index == 3 {
            chartView.xAxis.valueFormatter = MyXAxisYearFormatter()
        } else if index == 2 {
            chartView.xAxis.valueFormatter = MyXAxisMonthFormatter()
        } else {
            chartView.xAxis.valueFormatter = MyXAxisValueFormatter()
        }
    }
    
    func showSpinner() {
        spinner = MBProgressHUD.showAdded(to: self.chartView, animated: true)
        spinner?.bezelView.style = MBProgressHUDBackgroundStyle.solidColor
        spinner?.bezelView.color = UIColor.clear
        spinner?.contentColor = UIColor.white
    }
    
    func hideSpinner() {
        self.spinner?.hide(animated: true)
        MBProgressHUD.hide(for: self.chartView, animated: true)
    }
    
    func onNewSpotData(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let price = userInfo["price"] as? String else { return }
        
        debugPrint("new spot price: 1 BTC = \(price) \(self.currency)")
        DispatchQueue.main.async {
            // UI Updates
            if let priceDouble = Double(price) {
                let priceNumber = NSNumber(value: priceDouble)
                self.priceBtn.setTitle(Constants.currencyFormatter.string(from: priceNumber), for: UIControlState.normal)
            }
        }
    }
    
    func onLoadingHome(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let doneLoading = userInfo["doneLoading"] as? Bool else { return }
        
        debugPrint("doneLoading = \(doneLoading)")
        DispatchQueue.main.async {
            if doneLoading {
                self.hideSpinner()
            } else {
                self.showSpinner()
            }
        }
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
            let dataEntry = ChartDataEntry(x: pricePoints[i].date.timeIntervalSince1970, y: pricePoints[i].price)
            //debugPrint("[CHART] date = \(pricePoints[i].date); price = \(pricePoints[i].price)")
            dataEntries.append(dataEntry)
        }
        debugPrint("pricePoints.count = \(pricePoints.count)")
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        chartDataSet.fillFormatter = MyFillFormatter()
        chartDataSet.drawFilledEnabled = true
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawCircleHoleEnabled = false
        chartDataSet.drawValuesEnabled = false
        chartDataSet.drawVerticalHighlightIndicatorEnabled = false
        chartDataSet.mode = .linear
//        chartDataSet.colors = ChartColorTemplates.vordiplom()
//        chartDataSet.drawCubicEnabled = true
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

