//
//  Deleteable.swift
//  Timeline
//
//  Created by Valentin Knabel on 10.12.15.
//  Copyright © 2015 Conclurer GbR. All rights reserved.
//

protocol Deleteable {
    // TODO: Add support for ConclurerHook
    func delete(completion: (error: String?) -> ())
}

// extension User: Deleteable { }
extension Timeline: Deleteable {
    func delete(completion: (error: String?) -> ()) {
        if(self.groupTimeline)
        {
            Storage.performRequest(ApiRequest.DeleteGroupTimeline(self.state.uuid!), completion: { (json) -> Void in
                if let error = json["error"] as? String {
                    defer { completion(error: error) }
                } else {
                    completion(error: nil)
                    let moms = self.moments
                    async {
                        for m in moms {
                            if let url = m.localVideoURL {
                                do {
                                    try NSFileManager.defaultManager().removeItemAtURL(url)
                                } catch {
                                    print("Timeline.delete(completion:) could not remove \(url): \n\(error)")
                                }
                            }
                        }
                    }
                }
            })

        }
        else
        {
            Storage.performRequest(ApiRequest.DestroyTimeline(self.state.uuid!), completion: { (json) -> Void in
                if let error = json["error"] as? String {
                    defer { completion(error: error) }
                } else {
                    completion(error: nil)
                    let moms = self.moments
                    async {
                        for m in moms {
                            if let url = m.localVideoURL {
                                do {
                                    try NSFileManager.defaultManager().removeItemAtURL(url)
                                } catch {
                                    print("Timeline.delete(completion:) could not remove \(url): \n\(error)")
                                }
                            }
                        }
                    }
                }
            })
  
        }
//        Storage.performRequest(ApiRequest.DestroyTimeline(self.state.uuid!), completion: { (json) -> Void in
//            if let error = json["error"] as? String {
//                defer { completion(error: error) }
//            } else {
//                completion(error: nil)
//                let moms = self.moments
//                async {
//                    for m in moms {
//                        if let url = m.localVideoURL {
//                            do {
//                                try NSFileManager.defaultManager().removeItemAtURL(url)
//                            } catch {
//                                print("Timeline.delete(completion:) could not remove \(url): \n\(error)")
//                            }
//                        }
//                    }
//                }
//            }
//        })
    }
}
