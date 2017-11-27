import UIKit

/** PlayerSwitchViewController documentation */
class PlayerSwitchViewController : UIViewController
{
    override func viewDidLoad()
    {
        let height : CGFloat = 64
        let button = CountdownButton(frame: CGRect(x: 0, y: self.view.bounds.maxY - height,
                                                   width: self.view.bounds.width, height: height))
        button.text = "Done"
        button.countdownText = "Oops, I wasn't done!"
        self.view.addSubview(button)
    }
}
