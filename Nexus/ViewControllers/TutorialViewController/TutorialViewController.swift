//
//  TutorialViewController.swift
//  Nexus
//
//  Created by Clifford Yin on 1/15/19.
//  Copyright © 2019 Clifford Yin. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SwipeableTabBarController
import TinyConstraints

/* Displays two tabs with a tutorial video on each */
class TutorialViewController: SwipeableTabBarController {

    var avPlayerMaster: AVPlayer!
    var avPlayerBoard: AVPlayer!
    var leftDot: UIImageView!
    var rightDot: UIImageView!
    var onRight = true
    
    // MARK: Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isHidden = true
        self.view.backgroundColor = UIColor(rgb: 0x6B9AFF)
        
        // Sets up the videos with .mov resources
        let filepathMaster: String? = Bundle.main.path(forResource: "NexusTut1", ofType: "mov")
        let fileURLMaster = URL.init(fileURLWithPath: filepathMaster!)
        avPlayerMaster = AVPlayer(url: fileURLMaster)
        
        let filepathBoard: String? = Bundle.main.path(forResource: "NexusTut2", ofType: "mov")
        let fileURLBoard = URL.init(fileURLWithPath: filepathBoard!)
        avPlayerBoard = AVPlayer(url: fileURLBoard)
        
        let avPlayerControllerMaster = AVPlayerViewController()
        avPlayerControllerMaster.player = avPlayerMaster
        avPlayerControllerMaster.view.frame = CGRect(x: 40, y: 40, width: UIScreen.main.bounds.size.width - 80, height: UIScreen.main.bounds.size.height - 140)
        avPlayerControllerMaster.showsPlaybackControls = true
        
        let avPlayerControllerBoard = AVPlayerViewController()
        avPlayerControllerBoard.player = avPlayerBoard
        avPlayerControllerBoard.view.frame = CGRect(x: 40, y: 40, width: UIScreen.main.bounds.size.width - 80, height: UIScreen.main.bounds.size.height - 140)
        avPlayerControllerBoard.showsPlaybackControls = true
        
        // Prepares a tab view controller
        let masterView = UIViewController()
        masterView.view.addSubview(avPlayerControllerMaster.view)
        let boardView = UIViewController()
        boardView.view.addSubview(avPlayerControllerBoard.view)
        self.viewControllers = [masterView, boardView]
        
        let button = UIButton(frame: CGRect(x: view.frame.midX - 20, y: view.frame.height - 60, width: 60, height: 40))
        button.setTitle("Done", for: .normal)
        button.titleLabel!.font = UIFont(name: "DINAlternate-Bold", size: 20)
        button.addTarget(self, action: #selector(dismissTutorial(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        
        leftDot = UIImageView(image: UIImage(named: "Filled Indicator"))
        rightDot = UIImageView(image: UIImage(named: "Unfilled Indicator"))
        self.view.addSubview(leftDot)
        self.view.addSubview(rightDot)
        leftDot.bottomToTop(of: button)
        rightDot.bottomToTop(of: button)
        leftDot.centerX(to: button, nil, offset: -10.0, priority: LayoutPriority(rawValue: 1), isActive: true)
        rightDot.centerX(to: button, nil, offset: 10.0, priority: LayoutPriority(rawValue: 1), isActive: true)
        
        avPlayerMaster.play()
    }
    
    // MARK: TabBarController delegate functions
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (onRight) {
            // If swipes right, set right dot to filled
            leftDot.image = UIImage(named: "Unfilled Indicator")
            rightDot.image = UIImage(named: "Filled Indicator")
            onRight = false
            avPlayerBoard.seek(to: kCMTimeZero)
            avPlayerBoard.play()
        } else {
            // If swipes left, set left dot to filled
            leftDot.image = UIImage(named: "Filled Indicator")
            rightDot.image = UIImage(named: "Unfilled Indicator")
            onRight = true
            avPlayerMaster.seek(to: kCMTimeZero)
            avPlayerMaster.play()
        }
    }
    
    @objc
    func dismissTutorial(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

