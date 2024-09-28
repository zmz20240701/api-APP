//
//  AddSongView.swift
//  YT-Vapor-APP
//
//  Created by 赵康 on 2024/9/27.
//

import SwiftUI

struct AddOrUpdateSongView: View {
    @StateObject var viewModel: AddOrUpdateSongViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            TextField("歌曲名称", text: $viewModel.title)
                .font(.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button {
                viewModel.addOrUpdateSong {
                    dismiss()
                }
            } label: {
                Text(viewModel.buttonTitle)
            }

        }
    }
}
