import UIKit

extension CATransaction
{
    /**
     * A wrapper for an implicit animation. Allows chaining further animations
     * to be run after it completes.
     */
    class Animation
    {
        /** The action to take when an animation has finished. */
        enum Completion
        {
            /** When the animation has finished, this function should be invoked. */
            case simple(() -> Void)
            /** When the animation has finished, this `Animation` should begin. */
            indirect case animation(Animation)
        }

        /** The duration of the animation. If none is set, `CATransaction`'s default is used. */
        let duration : CFTimeInterval?
        /** A timing function for the animation. If none is set, `CATransaction`'s default is used. */
        let timingFunction : CAMediaTimingFunction?
        /** The code for the animation itself. */
        let action : () -> Void
        /** The action to take when the animation completes. Defaults to `nil`. */
        private(set) var completion : Completion?

        /**
         * Create an animation.
         * - parameter duration: The duration for the new animation. Defaults to `nil`.
         * - parameter timingFunction: The timing function for the new animation. Defaults to `nil`.
         * - parameter action: The code for the animation itself.
         * - parameter completion: The action to take when the animation completes. Defaults to `nil`.
         */
        init(duration: CFTimeInterval? = nil,
             timingFunction: CAMediaTimingFunction? = nil,
             action: @escaping () -> Void,
             completion: (() -> Void)? = nil)
        {
            self.duration = duration
            self.timingFunction = timingFunction
            self.action = action
            self.completion = completion.map({ .simple($0) })
        }

        /**
         * Create another `Animation` with the given parameters and add it as this `Animation`'s completion.
         * - parameter duration: The duration for the new animation. Defaults to `nil`.
         * - parameter timingFunction: The timing function for the new animation. Defaults to `nil`.
         * - parameter action: The code for the animation itself.
         * - parameter completion: The action to take when the animation completes. Defaults to `nil`.
         * - returns: The new animation that was added to the end of the chain; this reference can be used
         * to continue chaining more animations.
         * - important: The existing `Animation` must not already have a completion.
         */
        @discardableResult
        func chainAnimation(duration: CFTimeInterval? = nil,
                            timingFunction: CAMediaTimingFunction? = nil,
                            action: @escaping () -> Void,
                            completion: (() -> Void)? = nil)
            -> Animation
        {
            precondition(self.completion == nil, "Animation already has a completion.")
            let chained = Animation(
                duration: duration,
                timingFunction: timingFunction,
                action: action,
                completion: completion
            )
            self.completion = .animation(chained)
            return chained
        }
    }

    /**
     * Configure and commit a transaction using the values in the given `Animation`.
     * This will produce nested transactions for any completions, with each configured
     * by its associated `Animation` as needed.
     */
    static func animate(_ animation: Animation)
    {
        self.begin()
        if let duration = animation.duration {
            self.setAnimationDuration(duration)
        }
        if let timingFunction = animation.timingFunction {
            self.setAnimationTimingFunction(timingFunction)
        }
        switch animation.completion {
            case .none:
                break
            case let .simple(block)?:
                self.setCompletionBlock(block)
            case let .animation(nextAnimation)?:
                self.animateChained(nextAnimation)
        }
        animation.action()
        self.commit()
    }

    private static func animateChained(_ animation: Animation)
    {
        self.setCompletionBlock({ self.animate(animation) })
    }
}
