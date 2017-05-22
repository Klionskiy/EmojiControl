//
//  EmojiRatingView.swift
//  EmojiControl
//
//  Created by Gosha K on 22.05.17.
//  Copyright © 2017 Gosha K. All rights reserved.
//

import UIKit
import Foundation

protocol EmojiRatingViewDelegate
{
    func saveRating(rating: Int)
}

class RatingButton : UIButton {
    fileprivate static let selectedScale = 1.3
    override var isSelected: Bool
        {
        willSet
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                if newValue
                {
                    self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                }
                else
                {
                    self.transform = CGAffineTransform.identity
                }
            })
        }
    }
}

class EmojiRatingView: UIView
{
    private var ratingButtons = [RatingButton]()
    private var emoji = [#imageLiteral(resourceName: "angry"), #imageLiteral(resourceName: "no_emotions"), #imageLiteral(resourceName: "confused"), #imageLiteral(resourceName: "like"), #imageLiteral(resourceName: "love")]
    
    private var touchHasEnded = false
    private var delegate : EmojiRatingViewDelegate?
    
    // MARK: - Properties
    
    public var rating : Int = -1
    {
        didSet
        {
            if rating > maxRating
            {
                rating = maxRating
            }
            setNeedsLayout()
        }
    }
    private var ratingForTouchBegan : Int = -1
    public var maxRating : Int = 5
    {
        didSet
        {
            setNeedsLayout()
        }
    }
    
    var spacing : CGFloat
    {
        return buttonsWidth/(CGFloat(maxRating) + 1)
    }
    
    // MARK: - Computed properties
    
    private var buttonsLength: CGFloat
    {
        return frame.width / 5
    }
    
    private var buttonsWidth: CGFloat
    {
        return frame.width / (CGFloat(maxRating) + 1) > frame.height ? frame.height : frame.width / (CGFloat(maxRating) + 1)
    }
    
    private var buttonsHeight: CGFloat
    {
        return buttonsWidth
    }
    
    // MARK: - Create and set buttons
    
    public func createButtons()
    {
        guard ratingButtons.count == 0
            else { return }
        
        for i in 0..<maxRating
        {
            let button = RatingButton()
            let basicImage = emoji[i].convertToGrayScale()
            //button.backgroundColor = UIColor.green
            button.setImage(basicImage, for: .normal)
            button.setImage(emoji[i], for: .selected)
            //            button.setImage(emoji[i], for: [.highlighted, .selected])
            button.imageView?.contentMode = .scaleAspectFit
            
            button.isUserInteractionEnabled = false
            button.adjustsImageWhenHighlighted = false
            let buttonFrame = CGRect(x: 0, y: 0, width: buttonsWidth, height: buttonsHeight)
            button.frame = buttonFrame
            ratingButtons.append(button)
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.createButtons()
        //self.spacing = (self.frame.width - CGFloat(ratingButtons.count) * buttonsLength) / CGFloat(ratingButtons.count)
        //        var buttonFrame = CGRect(x: 0, y: 0, width: buttonsLength, height: buttonsHeight)
        print(spacing)
        for (index, button) in ratingButtons.enumerated()
        {
            button.center.x = buttonsWidth/2  + spacing + CGFloat(index) * (buttonsWidth + spacing)
            print(button.isSelected)
        }
        
        updateButtonsSelectedState()
    }
    
    override var intrinsicContentSize: CGSize
    {
        return CGSize(width: buttonsWidth, height: buttonsHeight)
    }
    
    func updateButtonsSelectedState()
    {
        if rating == -1
        {
            deselectButtons()
        }
        else if rating < ratingButtons.count
        {
            setSingleSelection(sender: ratingButtons[rating])
        }
    }
    
    func deselectButtons()
    {
        for button in ratingButtons
        {
            
            button.isSelected = false
        }
    }
    
    func setSingleSelection(sender: UIButton)
    {
        deselectButtons()
        sender.isSelected = true
    }
    
    // MARK: - Handle touch events
    
    func handleTouchEvent(touches: Set<UITouch>, withEvent event: UIEvent?, type : events)
    {
        if let touch = touches.first
        {
            let position = touch.location(in: self)
            
            for button in ratingButtons
            {
                
                
                if button.frame.contains(position)
                {
                    switch type {
                    case .began:
                        ratingForTouchBegan = ratingButtons.index(of: button)!
                        
                    case .end:
                        
                        if button.isSelected && ratingForTouchBegan == rating {
                            deselectButtons()
                            rating = -1
                            ratingForTouchBegan = -1
                            return
                        } else if rating != ratingButtons.index(of: button)! {
                            ratingForTouchBegan = -1
                            rating = ratingButtons.index(of: button)!
                        }
                    case .move:
                        ratingForTouchBegan = -1
                        if ratingButtons.index(of: button)! != rating {
                            rating = ratingButtons.index(of: button)!
                            return
                        }
                        
                        
                    }
                    
                    //button.isSelected = true
                                    }
            }
        }
    }
//    func handleEndTouchEvent(touches: Set<UITouch>, withEvent event: UIEvent?)
//    {
//        if let touch = touches.first
//        {
//            let position = touch.location(in: self)
//            for button in ratingButtons
//            {
//                if button.frame.contains(position)
//                {
//                    //button.isSelected = true
//                    rating = ratingButtons.index(of: button)!
//                    return
//                } else {
//                    
//                
//            }
//        }
//    }
//    func handleBeginTouchEvent(touches: Set<UITouch>, withEvent event: UIEvent?)
//    {
//        if let touch = touches.first
//        {
//            let position = touch.location(in: self)
//            for button in ratingButtons
//            {
//                if button.frame.contains(position)
//                {
//                    return
//                }
//            }
//            deselectButtons()
//        }
//    }
    enum events :Int {
        case began = 0
        case end = 1
        case move = 2
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        handleTouchEvent(touches: touches, withEvent: event, type: .began)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        handleTouchEvent(touches: touches, withEvent: event, type: .end)
        delegate?.saveRating(rating: rating)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        handleTouchEvent(touches: touches, withEvent: event, type: .move)
    }
    
    
    
    
    
    
    
    func resizeImage(image: UIImage) -> UIImage {
        
        let scale = 200 / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: 200, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width: 200, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

extension UIImage
{
    func convertToGrayScale() -> UIImage
    {
        let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = self.size.width
        let height = self.size.height
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(self.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()
        let convertedImage = UIImage(cgImage: imageRef!)
        
        return convertedImage
    }
}
