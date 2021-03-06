//
//  FCPublicationsTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 12/30/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationsTVCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var publication: FCPublication? {
        
        didSet{
            if let thePublication = self.publication {
                setUp(thePublication)
            }
        }
    }
    
    func setUp(publication: FCPublication) {
        self.titleLabel.text = publication.title
        self.addressLabel.text = publication.address
        self.distanceLabel.text = FCStringFunctions.longDistanceString(publication)
        self.iconImageView.image = FCIconFactory.publicationsTableIcon(publication)
        downloadImage()
    }
    
    func downloadImage() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            if self.publication?.photoData.photo != nil {self.showImage()}
                
            else if (self.publication?.photoData.didTryToDonwloadImage == false) {
                
                let photoFetcher = FCPhotoFetcher()
                photoFetcher.fetchPhotoForPublication(self.publication!, completion: { (image) -> Void in
                    
                    self.publication?.photoData.didTryToDonwloadImage = true
                    
                    if self.publication?.photoData.photo != nil {
                        self.showImage()
                    }
                })
            }
        })
    }
    
    func showImage() {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in

            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.photoImageView.alpha = 0
                self.photoImageView.image = self.publication?.photoData.photo
                self.photoImageView.alpha = 1
            })

        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = UIImage(named: "NoPhoto-Placeholder")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant:96 ))
        

    }
    
}

