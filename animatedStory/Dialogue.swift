//
//  Dialogues.swift
//  animatedStory
//
//  Created by Роман Важник on 29.03.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit

struct Dialogue {
    let characterImage: UIImage
    let characterText: String
}

let dialogues = [
    Dialogue(characterImage: UIImage(named: "Burns")!, characterText: "And... make yourselves at home."),
    Dialogue(characterImage: UIImage(named: "Bart")!, characterText: "Hear that, Dad? You can lie around in your underwear and scratch yourself."),
    Dialogue(characterImage: UIImage(named: "AngryHomer")!, characterText: "Now, you listen to me..."),
    Dialogue(characterImage: UIImage(named: "Burns")!, characterText: "Trouble, Simpson?"),
    Dialogue(characterImage: UIImage(named: "SimpleHomer")!, characterText: "No. just congratulating the son on a fine joke about his old man.")
]
