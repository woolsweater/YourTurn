import UIKit

/** PlayerSwitchViewController documentation */
class PlayerSwitchViewController : UIViewController
{
    override func viewDidLoad()
    {
        let height : CGFloat = 64
        let button = CountdownButton(frame: CGRect(x: 0, y: self.view.bounds.maxY - height,
                                                   width: self.view.bounds.width, height: height))
        self.view.addSubview(button)
    }
}
