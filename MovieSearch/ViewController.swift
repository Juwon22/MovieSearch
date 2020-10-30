//
//  ViewController.swift
//  MovieSearch
//
//  Created by Olajuwon Adeola on 10/29/20.
//

import UIKit
import SafariServices

// UI (tableview)
// Network request
// tap a cell for more info
// custom cell

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var table: UITableView!
    @IBOutlet var field: UITextField!
    
    var movies = [Movie]()

    override func viewDidLoad() {
        table.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.identifier)
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        field.delegate = self
        
    }
    
    // Field
    func searchMovies() {
        field.resignFirstResponder()
        
        guard let text = field.text, !text.isEmpty else {
            return
        }
        
        let queryText = text.replacingOccurrences(of: " ", with: "%20")
        
        //4a5bdd01
        let url = URL(string:"https://www.omdbapi.com/?apikey=4a5bdd01&s=\(queryText)&type=movie")!
        self.movies.removeAll()
        URLSession.shared.dataTask(with: url,
                                   completionHandler: {data, response, error in
                                    
                                    // make sure no error, data response
                                    guard let data = data, error == nil else {
                                        return
                                    }
                                    //decode data into Movie struct
                                    var result: MovieResult?
                                    
                                    do {
                                        result = try JSONDecoder().decode(MovieResult.self, from: data)
                                        
                                    
                                    }
                                    catch {
                                        print(error.localizedDescription)
                                        print("error")
                                    }
                                    guard let finalResult = result else {
                                        return
                                    }
                                    
//                                    print("\(finalResult.Search.first?.Title ?? "")")
                                    
                                    let theMovies = finalResult.Search
                                    self.movies.append(contentsOf: theMovies)
                            
                                    DispatchQueue.main.async {
                                        self.table.reloadData()
                                    }
                                    
                                    
                                   }).resume()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchMovies()
        return true
    }
    
    // Tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as! MovieTableViewCell
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Show movie details
        let url = "https://www.imdb.com/title/\(movies[indexPath.row].imdbID)/"
        
        let vc = SFSafariViewController(url: URL(string: url)!)
        present(vc, animated: true, completion: nil)
    }


}


struct Movie: Codable {
    let Title: String
    let Year: String
    let imdbID: String
    let _type: String
    let Poster: String
    
    private enum CodingKeys: String, CodingKey {
        case Title
        case Year
        case imdbID
        case _type = "Type"
        case Poster
    }
    
}



struct MovieResult: Codable {
    let Search: [Movie]
}
