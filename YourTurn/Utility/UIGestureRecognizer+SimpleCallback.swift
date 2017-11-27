import UIKit
import ObjectiveC

extension UIGestureRecognizer
{
    /** A proxy for a gesture recognizer action method. */
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

    /** Store the proxy via ObjC associated objects so that it is not dealloc'd. */
    private var passthrough : GesturePassthrough
    {
        get { return objc_getAssociatedObject(self, &passthroughKey) as! GesturePassthrough }
        set { objc_setAssociatedObject(self, &passthroughKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }

    /**
     * Create a gesture recognizer with the passed function as its action callback.
     */
    convenience init(didRecognize: @escaping (UIGestureRecognizer) -> Void)
    {
        let passthrough = GesturePassthrough(callback: didRecognize)
        self.init(target: passthrough,
                  action: #selector(GesturePassthrough.didRecognize(recognizer:)))
        self.passthrough = passthrough
    }
}

/** Key for the `GesturePassthrough` associated object. */
private var passthroughKey : UInt8 = 0
