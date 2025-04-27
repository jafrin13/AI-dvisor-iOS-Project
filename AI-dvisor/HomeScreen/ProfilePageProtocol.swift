//
//  ProfilePageProtocol.swift
//  AI-dvisor
//
//  Created by Jafrina Rahman on 4/8/25.
//

import UIKit

// To communicate back to the settings page to change PFP since user changed it
protocol ProfilePageDelegate: AnyObject {
    func profilePageDidUpdateProfilePicture(_ newProfilePicture: UIImage)
}
