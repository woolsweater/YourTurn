import UIKit

/** Callbacks for events on a `CountdownButton`. */
protocol CountdownButtonObserver : class
{
    /** Notify the observer that the countdown has started. */
    func countdownDidBegin(_ button: CountdownButton)

    /** Notify the observer that the countdown has ended because the time elapsed. */
    func countdownDidComplete(_ button: CountdownButton)

    /**
     * Notify the observer that the countdown has ended because the user tapped
     * the button again within the counted period.
     */
    func countdownWasCancelled(_ button: CountdownButton)
}

/** Draws a tappable bar that does a countdown animation after being tapped. */
class CountdownButton : UIView
{
    /** The text that should be displayed in the label when the button is idle. */
    var text : String? = nil
    {
        didSet {
            self.label.text = self.text
        }
    }

    /**
     * The text that should be displayed in the label when the button is performing
     * a countdown.
     */
    var countdownText : String? = nil

    /**
     * The color for the animated bar that is drawn during a countdown. Defaults to
     * `UIColor.red`.
     */
    var countdownColor : UIColor = .red

    /**
     * The number of seconds for the countdown. Defaults to 5; only whole numbers
     * are supported.
     */
    var duration : Int = 5

    /** Whether the button should respond to taps. */
    var isEnabled : Bool = true
    {
        didSet { self.configureGestureRecognizer() }
    }

    /** An object that wants to be notified of button events. */
    weak var observer : CountdownButtonObserver? = nil

    private let label : UILabel

    private let ticker : CALayer

    private var shrinker : AnyIterator<CATransform3D>? = nil

    private var isCountingDown : Bool = false

    private var tapRecognizer : UITapGestureRecognizer!

    override init(frame: CGRect)
    {
        self.label = UILabel()
        self.ticker = CALayer()
        super.init(frame: frame)
        self.tapRecognizer = UITapGestureRecognizer(didRecognize: self.tap)
        self.configureGestureRecognizer()
        self.constrainLabel()
        self.configureTicker()
    }

    /** `initWithCoder:` is not supported on `CountdownButton` */
    required init?(coder _: NSCoder) {
        fatalError("`initWithCoder:' is not supported on 'CountdownButton'")
    }

    private func configureGestureRecognizer()
    {
        if self.isEnabled {
            self.addGestureRecognizer(self.tapRecognizer)
        }
        else {
            self.removeGestureRecognizer(self.tapRecognizer)
        }
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
        self.ticker.backgroundColor = self.countdownColor.cgColor
        self.ticker.opacity = 0.0
        self.layer.insertSublayer(self.ticker, at: 0)
    }

    @objc private func tap(recognizer: UIGestureRecognizer)
    {
        if self.isCountingDown {
            self.resetCountdown()
            self.observer?.countdownWasCancelled(self)
        }
        else {
            self.beginCountdown()
            self.observer?.countdownDidBegin(self)
        }
    }

    private func resetCountdown()
    {
        self.isCountingDown = false
        self.label.text = self.text
        self.shrinker = nil
        self.ticker.opacity = 0.0
        self.ticker.transform = .identity
    }

    private func beginCountdown()
    {
        self.isCountingDown = true
        if let countdownText = self.countdownText {
            self.label.text = countdownText
        }
        let steps = self.duration
        self.shrinker = CATransform3D.horizontalShrinker(steps: steps)
        self.ticker.opacity = 1.0
        self.countDown(from: steps)
    }

    private func countDown(from index: Int)
    {
        guard self.isCountingDown, index > 0 else {
            self.resetCountdown()
            self.observer?.countdownDidComplete(self)
            return
        }
        CATransaction.setAnimationDuration(Animation.shrinkingDuration)
        CATransaction.setAnimationTimingFunction(.easeIn)
        CATransaction.setCompletionBlock({
            guard let nextTransform = self.shrinker?.next() else { return }
            CATransaction.setAnimationDuration(Animation.expandingDuration)
            CATransaction.setCompletionBlock({
                self.countDown(from: index - 1)
            })
            self.ticker.transform = nextTransform
        })
        self.ticker.transform = .horizontalScaleZero
    }
}

//MARK:- Constants
extension CountdownButton
{
    fileprivate struct Animation
    {
        /** The length of time that the countdown bar should spend shrinking. */
        static let shrinkingDuration : CFTimeInterval = 0.95
        /** The length of time that the countdown bar should spend expanding. */
        static var expandingDuration : CFTimeInterval
        {
            return 1.0 - self.shrinkingDuration
        }
    }
}
