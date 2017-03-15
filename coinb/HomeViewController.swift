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
        spinner = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinner?.color = UIColor.clear
        
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.highlightPerDragEnabled = true
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        
        chartView.backgroundColor = UIColor.white
        chartView.legend.enabled = false
        chartView.tintColor = UIColor.blue
        
        backgroundQueue.async {
            // Background thread
            ApiClient.sharedInstance.getSpotPrice(withCurrency: self.currency) { (price: String?) in
                self.spinner?.hide(animated: true)
                guard let price = price else { return }
                
                DispatchQueue.main.async {
                    // UI Updates
                    self.priceLabel.text = price
                }
            }
            
            ApiClient.sharedInstance.getHistoricalPrice(withCurrency: self.currency, completion: { (result: Bool, query: String) in
                guard result else { return }
                
                DispatchQueue.main.async {
                    // UI Updates
                    self.updateChartWithData(query: query)
                }
            })
        }
    }
    
    func updateChartWithData(query: String) {
        var dataEntries: [ChartDataEntry] = []
        let pricePoints = PricePoint.getPricePoints(query: query)
        for i in 0..<pricePoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: pricePoints[i].price)
            dataEntries.append(dataEntry)
        }
        debugPrint("pricePoints.count = \(pricePoints.count)")
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Price")
        let chartData = LineChartData(dataSet: chartDataSet)
        chartView.data = chartData
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

