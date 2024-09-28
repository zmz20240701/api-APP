//
//  ContentView.swift
//  YT-Vapor-APP
//
//  Created by 赵康 on 2024/9/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = SongViewModel()
    @State private var modal: ModelType? = nil
    // 这个属性需要在用户与界面交互时动态更新
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.songs) { song in
                    Button {
                        modal = .update(song)
                    } label: {
                        Text(song.title)
                            .font(.title3)
                            .foregroundStyle(Color(.label))
                    }
                }
                .onDelete { indexSet in
                    viewModel.delete(at: indexSet)
                }
            }
            .toolbar(content: {
                Button {
                    modal = .add //点击按钮时, 设置modal为.add, 显示添加歌曲的表单
                } label: {
                    Label("添加歌曲", systemImage: "plus.circle")
                }

            })
            .navigationTitle(Text("🎵 音乐"))
        }
        .sheet(item: $modal, onDismiss: { // 在表单中填写过数据并成功后, 执行下边的动作, 我们在addOrUpdate视图中定义了完成传输后执行dismiss
            Task {
                do {
                    try await viewModel.fetchSong()
                } catch {
                    print("❌ Error fetching songs: \(error)")
                }
            }
        }, content: { modal in
            switch modal {
            case .add:
                AddOrUpdateSongView(viewModel: AddOrUpdateSongViewModel())
            case .update(let song):
                AddOrUpdateSongView(viewModel: AddOrUpdateSongViewModel(existingSong: song))
            }
        })
        .onAppear { // 界面出现时执行加载函数
            Task {
                do {
                    try await viewModel.fetchSong()
                } catch {
                    print("❌ Error fetching songs: \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
