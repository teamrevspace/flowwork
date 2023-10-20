//
//  RTCService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/20/23.
//

import Foundation
import Swinject
import WebRTC
import Firebase
import AVFoundation

class RoomService: NSObject, RoomServiceProtocol, ObservableObject {
    weak var delegate: RoomServiceDelegate?
    
    private var peerConnectionFactory: RTCPeerConnectionFactory
    private var peerConnection: RTCPeerConnection?
    
    @Published var audioTransceiver: RTCRtpTransceiver?
    @Published var mediaConstraints: RTCMediaConstraints
    @Published var inboundStream: RTCMediaStream?
    @Published var storeService: StoreServiceProtocol
    
    private let stunServerUrl = "stun:stun.l.google.com:19302"
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.peerConnectionFactory = RTCPeerConnectionFactory()
        
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        
        let configuration = RTCConfiguration()
        configuration.iceServers = [RTCIceServer(urlStrings: [stunServerUrl])]
        
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        self.peerConnection = self.peerConnectionFactory.peerConnection(
            with: configuration,
            constraints: constraints,
            delegate: nil
        )
        self.mediaConstraints = constraints
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        self.inboundStream = stream
        if let audio = stream.audioTracks.first {
            self.delegate?.didAddRemoteAudio(audioTrack: audio)
        }
    }
    
    func createRoom(roomId: String) {
        setupPeerConnection() { success in
            if (success) {
                self.signalCreateRoom(roomId: roomId)
            }
        }
    }
    
    private func setupPeerConnection(completion: @escaping (Bool) -> Void) {
        let audioSource = peerConnectionFactory.audioSource(with: self.mediaConstraints)
        let audioTrack = peerConnectionFactory.audioTrack(with: audioSource, trackId: "audio0")
        
        self.audioTransceiver = peerConnection?.addTransceiver(with: audioTrack)
        var error: NSError?
        self.audioTransceiver?.setDirection(.sendRecv, error: &error)
        if let error = error {
            print("Failed to set transceiver direction: \(error.localizedDescription)")
            completion(false)
        } else {
            completion(true)
        }
    }
    
    private func signalCreateRoom(roomId: String) {
        guard let peerConnection = self.peerConnection else {
            print("Peer connection is not set up.")
            return
        }
        
        peerConnection.offer(for: self.mediaConstraints) { (offer, error) in
            guard let offer = offer else {
                print("Error creating offer: \(String(describing: error))")
                return
            }
            
            peerConnection.setLocalDescription(offer, completionHandler: { (error) in
                guard error == nil else {
                    print("Error setting local description: \(String(describing: error))")
                    return
                }
                
                let rtcOffer = RTCOffer(sdp: offer.sdp, type: offer.type.rawValue)
                self.storeService.addRTCOfferToRoom(rtcOffer: rtcOffer, roomId: roomId)
            })
        }
        
        self.storeService.findRTCAnswerByRoomId(roomId: roomId) { answer in
            guard let answer = answer else { return }
            peerConnection.setRemoteDescription(answer, completionHandler: { (error) in
                print(error?.localizedDescription as Any)
            })
        }
        
        self.storeService.findRTCIceCandidateByRoomId(roomId: roomId) { candidate in
            guard let candidate = candidate else { return }
            peerConnection.add(candidate, completionHandler: { (error) in
                if let error = error {
                    print("Failed to add ICE candidate: \(error.localizedDescription)")
                } else {
                    print("Successfully added ICE candidate.")
                }
            })
        }
    }
    
    func joinRoom(roomId: String) {
        setupPeerConnection() { success in
            if success {
                self.fetchOffer(for: roomId) { offer in
                    self.processOfferAndJoinRoom(offer: offer, roomId: roomId)
                }
            }
        }
    }
    
    private func fetchOffer(for roomId: String, completion: @escaping (RTCSessionDescription) -> Void) {
        self.storeService.findRTCOfferByRoomId(roomId: roomId) { offer in
            guard let offer = offer else {
                print("Failed to retrieve the offer")
                return
            }
            completion(offer)
        }
    }
    
    private func processOfferAndJoinRoom(offer: RTCSessionDescription, roomId: String) {
        guard let peerConnection = self.peerConnection else {
            print("Peer connection is not set up.")
            return
        }
        
        peerConnection.setRemoteDescription(offer, completionHandler: { (error) in
            guard error == nil else {
                print("Error setting remote description: \(String(describing: error))")
                return
            }
            
            peerConnection.answer(for: self.mediaConstraints, completionHandler: { (answer, error) in
                guard let answer = answer else {
                    print("Error creating answer: \(String(describing: error))")
                    return
                }
                
                peerConnection.setLocalDescription(answer, completionHandler: { (error) in
                    guard error == nil else {
                        print("Error setting local description: \(String(describing: error))")
                        return
                    }
                    let rtcAnswer = RTCAnswer(sdp: answer.sdp, type: answer.type.rawValue)
                    self.storeService.addRTCAnswerToRoom(rtcAnswer: rtcAnswer, roomId: roomId)
                })
            })
        })
        
        self.storeService.findRTCIceCandidateByRoomId(roomId: roomId) { candidate in
            guard let candidate = candidate else { return }
            peerConnection.add(candidate, completionHandler: { (error) in
                if let error = error {
                    print("Failed to add ICE candidate: \(error.localizedDescription)")
                } else {
                    print("Successfully added ICE candidate.")
                }
            })
        }
    }
    
    func leaveRoom() {
        self.peerConnection?.close()
        self.peerConnection = nil
        self.audioTransceiver?.stopInternal()
    }
}
