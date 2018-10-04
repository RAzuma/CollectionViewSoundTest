//
//  ViewController.swift
//  CollectionViewSoundTest
//
//  Created by Ryohei Azuma on 2018/10/04.
//  Copyright © 2018年 Ryohei Azuma. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var audioPlayer:AVAudioPlayer!
    @IBOutlet weak var collectionView:UICollectionView!
    
    private let callenderIdentifier = "Cell"
    private var layer2:CALayer!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: callenderIdentifier)
    }
    
    
    
    @IBAction func test(_ sender: Any) {
        
        soundStart()
        
    }
    
    private func soundStart(){
        
        // とりあえず鳴らしたいだけなのでmp3をフリー素材から
        // http://www.ne.jp/asahi/music/myuu/wave/wave.htm
        guard let path = Bundle.main.path(forResource: "test", ofType: "mp3") else {
            print("音源ファイルが見つかりません")
            return
        }
        
        // 音楽の読み込みに少し時間がかかってしまうのでロードが完了してからアニメーションと音を鳴らすと言うのも手
        self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        self.audioPlayer.delegate = self
        self.audioPlayer.play()
        
    }
    
    private func animatePulsatingLayer(layer:CALayer) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.4 //丸がどこまで大きくなるか。1がデフォルト。
        animation.duration = 0.8 //動く速さ
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.autoreverses = true //元に戻る
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: "pulsing")
    }
    
}

extension ViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: callenderIdentifier, for: indexPath)
        
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension ViewController:UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            layer2 = cell.blueView?.layer
        }
        
        animatePulsatingLayer(layer: layer2)
        
        // 実際にはどこかから音源ファイルを取得してdataに突っ込んだものが返ってくるはず。
        // 用意するのが面倒なので適当な通信を呼んで返してくるだけ。適宜置き換えてください。
        let audioUrl = URL.init(string: "http://127.0.0.1/test.php")
        URLSession.shared.dataTask(with: audioUrl!, completionHandler: { (data, response, error) in
            
            // この書き方は正しい？？
            DispatchQueue.global().async{
                DispatchQueue.main.async{
                    self.soundStart()
                    // reloadDataしないと同時に流れるはず
//                    self.collectionView.reloadData();
                    
                }
            }
            
        }).resume()
    }
    
}

// delegateについてこう言う書き方もあります。やっていることは同じ。
extension ViewController:AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("音楽終わり")
    }
    
}


