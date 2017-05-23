//
//  ViewController.swift
//  EmojiControl
//
//  Created by Gosha K on 22.05.17.
//  Copyright © 2017 Gosha K. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var emojiView: EmojiRatingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let eView = EmojiRatingView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100), scale: 1.2, images: [#imageLiteral(resourceName: "lol"), #imageLiteral(resourceName: "cry"), #imageLiteral(resourceName: "no_emotions"), #imageLiteral(resourceName: "thumbsDown"), #imageLiteral(resourceName: "like"), #imageLiteral(resourceName: "love"), #imageLiteral(resourceName: "ok"), #imageLiteral(resourceName: "thumbsUp")])
        self.view.addSubview(eView)
    }



}

