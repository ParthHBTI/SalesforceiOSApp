//
//  LeftViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit
import SalesforceSDKCore
import SalesforceRestAPI
import SDWebImage

enum LeftMenu: Int {
    case lead = 0
    case account
    case contact
    case opportunity
    case Logout
    case NonMenu
}

protocol LeftMenuProtocol : class {
    func changeViewController(menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    var menus = ["Leads", "Accounts", "Contacts", "Opportunities", "Logout"]
    var mainViewController: UIViewController!
    var swiftViewController: UIViewController!
    var javaViewController: UIViewController!
    var goViewController: UIViewController!
    var nonMenuViewController: UIViewController!
    var imageHeaderView: ImageHeaderView!
    var userInfoDic: NSDictionary!
    var rootVC = RootViewController()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //remove all blank rows from table view
//        NSLog(@"userData= %@",[SFAuthenticationManager sharedManager].idCoordinator.idData);
//        
//        NSLog(@"first name = %@",[SFAuthenticationManager sharedManager].idCoordinator.idData.firstName);
//        NSLog(@"last name = %@",[SFAuthenticationManager sharedManager].idCoordinator.idData.lastName);
//        NSLog(@"email name = %@",[SFAuthenticationManager sharedManager].idCoordinator.idData.email);
        
        
        
        
        tableView.tableFooterView = UIView()
        //self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let swiftViewController = storyboard.instantiateViewControllerWithIdentifier("AccountViewController") as! AccountViewController
        self.swiftViewController = UINavigationController(rootViewController: swiftViewController)
        
        let javaViewController = storyboard.instantiateViewControllerWithIdentifier("ContactViewController") as! ContactViewController
        self.javaViewController = UINavigationController(rootViewController: javaViewController)
        
        let goViewController = storyboard.instantiateViewControllerWithIdentifier("OpportunityViewController") as! OpportunityViewController
        self.goViewController = UINavigationController(rootViewController: goViewController)
        
        let nonMenuController = storyboard.instantiateViewControllerWithIdentifier("NonMenuController") as! NonMenuController
        nonMenuController.delegate = self
        self.nonMenuViewController = UINavigationController(rootViewController: nonMenuController)
        self.tableView.registerCellClass(BaseTableViewCell.self)
        self.imageHeaderView = ImageHeaderView.loadNib()
        self.view.addSubview(self.imageHeaderView)
        
     let sfIdentityData =    SFAuthenticationManager.sharedManager().idCoordinator.idData

        
        
       var userName = ""
        if  let _  = nullToNil(sfIdentityData.displayName) {
            userName = sfIdentityData.displayName
        }
        var userCompanyName = ""
        if  let _  = nullToNil( sfIdentityData.username) {
            userCompanyName =  sfIdentityData.username
        }
        
        
        self.imageHeaderView.userNameLbl.text = userName + " (" + userCompanyName + ")"
        self.imageHeaderView.userEmailLbl.text = sfIdentityData.email
        let url = sfIdentityData.pictureUrl
            
            //NSURL(string: (userInfoDic["FullPhotoUrl"] as? String!)! + "?oauth_token=" + SFUserAccountManager.sharedInstance().currentUser!.credentials.accessToken! )
      
        
        self.imageHeaderView.profileImage?.sd_setImageWithURL(url,placeholderImage: UIImage(named: "User"))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imageHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.imageHeaderView.backgroundImage.frame.height)
        //self.imageHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160)
        self.view.layoutIfNeeded()
    }
    
    func logoutFromApp()  {
        SFAuthenticationManager.sharedManager().logout()
     //   UIAppDelegate.handleSdkManagerLogout()
    }
    
    func changeViewController(menu: LeftMenu) {
        switch menu {
        case .lead:
            self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
        case .account:
            self.slideMenuController()?.changeMainViewController(self.swiftViewController, close: true)
        case .contact:
            self.slideMenuController()?.changeMainViewController(self.javaViewController, close: true)
        case .opportunity:
            self.slideMenuController()?.changeMainViewController(self.goViewController, close: true)
        case .Logout: logoutFromApp()
        case .NonMenu:
            self.slideMenuController()?.changeMainViewController(self.nonMenuViewController, close: true)
        }
    }
    
}

extension LeftViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            switch menu {
            case .lead, .account, .contact, .opportunity, .Logout, .NonMenu:
                return BaseTableViewCell.height()
            }
        }
        return 0
    }
}

extension LeftViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let menu = LeftMenu(rawValue: indexPath.item) {
            switch menu {
            case .lead, .account, .contact, .opportunity, .Logout, .NonMenu:
                let cell = BaseTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: BaseTableViewCell.identifier)
                cell.setData(menus[indexPath.row])
                tableView.backgroundColor = UIColor.init(colorLiteralRed: 78.0/255, green: 158.0/255, blue: 255.0/255, alpha: 1.0)
                cell.backgroundColor = UIColor.init(colorLiteralRed: 78.0/255, green: 158.0/255, blue: 255.0/255, alpha: 1.0)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            self.changeViewController(menu)
        }
    }
}

extension LeftViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.tableView == scrollView {
            
        }
    }
}
