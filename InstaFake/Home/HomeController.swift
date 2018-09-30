//
//  HomeController.swift
//  InstaFake
//
//  Created by Admin on 01.09.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate{
    
    let cellId = "cellId"
    var posts = [Post]()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        collectionView?.backgroundColor = .white
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        let refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControll
        setupNavigationItems()
        
        fetchAllPosts()
    }
    
    @objc func handleRefresh(){
        posts.removeAll()
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts(){
        fetchPosts()
        fetchFollowingUserIds()
    }
    
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userIdDectionary = snapshot.value as? [String : Any] else {return}
            userIdDectionary.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user: user)
                })
            })
        }) { (error) in
            print("Could not fetch followign users ids", error)
        }
    }
    
    fileprivate func fetchPosts(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User){
        let reference = Database.database().reference().child("posts").child(user.uid)
        reference.observeSingleEvent(of: .value, with: { (snapshot) in
            self.collectionView?.refreshControl?.endRefreshing()
            guard let dictionaries = snapshot.value as? [String : Any] else {return}
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String : Any] else {return}
                var post = Post(user: user, dictionaty: dictionary)
                post.id = key
                guard let uid = Auth.auth().currentUser?.uid else {return}
                Database.database().reference().child("likes").child(key).child(uid).observe(.value, with: { (snapshot) in
                    if let value = snapshot.value as? Int, value == 1{
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    self.posts.append(post)
                    self.posts.sort(by: { (postOne, postTwo) -> Bool in
                        return postOne.creationDate.compare(postTwo.creationDate) == .orderedDescending
                    })
                     self.collectionView?.reloadData()
                }, withCancel: { (error) in
                    print("Error with observing likes:", error)
                })
            })
        }) { (error) in
            print("Failed to fetch post", error)
        }
    }
    
    @objc func handleUpdateFeed(){
        handleRefresh()
    }
    
    func setupNavigationItems(){
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    @objc func handleCamera(){
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
    //MARK: - Methods for collection view
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 //User name profile image and username
        height += view.frame.width
        height += 50
        height += 60
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        cell.post = posts[indexPath.item]
        
        cell.delegate = self
        
        return cell
    }
    
    //Pressing comment button logic
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    //Pressing like button logic
    
    func didLike(for cell: HomePostCell) {
        print("Handling inside controller")
        guard let indexPath = collectionView?.indexPath(for: cell) else {return}
        var post = self.posts[indexPath.item]
        print(post.caption)
        guard let postId = post.id else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = [uid: post.hasLiked == true ? 0 : 1]
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (error, _) in
            if let error = error {
                print("Failed to send like due to:", error)
                return
            }
            print("Successfuly liked post.")
            post.hasLiked = !post.hasLiked
            self.posts[indexPath.item] = post
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
    
    
    
}
