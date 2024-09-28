//
//  AddOrUpdateSongViewModel.swift

//  YT-Vapor-APP
//
//  Created by 赵康 on 2024/9/27.
//

import Foundation

class AddOrUpdateSongViewModel: ObservableObject {
    @Published var title = ""
    
    var songID: UUID?
    
    var isUpdating: Bool {
        songID != nil // 如果 ID 存在那么说明在执行的是更新的操作, 否则反之
    }
    
    var buttonTitle: String {
        !isUpdating ? "添加歌曲" : "更新歌曲"
    }
    
    // 这个视图有两种模式, 一种是采用默认属性值
    init() {} //
    
    // 另一种是付新值
    init(existingSong: Song) {
        self.title = existingSong.title
        self.songID = existingSong.id
    }
    func addOrUpdateSong(completion: @escaping () -> Void) {
        Task {
            do {
                if isUpdating {
                    try await updateSong()
                } else {
                    try await addSong()
                }
            } catch {
                print("Error: \(error)")
            }
            completion()
        }
    }
    
    func addSong() async throws {
        let urlString = Constants.baseURL + Endpoints.songs
        
        guard let url = URL(string: urlString) else {
            throw HTTPError.badURL
        }
        
        let song = Song(id: nil, title: title) // 添加歌曲, 不存在 ID
        
        try await HttpClient.shared.send(to: url, object: song, httpMethod: HttpMethod.POST.rawValue)
    }
    
    func updateSong() async throws {
        let urlString = Constants.baseURL + Endpoints.songs
        
        guard let url = URL(string: urlString) else {
            throw HTTPError.badURL
        }
        
        let song = Song(id: songID, title: title) // 更新歌曲,信息都存在
        
        try await HttpClient.shared.send(to: url, object: song, httpMethod: HttpMethod.PUT.rawValue)
    }
}
