//
//  ProfilePageProtocol.swift
//  AI-dvisor
//
//  Created by Jafrina Rahman on 4/8/25.
//

import UIKit

protocol ProfilePageDelegate: AnyObject {
    func profilePageDidUpdateProfilePicture(_ newProfilePicture: UIImage)
}
