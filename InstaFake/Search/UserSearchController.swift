//
//  UserSearchController.swift
//  InstaFake
//
//  Created by Admin on 01.09.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let cellId = "cellId"
    
    lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Enter username"
        search.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        search.delegate = self
        return search
    }()
    
    var filteredUsers = [User]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        navigationController?.navigationBar.addSubview(searchBar)
        let navBarForAnchor = navigationController?.navigationBar
        searchBar.anchor(top: navBarForAnchor?.topAnchor, left: navBarForAnchor?.leftAnchor, bottom: navBarForAnchor?.bottomAnchor, right: navBarForAnchor?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        fetchUsers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    //Method for filtering the searchBar text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            filteredUsers = users
        } else {
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView?.reloadData()
    }
    
    fileprivate func fetchUsers(){
        let reference = Database.database().reference().child("users")
        reference.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionatires = snapshot.value as? [String: Any] else {return}
            dictionatires.forEach({ (key, value) in
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                guard let userDictionaty = value as? [String : Any] else {return}
                let user = User(uid: key, dictionary: userDictionaty)
                self.users.append(user)
            })
            //Sorting fetching usernames in order
            self.users.sort(by: { (user1, user2) -> Bool in
                return user1.username.compare(user2.username) == .orderedAscending
            })
            self.filteredUsers = self.users
            self.collectionView?.reloadData()
        }) { (error) in
            print("Problems with search fetch", error)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item] //.user from UserSearchCell, because we cast this cell as reference to this object
   
        return cell
        }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        let user = filteredUsers[indexPath.item]
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        return CGSize(width: view.frame.width, height: 66)
    }
    
    
    
}
