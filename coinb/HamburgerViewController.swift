//
//  HamburgerViewController.swift
//  coinb
//
//  Created by Hugo Nguyen on 3/14/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewLeftMargin: NSLayoutConstraint!
    
    var originalLeftMargin: CGFloat!
    
    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            menuViewController.willMove(toParentViewController: self)
            menuView.addSubview(menuViewController.view)
            menuViewController.didMove(toParentViewController: self)
        }
    }
    
    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMove(toParentViewController: nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMove(toParentViewController: nil)
            }
            
            contentViewController.willMove(toParentViewController: self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMove(toParentViewController: self)
            toggleHamburger(open: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,  action: #selector(onPanGesture(sender:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(panGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onPanGesture(sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            originalLeftMargin = contentViewLeftMargin.constant
        } else if sender.state == UIGestureRecognizerState.changed {
            let translation = sender.translation(in: sender.view)
            if (translation.x > 0) {
                contentViewLeftMargin.constant = originalLeftMargin + translation.x
            }
        } else if sender.state == UIGestureRecognizerState.ended {
            let velocity = sender.velocity(in: sender.view)
            toggleHamburger(open: velocity.x > 0)
        }
    }

    func toggleHamburger(open: Bool) {
        UIView.animate(withDuration: 0.3) { () -> Void in
            if open {
                self.contentViewLeftMargin.constant = self.view.frame.size.width - 100
            } else {
                self.contentViewLeftMargin.constant = 0
            }
            self.view.layoutIfNeeded()
        }
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

