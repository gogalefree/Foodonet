//
//  FCPublishRootVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

let kPublisherRootVCHeaderViewReusableId = "collectionViewHeader"
///
/// show all user created publication: live and expired.
/// contains a button for creating a new Publication.
/// clicking an item starts’ editing mode of that item.
///
class FCPublishRootVC : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, UISearchBarDelegate , UIScrollViewDelegate{
    
    @IBOutlet var collectionView:UICollectionView!
    var noUserCreatedPublicationMessageLabel: UILabel?
    
    var userCreatedPublications = [FCPublication]()
    var collectionViewHidden = false
    
    var searchBar: UISearchBar!
    var searchTextCharCount = 0
    var onceToken = 0
    var isFiltered = false
    var unPresentedPublications = [FCPublication]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
        
        collectionView.delegate = self
        if userCreatedPublications.count == 0 {
            collectionView.alpha = 0
            collectionViewHidden = true
            displayNoPublicatiosMessage()
        }
        else {
            
            userCreatedPublications = FCPublicationsSorter.sortPublicationByIsOnAir(userCreatedPublications)
            collectionView.userInteractionEnabled = true
            collectionView.scrollEnabled = true
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newUserCreatedPublication", name: kNewUserCreatedPublicationNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeletePublicationNotification", name: kDeletedPublicationNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        dispatch_once(&onceToken) {
            self.collectionView.contentOffset.y = 20
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return userCreatedPublications.count
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        
        var publication = userCreatedPublications[indexPath.item]
        let reusableId = "FCPublishCollectionViewCell"
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableId, forIndexPath: indexPath) as! FCPublishRootVCCustomCollectionViewCell
        cell.publication = publication
        
        // The tag property will be used later in the segue to identify
        // the publication item clicked by the user for editing.
        cell.tag = indexPath.item
       // FCTableViewAnimator.animateCollectionViewCell(cell, sender: self.collectionView)
        
        return cell
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if let collectionView = self.collectionView {
        
            self.collectionView.collectionViewLayout.invalidateLayout()
            super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = CGSizeMake(self.collectionView.bounds.size.width , 90)
        return size
    }
    
    // Check which segue was used to go to the FCPublicationEditorTVC view.
    //
    // If the segue identifier is "showNewPublicationEditorTVC" - do nothing. In the
    // FCPublicationEditorTVC class we will check to see if var publication is empty or nil
    // and if it is, we will disply a new publication table.
    //
    // If the segue identifier is "showEditPublicationEditorTVC" we will pass on the
    // publication object that corresponds to the clicked cell in the collection view
    // and display the publication's content in the FCPublicationEditorTVC class.

    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
      
        if (segue.identifier == "showEditPublicationEditorTVC") {
            let publicationEditorTVC = segue!.destinationViewController as! FCPublicationEditorTVC
            publicationEditorTVC.setupWithState(.EditPublication, publication: userCreatedPublications[sender.tag])
        }
        else if (segue.identifier == "showNewPublicationEditorTVC") {
            let publicationEditorTVC = segue!.destinationViewController as! FCPublicationEditorTVC
            publicationEditorTVC.setupWithState(.CreateNewPublication, publication: nil)
        }
    }
    
    func newUserCreatedPublication() {
        
        if collectionViewHidden {showCollectionView()}
        let publication = FCModel.sharedInstance.userCreatedPublications.last!
        self.userCreatedPublications.insert(publication, atIndex: 0)
        self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])        
    }
    
    func showCollectionView() {
        self.collectionViewHidden = false
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.collectionView.alpha = 1
            if let label = self.noUserCreatedPublicationMessageLabel {
                label.alpha = 0
                label.removeFromSuperview()
            }
        })
    }
    
    //this is triggered by a NSNotification.
    //we reload the collection view since it might have been a user created publication taken off air
    func didDeletePublicationNotification() {
        self.collectionView.reloadData()
    }
    
    func displayNoPublicatiosMessage(){
        let recWidth = FCDeviceData.screenWidth()/1.4
        let recHight = FCDeviceData.screenHight()/1.4
        let recCenterX = FCDeviceData.screenWidth()/2
        let recCenterY = FCDeviceData.screenHight()/2
        let fontSize = FCDeviceData.screenWidth()/10 - 9
        
        self.noUserCreatedPublicationMessageLabel = UILabel(frame: CGRectMake(0, 0, recWidth, recHight))
        
        if let label = self.noUserCreatedPublicationMessageLabel {
            
            label.center = CGPointMake(recCenterX, recCenterY - 100)
            label.textAlignment = NSTextAlignment.Center
            label.numberOfLines = 0
            label.font = UIFont.systemFontOfSize(fontSize)
            label.text = String.localizedStringWithFormat("Hi,\nYou haven't shared yet." , "No user created publications message")
            self.view.addSubview(label)
        }
    }
    
    //MARK: - UISearchBar
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableview:UICollectionReusableView!
        
        
        
        if (kind == UICollectionElementKindSectionHeader) {
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: kPublisherRootVCHeaderViewReusableId, forIndexPath: indexPath) as! FCPublisherRootVCCollectionViewHeaderCollectionReusableView
            
            headerView.setUp()
            self.searchBar = headerView.searchBar
            self.searchBar.delegate = self
            reusableview = headerView
        }
        
        return reusableview
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        //user is deleting
        //show all publications
        if searchText == "" || count(searchText) < self.searchTextCharCount{
            
            self.isFiltered = false
            self.showAllUserCreatedPublications()
        }
            //user is writing
        else {
            
            self.isFiltered = true
            self.searchPublications(searchText)
        }
        
        //save the count to check whether user writing or deleting
        self.searchTextCharCount = count(searchText)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {

        searchBar.setShowsCancelButton(false, animated: true)
        self.isFiltered = false
        self.searchBar.resignFirstResponder()
        self.searchBar.text = ""
        self.showAllUserCreatedPublications()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.collectionView.contentOffset.y = 20
        })
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            //sort by onAire
            self.userCreatedPublications = FCPublicationsSorter.sortPublicationByIsOnAir(self.userCreatedPublications)
        case 1:
            //sort by OffAir
            self.userCreatedPublications = FCPublicationsSorter.sortPublicationsByIsOffAir(self.userCreatedPublications)
            
        case 2:
            //sort by endingDate
            self.userCreatedPublications = FCPublicationsSorter.sortPublicationsByEndingDate(self.userCreatedPublications)
        default:
            break
        }
        self.collectionView.reloadData()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        self.searchBar.resignFirstResponder()
    }
    
    func searchPublications(text: String) {
        
        for (index ,publication) in enumerate(self.userCreatedPublications) {
            
            var titleRange: Range<String.Index> = Range<String.Index>(start: publication.title.startIndex  ,end: publication.title.endIndex)
            
            var titleFound = publication.title.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch, range: titleRange, locale: nil)
            
            
            var subtitleFound: Range<String.Index>?
            
            if let subtitle = publication.subtitle {
                
                var subTitleRange = Range<String.Index>(start: subtitle.startIndex  ,end: subtitle.endIndex)
                
                subtitleFound = subtitle.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch, range: subTitleRange, locale: nil)
                
            }
            
            if titleFound == nil && subtitleFound == nil {
                
                self.unPresentedPublications.append(publication)
                
            }
        }
        
        self.removeFromCollectionView()
    }
    
    func removeFromCollectionView() {
        
            for publicationToRemove in self.unPresentedPublications {
                
                for (index, publication) in enumerate(self.userCreatedPublications) {
                    
                    if publicationToRemove.uniqueId == publication.uniqueId &&
                        publicationToRemove.version == publication.version {
                            self.userCreatedPublications.removeAtIndex(index)
                            self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
                            break
                    }
                }
            }
    }
    
    func showAllUserCreatedPublications() {
        
            for publication in self.unPresentedPublications {
                
                self.userCreatedPublications.append(publication)
                self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.userCreatedPublications.count-1, inSection: 0)])
            }

            self.unPresentedPublications.removeAll(keepCapacity: false)
        
        self.collectionView.performBatchUpdates({ () -> Void in
            self.userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
            self.userCreatedPublications = FCPublicationsSorter.sortPublicationByIsOnAir(self.userCreatedPublications)
        }, completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
