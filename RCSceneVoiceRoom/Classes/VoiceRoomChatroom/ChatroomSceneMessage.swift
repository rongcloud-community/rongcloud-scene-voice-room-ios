//
//  ChatroomSceneMessage.swift
//  RCE
//
//  Created by shaoshuai on 2022/1/27.
//

import Foundation

struct ChatroomError: Error, LocalizedError {
    let msg: String
    
    init(_ msg: String) {
        self.msg = msg
    }
    
    var errorDescription: String? {
        return msg
    }
}

func ChatroomSendMessage(_ content: RCMessageContent,
                         result:((Result<Int, ChatroomError>) -> Void)? = nil)
{
    guard let room = SceneRoomManager.shared.currentRoom else {
        result?(.failure(ChatroomError("没有加入房间")))
        return
    }
    RCChatroomMessageCenter.sendChatMessage(room.roomId, content: content) { code, mId in
        if code == .RC_SUCCESS {
            result?(.success(mId))
        } else {
            result?(.failure(ChatroomError("消息发送失败：\(code.rawValue)")))
        }
    }
}

func ChatroomSendMessage(_ content: RCMessageContent, messageView: RCChatroomSceneMessageView?)
{
    guard let roomId = SceneRoomManager.shared.currentRoom?.roomId else {
        SVProgressHUD.showError(withStatus: "没有加入房间")
        return
    }
    RCChatroomMessageCenter.sendChatMessage(roomId, content: content) { code, mId in
        if code == .RC_SUCCESS {
            if let message = content as? RCChatroomSceneMessageProtocol {
                messageView?.addMessage(message)
            }
        } else {
            let msg = "消息发送失败：\(code.rawValue)"
            SVProgressHUD.showError(withStatus: msg)
        }
    }
}
