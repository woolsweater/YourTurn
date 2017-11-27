import UIKit

/**
 * Draws a tappable bar that does a countdown animation after tapped.
 */
class CountdownButton : UIView
{
    var text : String? = nil
    {
        didSet {
            self.label.text = self.text
        }
    }
    
    var countdownText : String? = nil
    
    private let label : UILabel
    
    private let ticker : CALayer
    
    private var shrinker : AnyIterator<CATransform3D>? = nil

    private var isCountingDown : Bool = false

    override init(frame: CGRect)
    {
        self.label = UILabel()
        self.ticker = CALayer()
        super.init(frame: frame)
        self.addGestureRecognizer(UITapGestureRecognizer(didRecognize: self.tap))
        self.backgroundColor = .darkGray
        self.constrainLabel()
        self.configureTicker()
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }
    
    private func constrainLabel()
    {
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.label)
        NSLayoutConstraint.activate([
            self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func configureTicker()
    {
        self.ticker.frame = CGRect(origin: self.bounds.origin,
                                     size: self.bounds.size)
        self.ticker.backgroundColor = UIColor.red.cgColor
        self.ticker.opacity = 0.0
        self.layer.insertSublayer(self.ticker, at: 0)
    }

    @objc private func tap(recognizer: UIGestureRecognizer)
    {
        if self.isCountingDown {
            self.resetCountdown()
        }
        else {
            self.beginCountdown()
        }
    }

    private func beginCountdown()
    {
        self.isCountingDown = true
        if let countdownText = self.countdownText {
            self.label.text = countdownText
        }
        let steps = 5
        self.shrinker = CATransform3D.horizontalShrinker(steps: steps)
        self.ticker.opacity = 1.0
        self.countDown(from: steps)
    }

    private func countDown(from index: Int)
    {
        guard self.isCountingDown, index > 0 else {
            self.resetCountdown()
            return
        }
        CATransaction.setAnimationDuration(0.95)
        CATransaction.setAnimationTimingFunction(.easeIn)
        CATransaction.setCompletionBlock({
            guard let nextTransform = self.shrinker?.next() else { return }
            CATransaction.setAnimationDuration(0.05)
            CATransaction.setCompletionBlock({
                self.countDown(from: index - 1)
            })
            self.ticker.transform = nextTransform
        })
        self.ticker.transform = .horizontalScaleZero
    }

    private func resetCountdown()
    {
        self.isCountingDown = false
        self.label.text = self.text
        self.shrinker = nil
        self.ticker.opacity = 0.0
        self.ticker.transform = .identity
    }
}

extension CAMediaTimingFunction
{
    static let easeIn = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
}

extension CATransform3D
{
    static let identity = CATransform3DIdentity
    
    static let horizontalScaleZero = CATransform3DMakeScale(0.0, 1.0, 1.0)
    
    static func horizontalShrinker(steps: Int) -> AnyIterator<CATransform3D>
    {
        let perStepFraction = 1.0 / CGFloat(steps)
        var index = 0
        return AnyIterator {
            guard index < steps else { return nil }
            index = index + 1
            let fraction = 1.0 - (perStepFraction * CGFloat(index))
            return CATransform3DMakeScale(fraction, 1.0, 1.0)
        }
    }
}

import ObjectiveC

private var passthroughKey : UInt8 = 0

extension UIGestureRecognizer
{
    private class GesturePassthrough : NSObject
    {
        let callback : (UIGestureRecognizer) -> Void

        init(callback: @escaping (UIGestureRecognizer) -> Void)
        {
            self.callback = callback
        }

        @objc func didRecognize(recognizer: UIGestureRecognizer)
        {
            self.callback(recognizer)
        }
    }

    private var passthrough : GesturePassthrough
    {
        get { return objc_getAssociatedObject(self, &passthroughKey) as! GesturePassthrough }
        set { objc_setAssociatedObject(self, &passthroughKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }

    convenience init(didRecognize: @escaping (UIGestureRecognizer) -> Void)
    {
        let passthrough = GesturePassthrough(callback: didRecognize)
        self.init(target: passthrough,
                  action: #selector(GesturePassthrough.didRecognize(recognizer:)))
        self.passthrough = passthrough
    }
}

extension CGRect
{
    var rotatedSize : CGSize
    {
        return CGSize(width: self.size.height, height: self.size.width)
    }
}
