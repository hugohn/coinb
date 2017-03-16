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
import RealmSwift

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
    var prevPrice: Double?
    var spinner: MBProgressHUD?
    var currRouterType: String?
    
    let spotRefreshInterval = 3.0
    let priceAnimatationDuration = 1.0
    
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
        
        Timer.scheduledTimer(withTimeInterval: spotRefreshInterval, repeats: true) {[weak self] (Timer) in
            if let strongSelf = self {
                strongSelf.backgroundQueue.async {
                    ApiClient.sharedInstance.loadSpotPrice(withCurrency: strongSelf.currency)
                }
            }
        }
        onModeBtnTapped(sender: yearModeBtn)
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
        
        priceBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        priceBtn.setTitleColor(Constants.grayColor, for: UIControlState.selected)
        
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
        chartView.noDataTextColor = Constants.grayColor
        chartView.noDataText = "Fetching price data..."
        
        chartView.rightAxis.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.drawAxisLineEnabled = false
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
    
    func onModeBtnTapped(sender: UIButton) {
        setButtonSelected(index: sender.tag)
        chartView.clear()
        
        backgroundQueue.async {
            ApiClient.sharedInstance.loadSpotPrice(withCurrency: self.currency)
            
            var router: CoindeskRouter?
            switch sender.tag {
            case 0:
                router = CoindeskRouter.Week(self.currency)
                break
            case 1:
                router = CoindeskRouter.Month(self.currency)
                break
            case 2:
                router = CoindeskRouter.Year(self.currency)
                break
            case 3:
                router = CoindeskRouter.All(self.currency)
                break
            default:
                break
            }
            
            if let router = router {
                self.currRouterType = router.type
                ApiClient.sharedInstance.loadHistoricalPrice(withRouter: router)
            }
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
        guard spinner == nil else { return }
        debugPrint("[SPINNER] showSpinner")
        spinner = MBProgressHUD.showAdded(to: self.chartView, animated: true)
        spinner?.bezelView.style = MBProgressHUDBackgroundStyle.solidColor
        spinner?.bezelView.color = UIColor.clear
        spinner?.contentColor = UIColor.white
    }
    
    func hideSpinner() {
        guard spinner != nil else { return }
        debugPrint("[SPINNER] hideSpinner")
        spinner?.hide(animated: true)
        spinner = nil
    }
    
    func onNewSpotData(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let price = userInfo["price"] as? String else { return }
        
        debugPrint("new spot price: 1 BTC = \(price) \(self.currency)")
        DispatchQueue.main.async {
            // UI Updates
            if let priceDouble = Double(price) {
                
                let priceNumber = NSNumber(value: priceDouble)
                var animateColor = UIColor.white
                
                // flash red if price is decreasing, green otherwise
                if self.prevPrice != nil && self.prevPrice != priceDouble {
                    if self.prevPrice! > priceDouble {
                        animateColor = UIColor.red
                    } else {
                        animateColor = UIColor.green
                    }
                }
                
                UIView.transition(with: self.priceBtn, duration: self.priceAnimatationDuration, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    self.priceBtn.setTitleColor(animateColor, for: UIControlState.normal)
                }, completion: { (Bool) in
                    self.priceBtn.setTitle(Constants.currencyFormatter.string(from: priceNumber), for: UIControlState.normal)
                    self.priceBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
                    self.prevPrice = priceDouble
                })
            }
        }
    }
    
    func onLoadingHome(notification: Notification) {
        DispatchQueue.main.async {
            self.showSpinner()
        }
    }
    
    func onNewHomeData(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let routerType = userInfo["type"] as? String,
            let pricePoints = userInfo["pricePoints"] as? Results<PricePoint> else { return }
        guard routerType == currRouterType else { return }
        
        updateChartWithData(pricePoints: pricePoints)
    }
    
    func updateChartWithData(pricePoints: Results<PricePoint>!) {
        var dataEntries: [ChartDataEntry] = []
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
        let chartData = LineChartData(dataSet: chartDataSet)
        
        DispatchQueue.main.async {
            self.hideSpinner()
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

