//
//  ContentView.swift
//  Resnet50
//
//  Created by Masao Nakama on 11/28/21.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    
    @State var classificationLabel = ""
    
//    リクエスト作成
    func createClassificationRequest() -> VNCoreMLRequest {
//        失敗する可能性を考慮してdocatch
        do{
            let configuration = MLModelConfiguration()
            
            let model = try VNCoreMLModel(for: Resnet50(configuration: configuration).model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
                performClassification(request: request)
            })
            
            return request
            
        } catch {
            fatalError("modelが読み込めません")
        }
    }
    
    func performClassification(request: VNRequest){
        guard let results = request.results else {
            return
        }
        
        let classification = results as! [VNClassificationObservation]
        
        classificationLabel = classification[0].identifier
    }
    
//    実際に画像を分類する
    func classifyImage(image: UIImage){
//        入力された画像の型をUIImageからCIImageに変換
        guard let ciImage = CIImage(image: image) else {
            fatalError("CIImageに変換できません")
        }
        
//        handler作成
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
//        request作成
        let classificationRequest = createClassificationRequest()
        
//        handkerを実行
        do{
            try handler.perform([classificationRequest])
        }catch{
            fatalError("画像分類に失敗しました")
        }
    }
    
    var body: some View {
        VStack {
            Image("cat")
                .resizable()
                .frame(width: 300, height: 300)
            
            Text(classificationLabel)
                .padding()
                .font(.title)
            
            Button(action: {
                classifyImage(image: UIImage (named: "cat")!)
            }, label: {
                Text("この画像は何の画像？")
                    .padding()
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
