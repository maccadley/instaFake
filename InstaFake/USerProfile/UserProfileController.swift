//
//  UserProfileController.swift
//  InstaFake
//
//  Created by Admin on 27.08.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate{
    
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    var posts = [Post]()
    var userId: String?
    var isGreedView = true
    var isFinishedPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        fetchUser()
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        setupLogOutButton()
        //fetchOrderedPosts()
        
    }
    
    //Fetching photos from Firebase ordered, by the date of creation. The first made photo append in the beggining, the last at the end
    fileprivate func fetchOrderedPosts(){
        guard let uid = self.user?.uid else {return}
        let reference = Database.database().reference().child("posts").child(uid)
        reference.queryOrdered(byChild: "CreationDate").observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            guard let user = self.user else {return}
            let post = Post(user: user, dictionaty: dictionary)
            self.posts.insert(post, at: 0)
            self.collectionView?.reloadData()
        }) { (error) in
            print("Failed to fetch ordered posts due to", error)
        }
    }
    
    //MARK: - Fetching paginated posts
    fileprivate func paginatePosts(){
        guard let uid = self.user?.uid else {return}
        let reference = Database.database().reference().child("posts").child(uid)
//        var query = reference.queryOrderedByKey()
        var query = reference.queryOrdered(byChild: "creationDate")
        //Setting last post's id in query. So we get only 4 post, and then, after scrolling down
        //we get new 4 posts from Firebase database depending on posts' ids
        if posts.count > 0 {
//            let value = posts.last?.id
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
         //Give us 4 objects instead ofall of them
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            allObjects.reverse()
            if allObjects.count < 4{
                self.isFinishedPaging = true
            }
            //Everytime we get new 4 posts we delete first element of this Dictionary
            //It was done in this way, because it would constantly repeat last picture in every 4'th stack
            if self.posts.count > 0 && allObjects.count > 0{
               allObjects.removeFirst()
            }
            guard let user = self.user else {return}
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                var post = Post(user: user, dictionaty: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
            })
            self.posts.forEach({ (post) in
                print(post.id ?? "")
            })
            self.collectionView?.reloadData()
        }) { (error) in
        print("Something bad happened with pagination in posts", error)
        }
    }
    
    
//    //Fetching user's data from Firebase
    // Actualy we don't need it anymore, as this method fetches unordered data
//    fileprivate func fetchPosts(){
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        let reference = Database.database().reference().child("posts").child(uid)
//        reference.observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let dictionaries = snapshot.value as? [String : Any] else {return}
//            dictionaries.forEach({ (key, value) in
//                guard let dictionary = value as? [String : Any] else {return}
//                let post = Post(user: <#User#>, dictionaty: dictionary)
//                self.posts.append(post)
//            })
//            self.collectionView?.reloadData()
//        }) { (error) in
//            print("Failed to fetch post", error)
//        }
//    }
    
    fileprivate func setupLogOutButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
       header.user = self.user
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    //MARK: - Collection View Cells
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == self.posts.count - 1 && !isFinishedPaging{
            paginatePosts()
        }
        if isGreedView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGreedView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8 //User name profile image and username
            height += view.frame.width
            height += 50
            height += 60
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    
    var user: User?
    
    //MARK: - Fetching user
    //Fileprivate means thet you can't access this method out of this class
    fileprivate func fetchUser(){
        
        // We serach in Database, inside "users" folder
        // Then we get the dictionary that contains profileImageUrl and username
        //With this constant we checked if userId is nil, then we get the uid from current user, wich means, that we looking at page with user's accoint. If userID has some name, then user see other user's page
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        //guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
          //  self.fetchOrderedPosts()
            self.paginatePosts()
        }
}
    
    @objc func handleLogOut(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do{
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutError{
                print(signOutError)
            }
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    // MARK: - Switching Views
    func didChangedToGridView() {
        isGreedView = true
        collectionView?.reloadData()
    }
    
    func didChangedToListView() {
        isGreedView = false
        collectionView?.reloadData()
    }
    
    
}


