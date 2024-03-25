import Foundation
import AVKit

class AudioPlayerViewModel: NSObject, ObservableObject {
    @Published var fileName: String?
    @Published var player: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var totalTime: TimeInterval = 0.0
    @Published var currentTime: TimeInterval = 0.0
    
    override init() {
        super.init()
        setupAudioSession()
    }

    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }

    func setupAudio(withURL url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            totalTime = player?.duration ?? 0.0
        } catch {
            print("Error loading audio: \(error)")
        }
    }

    func playPause() {
        if let player = player {
            isPlaying.toggle()
            if isPlaying {
                player.play()
            } else {
                player.pause()
            }
        }
    }

    func seekAudio(to time: TimeInterval) {
        player?.currentTime = time
    }
    
    func updateProgress() {
        guard let player = player else { return }
        currentTime = player.currentTime
    }
}
