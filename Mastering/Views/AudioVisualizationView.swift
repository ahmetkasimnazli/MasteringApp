import SwiftUI
import AVFoundation

struct AudioVisualizationView: View {
    let audioURL: URL
    @StateObject private var viewModel = DolbyIOViewModel()
    @State private var audioSamples: [Float] = []
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                guard audioSamples.count > 1 else {
                    return
                }

                let stepX = width / CGFloat(audioSamples.count - 1)

                var x: CGFloat = 0
                var y: CGFloat = height / 2

                path.move(to: CGPoint(x: 0, y: y))

                for sample in audioSamples {
                    x += stepX
                    y = height / 2 - CGFloat(sample) * height / 2
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(lineWidth: 2)
            .foregroundColor(.blue)
        }
        .onAppear {
            loadAudio()
        }
    }

    func loadAudio() {
        do {
            let audioFile = try AVAudioFile(forReading: audioURL)
            let format = AVAudioFormat(standardFormatWithSampleRate: audioFile.fileFormat.sampleRate, channels: 1)
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(audioFile.length))
            try audioFile.read(into: audioBuffer!)
            
            let floatArray = Array(UnsafeBufferPointer(start: audioBuffer!.floatChannelData![0], count:Int(audioBuffer!.frameLength)))
            audioSamples = floatArray
        } catch {
            print("Error loading audio: \(error.localizedDescription)")
        }
    }
}

