//
//  ViewController.swift
//  testShowMore
//
//  Created by User on 15/4/21.
//

import UIKit


/// The controller that handles the learn more section of the app. Most of it is developed using storyboards.
class LearnMoreController: UIViewController {
    
    @IBOutlet weak var button1: UIButton!
    
    @IBOutlet weak var button1_2: UIButton!
    
    @IBOutlet weak var button2: UIButton!
    
    @IBOutlet weak var button2_2: UIButton!
    
    @IBOutlet weak var button3: UIButton!
    
    @IBOutlet weak var button4: UIButton!
    
    @IBOutlet weak var button5: UIButton!
    
    @IBOutlet weak var button6: UIButton!
    
    @IBOutlet weak var button7: UIButton!
    
    @IBOutlet weak var button8: UIButton!
    
    @IBOutlet weak var textView1: UITextView!
    
    @IBOutlet weak var textView1_2: UITextView!
    
    @IBOutlet weak var textView2: UITextView!
    
    @IBOutlet weak var textView2_2: UITextView!
    
    @IBOutlet weak var textView3: UITextView!
    
    @IBOutlet weak var textView4: UITextView!
    
    @IBOutlet weak var textView5: UITextView!
    
    @IBOutlet weak var textView6: UITextView!
    
    @IBOutlet weak var textView7: UITextView!
    
    @IBOutlet weak var textView8: UITextView!
    
    @IBOutlet weak var height1: NSLayoutConstraint!
    
    @IBOutlet weak var height1_2: NSLayoutConstraint!
    
    @IBOutlet weak var height2: NSLayoutConstraint!
    
    @IBOutlet weak var height2_2: NSLayoutConstraint!
    
    @IBOutlet weak var height3: NSLayoutConstraint!
    
    @IBOutlet weak var height4: NSLayoutConstraint!
    
    @IBOutlet weak var height5: NSLayoutConstraint!
    
    @IBOutlet weak var height6: NSLayoutConstraint!
    
    @IBOutlet weak var height7: NSLayoutConstraint!
    
    @IBOutlet weak var height8: NSLayoutConstraint!
    
    var txtViews : [UITextView] = []
    var heights : [NSLayoutConstraint] = []
    var buttons : [UIButton] = []
    
    
    /// Calculates the height of the current textView.
    /// - Parameter tView: The input textView
    /// - Returns: A CGFloat representing the height of the textView.
    func getRowHeightFromText(tView: UITextView!) -> CGFloat
    {
        let strText = tView.text
        let textView : UITextView! = UITextView(frame: CGRect(x:      tView.frame.origin.x,
                                                              y: 0,
                                                              width: tView.frame.size.width,
                                                              height: 0))
        textView.text = strText
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.sizeToFit()
        
        var txt_frame : CGRect! = CGRect()
        txt_frame = textView.frame
        
        var size : CGSize! = CGSize()
        size = txt_frame.size
        
        size.height = txt_frame.size.height
        
        return size.height
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtViews.append(contentsOf: [textView1, textView1_2, textView2, textView2_2, textView3, textView4, textView5, textView6, textView7, textView8])
        heights.append(contentsOf: [height1, height1_2, height2, height2_2, height3, height4, height5, height6, height7, height8])
        buttons.append(contentsOf: [button1, button1_2, button2, button2_2, button3, button4, button5, button6, button7, button8])

    }
    
    
    /// Handles the click of any button. If it is the first (3rd, 5th, etc) click, it shows more. If it is the second (4th, 6th etc) it shows less.
    /// - Parameter sender: The sender button.
    @IBAction func buttonClicked(_ sender: UIButton) {
        var ind: Int = 0
        for i in 0..<buttons.count {
            if buttons[i] == sender {
                ind = i
                break
            }
        }
        if sender.tag == 0
        {
            let height = self.getRowHeightFromText(
                tView: txtViews[ind])
            print(height)
            self.heights[ind].constant = height
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            sender.tag = 1
        }
        else
        {
            self.heights[ind].constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            sender.tag = 0
        }
        
    }
    
    
    
}
