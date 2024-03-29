//
//  VoiceRoomViewController+Chatroom.swift
//  RCE
//
//  Created by shaoshuai on 2022/1/26.
//

import UIKit
import SVProgressHUD

import RCSceneRoom


extension VoiceRoomViewController {
    @_dynamicReplacement(for: setupModules)
    private func chatroom_setupModules() {
        setupModules()
        
        micButton.addTarget(self, action: #selector(handleMicButtonClick), for: .touchUpInside)
        giftButton.addTarget(self, action: #selector(handleGiftButtonClick), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(handleMessageButtonClick), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(handleSettingClick), for: .touchUpInside)
        
        messageButton.refreshMessageCount()
        
        setupToolBarView()
        
        fetchForbidden()
    }
    
    func setupToolBarView() {
        micButton.micState = voiceRoomInfo.isOwner ? .user : .request
        chatroomView.toolBar.delegate = self
        let config = RCChatroomSceneToolBarConfig.default()
        config.commonActions = [micButton]
        if currentUserRole() == .creator {
            config.actions = [pkButton, giftButton, messageButton, settingButton]
        } else {
            config.actions = [micButton, giftButton, messageButton]
        }
        config.recordButtonEnable = !voiceRoomInfo.isOwner
        chatroomView.toolBar.setConfig(config)
    }
    
    @objc func handleMessageButtonClick() {
        RCSensorAction.textClick(voiceRoomInfo).trigger()
        let vc = ChatListViewController(.ConversationType_PRIVATE)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchForbidden() {
        voiceRoomService.forbiddenList(roomId: voiceRoomInfo.roomId) { result in
            switch result.map(RCSceneWrapper<[RCSceneRoomForbiddenWord]>.self) {
            case let .success(model):
                SceneRoomManager.shared.forbiddenWords = (model.data ?? []).map { $0.name }
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
}

extension VoiceRoomViewController: RCChatroomSceneToolBarDelegate {
    func textInputViewSendText(_ text: String) {
        RCSceneUserManager.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
            let event = RCChatroomBarrage()
            event.userId = user.userId
            event.userName = user.userName
            event.content = text
            self?.messageView.addMessage(event)
            if text.isCivilized {
                ChatroomSendMessage(event)
            }
        }
    }
    
    func audioRecordShouldBegin() -> Bool {
        if RCCoreClient.shared().isAudioHolding() {
            SVProgressHUD.showError(withStatus: "声音通道被占用，请下麦后使用")
            return false
        }
        return true
    }
    
    func audioRecordDidEnd(_ data: Data?, time: TimeInterval) {
        guard let data = data, time > 1 else { return SVProgressHUD.showError(withStatus: "录音时间太短") }
        voiceRoomService.uploadAudio(data: data, extensions: "wav") { [weak self] result in
            switch result.map(RCSceneWrapper<String>.self) {
            case let .success(response):
                guard let path = response.data else {
                    debugPrint("path is nil")
                    return
                }
                let urlString = Environment.url.absoluteString + "/file/show?path=" + path
                self?.sendMessage(urlString, time: Int(time) + 1)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func sendMessage(_ URLString: String, time: Int) {
        RCSceneUserManager.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let message = RCVRVoiceMessage()
            message.userId = user.userId
            message.userName = user.userName
            message.path = URLString
            message.duration = UInt(time)
            ChatroomSendMessage(message, messageView: self.messageView)
        }
    }
    
}

extension String {
    var civilized: String {
        return SceneRoomManager.shared.forbiddenWords.reduce(self) { $0.replacingOccurrences(of: $1, with: String(repeating: "*", count: $1.count)) }
    }
    
    var isCivilized: Bool {
        return SceneRoomManager.shared.forbiddenWords.first(where: { contains($0) }) == nil
    }
}
