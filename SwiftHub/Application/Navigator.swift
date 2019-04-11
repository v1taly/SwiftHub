//
//  Navigator.swift
//  SwiftHub
//
//  Created by Khoren Markosyan on 1/5/18.
//  Copyright © 2018 Khoren Markosyan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SafariServices
import Hero
import AcknowList
import WhatsNewKit
import MessageUI

protocol Navigatable {
    var navigator: Navigator! { get set }
}

class Navigator {
    static var `default` = Navigator()

    // MARK: - segues list, all app scenes
    enum Scene {
        case tabs(viewModel: HomeTabBarViewModel)
        case search(viewModel: SearchViewModel)
        case languages(viewModel: LanguagesViewModel)
        case users(viewModel: UsersViewModel)
        case userDetails(viewModel: UserViewModel)
        case repositories(viewModel: RepositoriesViewModel)
        case repositoryDetails(viewModel: RepositoryViewModel)
        case contents(viewModel: ContentsViewModel)
        case source(viewModel: SourceViewModel)
        case commits(viewModel: CommitsViewModel)
        case branches(viewModel: BranchesViewModel)
        case releases(viewModel: ReleasesViewModel)
        case pullRequests(viewModel: PullRequestsViewModel)
        case events(viewModel: EventsViewModel)
        case notifications(viewModel: NotificationsViewModel)
        case issues(viewModel: IssuesViewModel)
        case theme(viewModel: ThemeViewModel)
        case language(viewModel: LanguageViewModel)
        case acknowledgements
        case whatsNew(block: WhatsNewBlock)
        case contacts(viewModel: ContactsViewModel)
        case safari(URL)
        case safariController(URL)
        case webController(URL)
    }

    enum Transition {
        case root(in: UIWindow)
        case navigation(type: HeroDefaultAnimationType)
        case customModal(type: HeroDefaultAnimationType)
        case modal
        case detail
        case alert
        case custom
    }

    // MARK: - get a single VC
    func get(segue: Scene) -> UIViewController? {
        switch segue {
        case .tabs(let viewModel):
            let rootVC = R.storyboard.main.homeTabBarController()!
            rootVC.navigator = self
            rootVC.viewModel = viewModel
//            let rootNavVC = NavigationController(rootViewController: rootVC)
            let detailVC = R.storyboard.main.initialSplitViewController()!
            let detailNavVC = NavigationController(rootViewController: detailVC)
            let splitVC = SplitViewController()
            splitVC.viewControllers = [rootVC, detailNavVC]
            return splitVC

        case .search(let viewModel):
            let vc = R.storyboard.main.searchViewController()!
            vc.viewModel = viewModel
            return vc

        case .languages(let viewModel):
            let vc = R.storyboard.main.languagesViewController()!
            vc.viewModel = viewModel
            return vc

        case .users(let viewModel):
            let vc = R.storyboard.main.usersViewController()!
            vc.viewModel = viewModel
            return vc

        case .userDetails(let viewModel):
            let vc = R.storyboard.main.userViewController()!
            vc.viewModel = viewModel
            return vc

        case .repositories(let viewModel):
            let vc = R.storyboard.main.repositoriesViewController()!
            vc.viewModel = viewModel
            return vc

        case .repositoryDetails(let viewModel):
            let vc = R.storyboard.main.repositoryViewController()!
            vc.viewModel = viewModel
            return vc

        case .contents(let viewModel):
            let vc = R.storyboard.main.contentsViewController()!
            vc.viewModel = viewModel
            return vc

        case .source(let viewModel):
            let vc = R.storyboard.main.sourceViewController()!
            vc.viewModel = viewModel
            return vc

        case .commits(let viewModel):
            let vc = R.storyboard.main.commitsViewController()!
            vc.viewModel = viewModel
            return vc

        case .branches(let viewModel):
            let vc = R.storyboard.main.branchesViewController()!
            vc.viewModel = viewModel
            return vc

        case .releases(let viewModel):
            let vc = R.storyboard.main.releasesViewController()!
            vc.viewModel = viewModel
            return vc

        case .pullRequests(let viewModel):
            let vc = R.storyboard.main.pullRequestsViewController()!
            vc.viewModel = viewModel
            return vc

        case .events(let viewModel):
            let vc = R.storyboard.main.eventsViewController()!
            vc.viewModel = viewModel
            return vc

        case .notifications(let viewModel):
            let vc = R.storyboard.main.notificationsViewController()!
            vc.viewModel = viewModel
            return vc

        case .issues(let viewModel):
            let vc = R.storyboard.main.issuesViewController()!
            vc.viewModel = viewModel
            return vc

        case .theme(let viewModel):
            let vc = R.storyboard.main.themeViewController()!
            vc.viewModel = viewModel
            return vc

        case .language(let viewModel):
            let vc = R.storyboard.main.languageViewController()!
            vc.viewModel = viewModel
            return vc

        case .acknowledgements:
            let vc = AcknowListViewController()
            return vc

        case .whatsNew(let block):
            if let versionStore = block.2 {
                return WhatsNewViewController(whatsNew: block.0, configuration: block.1, versionStore: versionStore)
            } else {
                return WhatsNewViewController(whatsNew: block.0, configuration: block.1)
            }

        case .contacts(let viewModel):
            let vc = R.storyboard.main.contactsViewController()!
            vc.viewModel = viewModel
            return vc

        case .safari(let url):
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            return nil

        case .safariController(let url):
            let vc = SFSafariViewController(url: url)
            return vc

        case .webController(let url):
            let vc = WebViewController()
            vc.load(url: url)
            return vc
        }
    }

    func pop(sender: UIViewController?, toRoot: Bool = false) {
        if toRoot {
            sender?.navigationController?.popToRootViewController(animated: true)
        } else {
            sender?.navigationController?.popViewController()
        }
    }

    func dismiss(sender: UIViewController?) {
        sender?.navigationController?.dismiss(animated: true, completion: nil)
    }

    func injectTabBarControllers(in target: UITabBarController) {
        if let children = target.viewControllers {
            for vc in children {
                injectNavigator(in: vc)
            }
        }
    }

    // MARK: - invoke a single segue
    func show(segue: Scene, sender: UIViewController?, transition: Transition = .navigation(type: .cover(direction: .left))) {
        if let target = get(segue: segue) {
            show(target: target, sender: sender, transition: transition)
        }
    }

    private func show(target: UIViewController, sender: UIViewController?, transition: Transition) {
        injectNavigator(in: target)

        switch transition {
        case .root(in: let window):
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window.rootViewController = target
            }, completion: nil)
            return
        case .custom: return
        default: break
        }

        guard let sender = sender else {
            fatalError("You need to pass in a sender for .navigation or .modal transitions")
        }

        if let nav = sender as? UINavigationController {
            //push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }

        switch transition {
        case .navigation(let type):
            if let nav = sender.navigationController {
                //add controller to navigation stack
                nav.hero.navigationAnimationType = .autoReverse(presenting: type)
                nav.pushViewController(target, animated: true)
            }
        case .customModal(let type):
            //present modally with custom animation
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                nav.hero.modalAnimationType = .autoReverse(presenting: type)
                sender.present(nav, animated: true, completion: nil)
            }
        case .modal:
            //present modally
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.present(nav, animated: true, completion: nil)
            }
        case .detail:
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.showDetailViewController(nav, sender: nil)
            }
        case .alert:
            DispatchQueue.main.async {
                sender.present(target, animated: true, completion: nil)
            }
        default: break
        }
    }

    private func injectNavigator(in target: UIViewController) {
        // view controller
        if var target = target as? Navigatable {
            target.navigator = self
            return
        }

        // navigation controller
        if let target = target as? UINavigationController, let root = target.viewControllers.first {
            injectNavigator(in: root)
        }

        // split controller
        if let target = target as? UISplitViewController, let root = target.viewControllers.first {
            injectNavigator(in: root)
        }
    }

    func toInviteContact(withPhone phone: String) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.body = "Hey! Come join SwiftHub at \(Configs.App.githubUrl)"
        vc.recipients = [phone]
        return vc
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
