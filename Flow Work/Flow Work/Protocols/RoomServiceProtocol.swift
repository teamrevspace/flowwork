//
//  RTCServiceProtocol.swift
//  Flow Work
//
//  Created by Allen Lin on 10/20/23.
//

import WebRTC

protocol RoomServiceDelegate: AnyObject {
    func didAddRemoteAudio(audioTrack: RTCAudioTrack)
    func didAddRemoteVideo(videoTrack: RTCVideoTrack)
}

protocol RoomServiceProtocol {
    var delegate: RoomServiceDelegate? { get set }
    
    var audioTransceiver: RTCRtpTransceiver? { get set }
    var mediaConstraints: RTCMediaConstraints { get set }
    var inboundStream: RTCMediaStream? { get }
    
    func createRoom(roomId: String)
    func joinRoom(roomId: String)
    func leaveRoom()
}
