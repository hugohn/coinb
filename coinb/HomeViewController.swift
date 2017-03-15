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
    @IBOutlet weak var chartView: LineChartView!
    
    var currency = "USD"
    
    let backgroundQueue = DispatchQueue(label: "com.hugohn.coinb",
                                        qos: .background,
                                        target: nil)
    
    private var spinner: MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupChartView()
        NotificationCenter.default.addObserver(self, selector: #selector(onNewHomeData(notification:)), name: NSNotification.Name(rawValue: kNewHomeData), object: nil)
        
        showSpinner()
        backgroundQueue.async {
            // Background thread
            ApiClient.sharedInstance.getSpotPrice(withCurrency: self.currency) { (price: String?) in
                DispatchQueue.main.async {
                    // UI Updates
                    self.hideSpinner()
                    if let price = price {
                        self.priceLabel.text = price
                    }
                }
            }
            
            ApiClient.sharedInstance.getHistoricalPrice(withRouter: CoindeskRouter.Month(self.currency))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupChartView() {
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.highlightPerDragEnabled = true
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        
        chartView.backgroundColor = UIColor.white
        chartView.legend.enabled = false
        chartView.tintColor = UIColor.blue
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

