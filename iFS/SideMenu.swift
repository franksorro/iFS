//
//  SideMenu.swift
//  iFS
//
//  Created by Francesco Sorrentino on 21/09/18.
//  Copyright © 2018 Francesco Sorrentino. All rights reserved.
//

import Foundation
import UIKit

extension FsManager {

    public class SideMenu: NSObject {

        public static let shared: SideMenu = SideMenu()

        private override init() {}

        private var sideMenuContainerView: UIView!
        private var sideMenuView: UIView!
        private var noAreaView: UIView! //---Clear view with closing tap for the area not covered by the sideMenu---
        private var direction: Types.SideMenuDirections!
        private var injectedViewController: UIViewController!
        private var leadingAnchor: NSLayoutConstraint!
        private var topAnchor: NSLayoutConstraint!
        private var trailingAnchor: NSLayoutConstraint!
        private var bottomAnchor: NSLayoutConstraint!

        public var padding: CGFloat = 50

        public func open(direction: Types.SideMenuDirections = .left,
                         container: UIViewController,
                         injectViewController: UIViewController?,
                         callBack: @escaping SideMenuResult) {
            guard
                sideMenuContainerView == nil,
                injectViewController != nil
                else {
                    callBack(false)
                    return
            }

            sideMenuContainerView = UIView(frame: container.view.bounds)
            container.view.addSubview(sideMenuContainerView)

            sideMenuContainerView.backgroundColor = UIColor.clear
            sideMenuContainerView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate(
                [sideMenuContainerView.leadingAnchor.constraint(equalTo: container.view.leadingAnchor, constant: 0),
                 sideMenuContainerView.topAnchor.constraint(equalTo: container.view.topAnchor, constant: 0),
                 sideMenuContainerView.trailingAnchor.constraint(equalTo: container.view.trailingAnchor, constant: 0),
                 sideMenuContainerView.bottomAnchor.constraint(equalTo: container.view.bottomAnchor, constant: 0)]
            )

            injectedViewController = injectViewController

            sideMenuView = UIView(frame: injectViewController!.view.bounds)
            sideMenuView.addSubview(injectViewController!.view)
            sideMenuView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate(
                [injectViewController!.view.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor,
                                                                     constant: 0),
                 injectViewController!.view.trailingAnchor.constraint(equalTo: sideMenuView.trailingAnchor,
                                                                      constant: 0),
                 injectViewController!.view.topAnchor.constraint(equalTo: sideMenuView.topAnchor,
                                                                 constant: 0),
                 injectViewController!.view.bottomAnchor.constraint(equalTo: sideMenuView.bottomAnchor,
                                                                    constant: 0)]
            )

            sideMenuContainerView.addSubview(sideMenuView)
            sideMenuContainerView.bringSubviewToFront(sideMenuView)

            container.addChild(injectViewController!)

            injectViewController!.view.translatesAutoresizingMaskIntoConstraints = false

            var leadingAnchorValue: CGFloat = 0
            var topAnchorValue: CGFloat = 0
            var trailingAnchorValue: CGFloat = 0
            var bottomAnchorValue: CGFloat = 0

            var shadowSize = CGSize(width: 0, height: 0)

            switch direction {
            case .left:
                trailingAnchorValue = padding * -1
                shadowSize = CGSize(width: 15, height: 0)

            case .right:
                leadingAnchorValue = padding
                shadowSize = CGSize(width: -15, height: 0)

            case .top:
                bottomAnchorValue = padding * -1

            case .bottom:
                topAnchorValue = padding
            }

            sideMenuView.layer.shadowOffset = shadowSize
            sideMenuView.layer.shadowOpacity = 0.5
            sideMenuView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor

            leadingAnchor = sideMenuView.leadingAnchor.constraint(equalTo: sideMenuContainerView.leadingAnchor,
                                                                  constant: leadingAnchorValue)
            topAnchor = sideMenuView.topAnchor.constraint(equalTo: sideMenuContainerView.topAnchor,
                                                          constant: topAnchorValue)
            trailingAnchor = sideMenuView.trailingAnchor.constraint(equalTo: sideMenuContainerView.trailingAnchor,
                                                                    constant: trailingAnchorValue)
            bottomAnchor = sideMenuView.bottomAnchor.constraint(equalTo: sideMenuContainerView.bottomAnchor,
                                                                constant: bottomAnchorValue)

            NSLayoutConstraint.activate([leadingAnchor, topAnchor, trailingAnchor, bottomAnchor] )

            injectViewController!.didMove(toParent: container)

            var directionToSwipe: UISwipeGestureRecognizer.Direction
            SideMenu.shared.direction = direction

            var frame = sideMenuView.bounds

            noAreaView = UIView()
            sideMenuContainerView.addSubview(noAreaView)
            noAreaView.backgroundColor = UIColor.clear

            var vwNoAreaOriginX: CGFloat = 0
            var vwNoAreaOriginY: CGFloat = 0
            var vwNoAreaWidth: CGFloat = 0
            var vwNoAreaHeight: CGFloat = 0

            switch direction {
            case .left:
                directionToSwipe = .left
                sideMenuView.frame.origin.x = sideMenuView.frame.width * -1
                frame.origin.x = 0
                vwNoAreaOriginX = sideMenuContainerView.frame.width - padding
                vwNoAreaOriginY = 0
                vwNoAreaWidth = padding
                vwNoAreaHeight = sideMenuContainerView.frame.height

            case .right:
                directionToSwipe = .right
                sideMenuView.frame.origin.x = sideMenuView.frame.width
                frame.origin.x = sideMenuContainerView.frame.width - sideMenuView.frame.width
                vwNoAreaOriginX = 0
                vwNoAreaOriginY = 0
                vwNoAreaWidth = padding
                vwNoAreaHeight = sideMenuContainerView.frame.height

            case .top:
                directionToSwipe = .up
                sideMenuView.frame.origin.y = sideMenuView.frame.height * -1
                frame.origin.y = 0
                vwNoAreaOriginX = 0
                vwNoAreaOriginY = sideMenuContainerView.frame.height - padding
                vwNoAreaWidth = sideMenuContainerView.frame.width
                vwNoAreaHeight = padding

            case .bottom:
                directionToSwipe = .down
                sideMenuView.frame.origin.y = sideMenuView.frame.height
                frame.origin.y = sideMenuContainerView.frame.height - sideMenuView.frame.height
                vwNoAreaOriginX = 0
                vwNoAreaOriginY = 0
                vwNoAreaWidth = sideMenuContainerView.frame.width
                vwNoAreaHeight = padding
            }

            noAreaView.frame = CGRect(x: vwNoAreaOriginX,
                                      y: vwNoAreaOriginY,
                                      width: vwNoAreaWidth,
                                      height: vwNoAreaHeight)

            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeFromNoArea))
            swipeGesture.direction = directionToSwipe
            sideMenuView.addGestureRecognizer(swipeGesture)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.closeFromNoArea))
            tapGesture.numberOfTapsRequired = 1
            noAreaView.addGestureRecognizer(tapGesture)

            UIApplication.shared.beginIgnoringInteractionEvents()

            UIView.animate(withDuration: TimeInterval(0.3), animations: {
                self.sideMenuView.frame = frame
                self.sideMenuView.layoutIfNeeded()
                if let bgColor = self.sideMenuContainerView.backgroundColor {
                    self.sideMenuContainerView.backgroundColor = bgColor.withAlphaComponent(0.5)
                }

            }, completion: { (_) in
                UIApplication.shared.endIgnoringInteractionEvents()
                callBack(true)
            })
        }

        private func resetViews() {
            if injectedViewController != nil {
                injectedViewController.removeFromParent()
                injectedViewController = nil
            }

            if noAreaView != nil {
                noAreaView.removeFromSuperview()
                noAreaView = nil
            }

            if sideMenuView != nil {
                sideMenuView.removeFromSuperview()
                sideMenuView = nil
            }

            if sideMenuContainerView != nil {
                sideMenuContainerView.removeFromSuperview()
                sideMenuContainerView = nil
            }
        }

        @objc private func closeFromNoArea() {
            self.close()
        }

        @objc public func close(callBack: @escaping (_ result: Bool) -> Void = { _ in }) {
            if sideMenuContainerView != nil && sideMenuView != nil && direction != nil {
                var frame = sideMenuView.frame

                let direction: Types.SideMenuDirections = self.direction
                switch direction {
                case .left:
                    frame.origin.x = sideMenuContainerView.frame.width * -1

                case .right:
                    frame.origin.x = sideMenuContainerView.frame.width

                case .top:
                    frame.origin.y = sideMenuContainerView.frame.height * -1

                case .bottom:
                    frame.origin.y = sideMenuContainerView.frame.height
                }

                UIApplication.shared.beginIgnoringInteractionEvents()

                UIView.animate(withDuration: TimeInterval(0.3), animations: {
                    self.sideMenuView.frame = frame
                    self.sideMenuView.layoutIfNeeded()
                    self.self.sideMenuContainerView.backgroundColor = UIColor.clear.withAlphaComponent(0)

                }, completion: { (_) in
                    self.resetViews()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    callBack(true)
                })

            } else { //---Forced closure---
                resetViews()
                callBack(false)
            }
        }
    }

}
