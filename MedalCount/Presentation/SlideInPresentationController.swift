/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class SlideInPresentationController: UIPresentationController {
  //1
  // MARK: - Properties
  private var dimmingView: UIView!
  private var direction: PresentationDirection
  override var frameOfPresentedViewInContainerView: CGRect {
    //1 You declare a frame and give it the size calculated in size(forChildContentContainer:withParentContainerSize:).
    var frame: CGRect = .zero
    frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)

    //2 For .right and .bottom directions, you adjust the origin by moving the x origin (.right) and y origin (.bottom) 1/3 of the width or height.
    switch direction {
    case .right:
      frame.origin.x = containerView!.frame.width * (1.0/3.0)
    case .bottom:
      frame.origin.y = containerView!.frame.height * (1.0/3.0)
    default:
      frame.origin = .zero
    }
    return frame
  }

  //2
  init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, direction: PresentationDirection) {
    self.direction = direction

    //3
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    setupDimmingView()
  }
  
  override func presentationTransitionWillBegin() {
    guard let dimmingView = dimmingView else { return }
    
    containerView?.insertSubview(dimmingView, at: 0)

    NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))
    NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))

    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 1.0
      return
    }

    coordinator.animate(alongsideTransition: { _ in self.dimmingView.alpha = 1.0 })
  }
  
  override func dismissalTransitionWillBegin() {
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 0.0
      return
    }

    coordinator.animate(alongsideTransition: { _ in self.dimmingView.alpha = 0.0 })
  }
  
  override func containerViewWillLayoutSubviews() {
    presentedView?.frame = frameOfPresentedViewInContainerView
  }
  
  // give the size of the presented view controller’s content to the presentation controller
  override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
    switch direction {
    case .left, .right:
      return CGSize(width: parentSize.width * (2.0/3.0), height: parentSize.height)
    case .bottom, .top:
      return CGSize(width: parentSize.width, height: parentSize.height * (2.0/3.0))
    }
  }
}


// MARK: - Private
private extension SlideInPresentationController {
  func setupDimmingView() {
    dimmingView = UIView()
    dimmingView.translatesAutoresizingMaskIntoConstraints = false
    dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    dimmingView.alpha = 0.0
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    dimmingView.addGestureRecognizer(recognizer)
  }
  
  @objc func handleTap(recognizer: UITapGestureRecognizer) {
    presentingViewController.dismiss(animated: true)
  }
}
