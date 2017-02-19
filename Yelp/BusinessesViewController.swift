//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var business: Business?
    
    let searchBar = UISearchBar()
    var searchTerm: String?
    
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    var offset: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        
        //Set tableview height
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        //Adding search bar to navi bar
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchTerm = "Chinese"
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        self.loadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return filteredBusinesses?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = filteredBusinesses[indexPath.row]
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        filteredBusinesses = searchText.isEmpty ? businesses : businesses?.filter {(businesses: Business) -> Bool in
            return (businesses.name! as String).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        self.tableView.reloadData()
    }
    
    func loadData() {
        Business.searchWithTerm(term: searchTerm!, offset: 0, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.filteredBusinesses = self.businesses
            self.tableView.reloadData()
            
            if let businesses = businesses {
                for business in businesses {
                    print("Name: \(business.name!)")
                    print("Address: \(business.address!)")
                }
            }
        }
        )
        self.tableView.reloadData()
        
    }
    
    func loadMoreData() {
        
        self.offset = self.offset + 20

        Business.searchWithTerm(term: searchTerm!, offset: offset, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses?.append(contentsOf: businesses!)
            self.filteredBusinesses = self.businesses
            self.isMoreDataLoading = false
            self.tableView.reloadData()
            
            if let businesses = businesses {
                for business in businesses {
                    print("Name: \(business.name!)")
                    print("Address: \(business.address!)")
                }
            }
        }
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData()
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
