//
//  GifOpeningViewController.swift
//  diplomaThesis
//
//  Created by User on 7/4/21.
//

import Foundation
import UIKit
import SwiftyGif


/// The controller that handles the heart loading gif image.
class GifOpeningViewController : UIViewController{
    
    @IBOutlet weak var gifImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let gif = try UIImage(gifName: "intro.gif")
            
            self.gifImageView.setGifImage(gif, loopCount: 2) // Will loop forever
            self.gifImageView.startAnimating()
            let timer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false, block: { timer in
                self.gifImageView.stopAnimating()
                self.performSegue(withIdentifier: "firstSegue", sender: self)
            })
            
        } catch {
            print("Error loading SwiftyGif")
        }
        
    }
    
}
