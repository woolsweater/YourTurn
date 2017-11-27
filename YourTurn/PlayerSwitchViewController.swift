import UIKit

/** PlayerSwitchViewController documentation */
class PlayerSwitchViewController : UIViewController, CountdownButtonObserver
{
    override func viewDidLoad()
    {
        let height : CGFloat = 64
        let button = CountdownButton(frame: CGRect(x: 0, y: self.view.bounds.maxY - height,
                                                   width: self.view.bounds.width, height: height))
        button.observer = self
        button.text = "Done"
        button.countdownText = "Oops, I wasn't done!"
        self.view.addSubview(button)
    }
    
    //MARK:- CountdownButtonObserver
    
    func countdownDidBegin(_ button: CountdownButton)
    {
        // Show next player view controller
    }
    
    func countdownDidComplete(_ button: CountdownButton)
    {
        // Disable button
    }

    func countdownWasCancelled(_ button: CountdownButton)
    {
        
    }
}
