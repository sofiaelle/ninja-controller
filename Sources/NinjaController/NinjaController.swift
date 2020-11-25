//
//  Copyright © 2019 Team Mingle. All rights reserved.
//

import UIKit

public final class NinjaController {

    private let containerView: UIView
    private let ninjaImageView: UIImageView
    private(set) var isWalking = false

    private let walkDuration: TimeInterval = 5
    private let edgePadding: CGFloat = 10
    private var minCenter: CGPoint {
        return CGPoint(x: edgePadding + ninjaImageView.bounds.size.width / 2, y: 0)
    }
    private var maxCenter: CGPoint {
        return  CGPoint(x: containerView.bounds.width - ninjaImageView.bounds.width / 2 - edgePadding, y: 0)
    }

    /// The returned ninja controller must be strongly retained by the caller.
    /// - Parameters:
    ///   - parentView: The view the ninja will reside in
    ///   - yAxisAnchor: The bottom or top anchor to pin the ninja to
    ///   - constant: The distance from the `yAxisAnchor` to pin the ninja to
    ///   - sideLength: The side height in points of the square ninja
    ///   - useWhiteNinja: A white ninja may be more suitable for dark background
    public init(parentView: UIView,
                yAxisAnchor: NSLayoutYAxisAnchor,
                constant: CGFloat = 0,
                sideLength: CGFloat = 30,
                useWhiteNinja: Bool = false) {
        containerView = NinjaController.createContainerView(in: parentView,
                                                            height: sideLength,
                                                            yAxisAnchor: yAxisAnchor,
                                                            constant: constant)
        ninjaImageView = NinjaController.createNinja(sideLength: sideLength,
                                                     useWhiteNinja: useWhiteNinja)
        containerView.addSubview(ninjaImageView)
        beginObservingAppDidBecomeActive()
    }

    /// Will start the ninja walking animation if the ninja is in the current window.
    @objc
    public func startWalkingAnimationIfNeeded() {
        // Avoid starting the animation if it's already running or if the view isn't visible in the current window.
        guard !isWalking, ninjaImageView.window != nil else {
            return
        }

        ninjaImageView.center = minCenter
        ninjaImageView.transform = .identity
        isWalking = true
        walk(forward: true)
    }

    // MARK: Private

    private func beginObservingAppDidBecomeActive() {
        // The animation may need to be restarted when returning from an inactive app state.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(startWalkingAnimationIfNeeded),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    private func walk(forward: Bool) {
        UIView.animate(withDuration: walkDuration,
                       delay: 0,
                       options: [.curveLinear],
                       animations: {
                        self.ninjaImageView.center = forward ? self.maxCenter : self.minCenter
                       }, completion: { (finished) in
                        // If the animation is interupted or if there is no longer a window for the ninja,
                        // calling walk recusively will push the device to 100% CPU usage as the completion
                        /// block would be called immediately.
                        guard finished, self.containerView.window != nil else {
                            self.isWalking = false
                            return
                        }

                        // Recursivly walk in the opposite direction by mirroring the image
                        self.ninjaImageView.transform = self.ninjaImageView.transform.scaledBy(x: -1, y: 1)
                        self.walk(forward: !forward)
                       })
    }

    private static func images(useWhiteNinja: Bool) -> [UIImage] {
        var images: [UIImage] = []
        for i in 1...4 {
            let name = "walk\(useWhiteNinja ? "-white" : "")\(i)"
            let image = UIImage(named: name, in: .module, with: nil)!
            images.append(image)
        }
        return images
    }

    private static func createNinja(sideLength: CGFloat, useWhiteNinja: Bool) -> UIImageView {
        let ninjaFrame = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)
        let imageView = UIImageView(frame: ninjaFrame)
        imageView.animationImages = NinjaController.images(useWhiteNinja: useWhiteNinja)
        imageView.animationDuration = 0.5
        imageView.startAnimating()
        return imageView
    }

    private static func createContainerView(in parentView: UIView,
                                            height: CGFloat,
                                            yAxisAnchor: NSLayoutYAxisAnchor,
                                            constant: CGFloat) -> UIView {
        let containerFrame = CGRect(x: 0, y: 0, width: parentView.bounds.width, height: height)
        let containerView = UIView(frame: containerFrame)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(containerView)
        NSLayoutConstraint.activate([containerView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                                     containerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                                     containerView.heightAnchor.constraint(equalToConstant: height),
                                     containerView.bottomAnchor.constraint(equalTo: yAxisAnchor, constant: constant)])
        return containerView
    }

}
