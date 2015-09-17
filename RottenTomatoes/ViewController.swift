//
//  ViewController.swift
//  RottenTomatoes
//
//  Created by Srinevasan Krishnamurthy on 9/12/15.
//  Copyright (c) 2015 Srinevasan Krishnamurthy. All rights reserved.
//

import UIKit

private let CELL_NAME = "com.codepath.rottentomatoes.moviecell"

class ViewController: UIViewController, UITableViewDataSource {
    var refreshControl: UIRefreshControl!
    @IBOutlet var scrollView: UIScrollView!

    
    @IBOutlet weak var movieTableView: UITableView!
    var movies: NSArray?
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return 10
        return movies?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
 /*       let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel?.text = "Row \(indexPath.row)"
        NSLog("TableView? \(cell.textLabel?.text)")
*/
        let movieDictionary = movies![indexPath.row] as! NSDictionary
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_NAME) as! MovieCell
        cell.movieTitleLabel.text = movieDictionary["title"] as? String
        cell.movieDescriptionLabel.text = movieDictionary["synopsis"] as? String
        //cell.movieTitleLabel.text = "Fast & Furious - \(indexPath.row)"
        let movie = movies![indexPath.row]
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        cell.posterImageView.setImageWithURL(url)

        return cell
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("TableView? \(movieTableView.frame)")
        getMovies()
    }
    
    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        scrollView.insertSubview(refreshControl, atIndex: 0)
        NSLog("viewdidLoad() done")
    }
    
    func onRefresh() {
        getMovies()
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func getMovies() {
        let RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=f2fk8pundhpxf77fscxvkupy"
        let request = NSMutableURLRequest(URL: NSURL(string: RottenTomatoesURLString)!)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let dictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                dispatch_sync(dispatch_get_main_queue()) {
                    self.movies = dictionary["movies"] as? NSArray
                    self.movieTableView.reloadData()
                }
              //  NSLog("Dictionary: \(dictionary)")
                NSLog("errors : \(error)")
            }else {
                
            }
        }
        task.resume()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = movieTableView.indexPathForCell(cell)
        
        let movie = movies![indexPath!.row]
        
        let movieDetailViewController = segue.destinationViewController as! MovieDetailViewController
        movieDetailViewController.movie = movie as! NSDictionary;
    }
}

class MovieCell:UITableViewCell {
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    
    @IBOutlet weak var posterImageView: UIImageView!
}
