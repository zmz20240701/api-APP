//
//  SongViewModel.swift
//  YT-Vapor-APP
//
//  Created by 赵康 on 2024/9/26.
//

import Foundation

class SongViewModel: ObservableObject {
    @Published var songs = [Song]()
   
   // 异步获取数据
    func fetchSong() async throws {
        let urlString = Constants.baseURL + Endpoints.songs
        
        guard let url = URL(string: urlString) else {
            throw HTTPError.badURL
        }
        
        let songsReceived: [Song] = try await HttpClient.shared.fetch(url: url)
        
        // 回到主线程更新 UI 数据
        DispatchQueue.main.async {
            self.songs = songsReceived
        }
    }
    
    func delete(at offsets: IndexSet) { // 从songs 数组中删除指定索引处的歌曲, 可能指定一个或多个
        offsets.forEach { i in // 分别为每一个指定的索引执行删除操作
            guard let songID = songs[i].id else { // songs[i]代表第 i 个被选中的歌曲
                return
            }
            
            // 生成删除请求的 URL
            guard let url = URL(string: Constants.baseURL + Endpoints.songs + "/\(songID)") else {
                return
            }
            Task {
                do {
                    try await HttpClient.shared.delete(at: songID, url: url)
                    try await fetchSong() // 这一步和 remove 那一步任选其中之一
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        // 前边的代码只是向服务器发送了删除请求, 
//        songs.remove(atOffsets: offsets)
    }
}
///虽然服务器上的数据会被更新，但如果没有 songs.remove(atOffsets:)，UI 不会立刻反映删除操作。用户必须关闭并重新打开界面，触发 onAppear 才能看到最新的状态。
/// 用户体验不佳：没有即时更新会让用户误以为删除操作失败。因此我们使用 onDelete 方法进行删除操作，并且手动从 songs 数组中移除被删除的歌曲，确保在 UI 中实时显示。

