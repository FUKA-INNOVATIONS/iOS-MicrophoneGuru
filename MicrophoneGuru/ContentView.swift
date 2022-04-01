//
//  ContentView.swift
//  MicrophoneGuru
//
//  Created by FUKA on 1.4.2022.
//

import SwiftUI
import AVKit

struct ContentView: View {
    var body: some View {
        Home()
        //.preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct Home: View {
    @State var record = false
    @State var session: AVAudioSession! // Creating instance for recording
    @State var recorder: AVAudioRecorder!
    @State var alert = false
    
    // Fetch audio files
    @State var audios: [URL] = []
    
    
    
    @State var audioPlayer: AVAudioPlayer!
    
    
    var body: some View {
        NavigationView {
            
            VStack {
                
                List(self.audios, id: \.self) { audio in
                    Text(audio.relativeString)  // Printing only file name
                    // Text(audio.absoluteURL.relativeString)
                    
                    
                    
                }
                
                Button(action: {
                    // Already Started recording
                    // Initialize
                    // Store audio file in document directory
                    
                    do {
                        
                        if self.record {
                            // Recording is already started, stop and save
                            self.recorder.stop()
                            self.record.toggle()
                            self.getAudios()    // Updating data for every record
                            return
                        }
                        
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        
                        let fileName = url.appendingPathComponent("SOSRecord\(self.audios.count+1).m4a")
                        
                        let settings = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]
                        
                        self.recorder = try AVAudioRecorder(url: fileName, settings: settings)
                        self.recorder.record()
                        self.record.toggle()
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                        
                        if self.record {
                            Circle()
                                .stroke(Color.white, lineWidth: 6)
                                .frame(width: 85, height: 85)
                        }
                    }
                }
                .padding(.vertical, 25)
            }
            .navigationBarTitle("Record audio")
        }
        .alert(isPresented: self.$alert, content: {
            Alert(title: Text("Error"), message: Text("Enable access"))
        })
        .onAppear {
            do {
                self.session = AVAudioSession.sharedInstance() // Initializing
                try self.session.setCategory(.playAndRecord)
                
                // Requesting permission
                // This requires microphone usage description in info.plist
                self.session.requestRecordPermission { (status) in
                    
                    if !status {
                        self.alert.toggle() // Alert error message
                    } else {
                        // Permission is granted, fetch all data
                        self.getAudios()
                    }
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    func getAudios() {
        
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            // Fetch all data from document directory
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            self.audios.removeAll() // Updated means remove all data
            
            for audio in result {
                self.audios.append(audio)
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
