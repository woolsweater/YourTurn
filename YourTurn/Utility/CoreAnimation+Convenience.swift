import UIKit

extension CAMediaTimingFunction
{
    /** The system-provided "Ease In" timing function. */
    static let easeIn = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
}

extension CATransform3D
{
    /** The identity transform. */
    static let identity = CATransform3DIdentity

    /**
     * A transform that scales the horizontal axis to 0, leaving the other two
     * axes untouched.
     */
    static let horizontalScaleZero = CATransform3D.scaling(x: 0.0, y: 1.0)

    /**
     * Create an iterator that produces transforms progressively shrinking along
     * the horizontal axis, starting at `1.0 - (1.0 / steps)` and going to `0.0`.
     */
    static func horizontalShrinker(steps: Int) -> AnyIterator<CATransform3D>
    {
        let perStepFraction = 1.0 / CGFloat(steps)
        var index = 0
        return AnyIterator {
            guard index < steps else { return nil }
            index = index + 1
            let fraction = 1.0 - (perStepFraction * CGFloat(index))
            return CATransform3D.scaling(x: fraction, y: 1.0)
        }
    }

    /**
     * Create a transform that scales the x, y, and z axes to the given fractions.
     * - parameter tx: The scaling factor for the x axis, 0 to 1 inclusive.
     * - parameter ty: The scaling factor for the y axis, 0 to 1 inclusive.
     * - parameter tz: The scaling factor for the z axis, 0 to 1 inclusive. Defaults to 1.
     */
    static func scaling(x tx: CGFloat, y ty: CGFloat, z tz: CGFloat = 1.0) -> CATransform3D
    {
        return CATransform3DMakeScale(tx, ty, tz)
    }
}
