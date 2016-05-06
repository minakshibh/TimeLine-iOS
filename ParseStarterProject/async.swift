import Foundation

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func async(closure:()->()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), closure)
}

func main(closure:()->()) {
    dispatch_async(dispatch_get_main_queue(), closure)
}

func synced(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

func SerialOperationQueue(name: String = "") -> NSOperationQueue {
    let op = NSOperationQueue()
    op.underlyingQueue = dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL)
    return op
}