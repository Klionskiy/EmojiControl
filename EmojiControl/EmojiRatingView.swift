//
//  EmojiRatingView.swift
//  EmojiControl
//
//  Created by Gosha K on 22.05.17.
//  Copyright © 2017 Gosha K. All rights reserved.
//

import UIKit
import Foundation

// MARK: - EmojiRatingViewDelegate Protocol

protocol EmojiRatingViewDelegate
{
    func saveRating(rating: Int)
}

// MARK: - RatingAnimationSettingsDelegate Protocol

protocol RatingAnimationSettingsDelegate
{
    func getScale() -> CGFloat
}

// MARK: - RatingButton Class

class RatingButton : UIButton
{
    var ratingAnimationSettingsDelegate : RatingAnimationSettingsDelegate?
    override var isSelected: Bool
        {
        willSet
        {
            if let delegate = ratingAnimationSettingsDelegate {
                if newValue
                {
                    let scale = delegate.getScale()
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                        self.transform = CGAffineTransform(scaleX: scale, y: scale)
                    })
                }
                else
                {
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                        self.transform = CGAffineTransform.identity
                    })
                }
            }
        }
    }
}

class EmojiRatingView: UIView
{
    
    
    // MARK: - Inspectable properties
    @IBInspectable
    public var selectedScale: CGFloat = 1.3
    
    // MARK: Properties
    private enum events :Int {
        case began = 0
        case end = 1
        case move = 2
    }
    
    private var ratingForTouchBegan : Int = -1
    
    private var ratingButtons = [RatingButton]()
    private var emoji = [#imageLiteral(resourceName: "angry"), #imageLiteral(resourceName: "no_emotions"), #imageLiteral(resourceName: "confused"), #imageLiteral(resourceName: "like"), #imageLiteral(resourceName: "love")]
    
    private var delegate : EmojiRatingViewDelegate?
    
    
    
    
    
    
    
    
    // MARK: Computed Properties
    
    public var rating : Int = -1
    {
        didSet
        {
            if rating > maxRating
            {
                rating = maxRating
            }
            if rating != -1 {
                //self.layoutMargins = UIEdgeInsets(top: 0, left: frame.width/CGFloat(maxRating), bottom: 0, right: frame.width/CGFloat(maxRating))
                //self.frame.size = CGSize(width: frame.size.width/selectedScale, height: frame.size.height/selectedScale)
            } else {
                
            }
            setNeedsLayout()
        }
    }
    private var maxRating : Int
    {
        return emoji.count
    }
    
    private var spacing : CGFloat
    {
        return  (frame.width - buttonsWidth * CGFloat(maxRating))/(CGFloat(maxRating) + 1)
    }
    
    private var buttonsWidth: CGFloat
    {
        let maxWidth = frame.width / (CGFloat(maxRating) + (CGFloat(maxRating) + 1)*(selectedScale - 1))
        return maxWidth > frame.height ? frame.height :  maxWidth
    }
    
    private var buttonsHeight: CGFloat
    {
        return buttonsWidth
    }
    
    // MARK: Override Properties
    
    override var intrinsicContentSize: CGSize
    {
        return CGSize(width: buttonsWidth, height: buttonsHeight)
    }
    //    override var frame: CGRect {
    //        willSet {
    //            setNeedsLayout()
    //        }
    //    }
    // MARK: - UI
    
    
    private func createButtons()
    {
        guard ratingButtons.count == 0
            else { return }
        
        for i in 0..<maxRating
        {
            let button = RatingButton()
            button.ratingAnimationSettingsDelegate = self
            let basicImage = emoji[i].convertToGrayScale()
            button.setImage(basicImage, for: .normal)
            button.setImage(emoji[i], for: .selected)
            button.imageView?.contentMode = .scaleAspectFill
            button.isUserInteractionEnabled = false
            button.adjustsImageWhenHighlighted = false
            
            //button.backgroundColor = UIColor.black
            ratingButtons.append(button)
            addSubview(button)
        }
    }
    
    // MARK: Layout
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.createButtons()
        UIView.animate(withDuration: 0.2) {}
        
        
        if   0...maxRating ~= rating
        {
            for (index, button) in ratingButtons.enumerated()
            {
                
//                let smallerWidth = buttonsWidth / selectedScale
//                switch index {
//                case rating:
//                    button.center.x = buttonsWidth/2  + spacing + CGFloat(index) * (smallerWidth + spacing)
//
//                case (rating + 1)...maxRating:
//                    button.center.x = smallerWidth/2  + spacing + CGFloat(index - 1) * (smallerWidth + spacing) + (buttonsWidth + spacing)
//                   // button.bounds.size = CGSize(width: smallerWidth, height: smallerWidth)
//                default:
//                    button.center.x = smallerWidth/2  + spacing + CGFloat(index) * (smallerWidth + spacing)
//                    //button.bounds.size = CGSize(width: smallerWidth, height: smallerWidth)
//                }
                button.center.x = buttonsWidth/2  + spacing + CGFloat(index) * (buttonsWidth + spacing)
                button.center.y = bounds.height/2
                button.bounds.size = intrinsicContentSize
            }
        } else
        {
            for (index, button) in ratingButtons.enumerated()
            {
                button.center.x = buttonsWidth/2  + spacing + CGFloat(index) * (buttonsWidth + spacing)
                button.bounds.size = intrinsicContentSize
                button.center.y = bounds.height/2
                
            }
            
        }
        updateButtonsSelectedState()
    }
    
    private func updateButtonsSelectedState()
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
    
    private func deselectButtons()
    {
        for button in ratingButtons
        {
            
            button.isSelected = false
        }
    }
    
    private func setSingleSelection(sender: UIButton)
    {
        deselectButtons()
        sender.isSelected = true
    }
    
    // MARK: - Handle touch events
    
    private func handleTouchEvent(touches: Set<UITouch>, withEvent event: UIEvent?, type : events)
    {
        if let touch = touches.first
        {
            let position = touch.location(in: self)
            
            for button in ratingButtons
            {
                if button.frame.origin.x...(button.frame.origin.x + button.frame.width) ~= position.x
                {
                    switch type
                    {
                    case .began:
                        ratingForTouchBegan = ratingButtons.index(of: button)!
                        return
                    case .end:
                        if button.isSelected && ratingForTouchBegan == rating {
                            deselectButtons()
                            rating = -1
                            ratingForTouchBegan = -1
                            return
                        } else if rating != ratingButtons.index(of: button)! {
                            ratingForTouchBegan = -1
                            rating = ratingButtons.index(of: button)!
                            return
                        }
                    case .move:
                        ratingForTouchBegan = -2
                        if ratingButtons.index(of: button)! != rating {
                            rating = ratingButtons.index(of: button)!
                            return
                        }
                    }
                }
            }
            if type == .end && ratingForTouchBegan == -1
            {
                deselectButtons()
                rating = -1
                ratingForTouchBegan = -1
                return
            }
        }
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
    
}

// MARK: - RatingAnimationSettingsDelegate Implementation

extension EmojiRatingView : RatingAnimationSettingsDelegate {
    func getScale() -> CGFloat {
        return selectedScale
    }
}

// MARK: - UIImage Extension - convertToGrayScale

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
