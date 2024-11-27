//
//  GameScene.swift
//  rockPaperScissors
//
//  Created by Leo Hohenberger on 04.11.24.
//


import SpriteKit
import UIKit // Für haptisches Feedback

// Enumeration für das Spielergebnis
enum GameResult {
    case win
    case lose
    case draw
}

// Physik-Kategorien
struct PhysicsCategory {
    // static let none: UInt32 = 0
    static let playerFist: UInt32 = 0x1 << 0 // Kategorie für die Spielerfaust
    static let computerFist: UInt32 = 0x1 << 1 // Kategorie für die Computerfaust
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - UI-Elemente
    private var countdownLabel: SKLabelNode!
    private var roundLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode! // Highscore Label
    private var resultLabel: SKLabelNode! // Neues Ergebnis-Label
    private var tutorialIndicator: SKSpriteNode? // Tutorial-Indikator

    // MARK: - Symbole für Spieler und Computer
    private var playerSymbol: SKSpriteNode!
    private var computerSymbol: SKSpriteNode!

    // MARK: - Spielzustände
    private var selectedSymbol: String?
    private var currentRound = 1
    private var hasSelected = false

    // Highscore
    private var highScore = 0

    // Ursprüngliche Größen und Schriftgrößen
    private var originalPlayerFistSize: CGSize!
    private var originalComputerFistSize: CGSize!
    private var originalCountdownFontSize: CGFloat!
    private var originalRoundLabelFontSize: CGFloat!
    private var originalResultFontSize: CGFloat! // Für das Ergebnis-Label

    // Kollisionen zählen
    private var collisionCount = 0

    // Variable, um Kollisionen zu kontrollieren
    private var isColliding = false

    // Variable, um zu verfolgen, ob die Faust berührt wird
    private var isTouchingFist = false

    // Ursprüngliche Positionen
    private var playerOriginalPosition: CGPoint!
    private var computerOriginalPosition: CGPoint!

    // Mindestabstand für die nächste Kollision
    private let minDistance: CGFloat = 350.0 // Der Abstand ann je nach Bedarf eingestellt werden

    // Für haptisches Feedback
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium) // .medium definirt die Intensität des Feedbacks -> Der Feedback-Generator gehört zur Klasse `UIImpactFeedbackGenerator`

    // Variable für die Tutorial-Animation
    private var tutorialFistAction: SKAction?

    // MARK: - Lebenszyklus-Methoden

    override func didMove(to view: SKView) {
        loadHighScore()
        setupScene()

        // Physik-Welt konfigurieren
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self

        // Start der Runde
        startNewRound()
    }

    override func update(_ currentTime: TimeInterval) {
        // Überprüfe den Abstand zwischen den Fäusten
        let dx = playerSymbol.position.x - computerSymbol.position.x
        let dy = playerSymbol.position.y - computerSymbol.position.y
        let distance = sqrt(dx * dx + dy * dy) // Gesamtdistanz zwischen den Fäusten

        if distance > minDistance { // Setzt den Kollisionsstatus zurück, wenn die Fäuste den Mindestabstand überschreiten
            isColliding = false
        }
    }

    // MARK: - Setup-Methoden

    func setupScene() {
        // Basis-Schriftgröße basierend auf der Bildschirmhöhe
        let baseFontSize = self.size.height * 0.03 // 3% der Bildschirmhöhe

        // Initialisiere Labels
        // Countdown Label
        countdownLabel = childNode(withName: "countdownLabel") as? SKLabelNode
        setResponsiveFontSize(for: countdownLabel, fontSize: baseFontSize)
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.numberOfLines = 2

        // Speichere die ursprüngliche Schriftgröße
        originalCountdownFontSize = countdownLabel.fontSize

        // Runden Label
        roundLabel = childNode(withName: "rundeLabel") as? SKLabelNode
        setResponsiveFontSize(for: roundLabel, fontSize: baseFontSize)
        roundLabel.verticalAlignmentMode = .center
        roundLabel.horizontalAlignmentMode = .center

        // Speichere die ursprüngliche Schriftgröße
        originalRoundLabelFontSize = roundLabel.fontSize

        // Highscore Label
        highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode
        setResponsiveFontSize(for: highScoreLabel, fontSize: baseFontSize)

        // Highscore anzeigen
        updateHighScoreLabel()

        // Ergebnis-Label initialisieren
        resultLabel = childNode(withName: "resultLabel") as? SKLabelNode
        resultLabel.text = ""
        resultLabel.alpha = 0 // Startet unsichtbar
        resultLabel.zPosition = 20 // Über anderen Elementen
        resultLabel.horizontalAlignmentMode = .center
        resultLabel.verticalAlignmentMode = .center
        originalResultFontSize = resultLabel.fontSize

        // Tutorial-Indikator initialisieren
        tutorialIndicator = childNode(withName: "//TutorialIndicator") as? SKSpriteNode

        if let tutorialIndicator = tutorialIndicator {
            tutorialIndicator.isHidden = true // Startet unsichtbar; wird in startNewRound() aktiviert
            tutorialIndicator.setScale(0.3) // Skalierung auf 30% setzen (ursprünglich 0.5)
       
        }

        // Initialisiere Symbole
        playerSymbol = childNode(withName: "rechteFaust") as? SKSpriteNode // Spieler
        computerSymbol = childNode(withName: "linkeFaust") as? SKSpriteNode // Computer

        // Setze die zPositionen
        playerSymbol.zPosition = 10 // Spielerfaust im Vordergrund
        computerSymbol.zPosition = 5 // Computerfaust dahinter

        // Speichere die ursprünglichen Größen der Fäuste
        originalPlayerFistSize = playerSymbol.size
        originalComputerFistSize = computerSymbol.size

        // Speichere die ursprünglichen Positionen
        playerOriginalPosition = playerSymbol.position
        computerOriginalPosition = computerSymbol.position

        updateRoundLabel()

        // Bereite den Feedback-Generator vor
        feedbackGenerator.prepare()
    }

    func startNewRound() {
        collisionCount = 0 // Kollisionen zurücksetzen
        isColliding = false // Kollisionen zurücksetzen
        selectedSymbol = nil
        hasSelected = false
        countdownLabel.text = "Wähle dein Symbol"
        countdownLabel.fontSize = originalCountdownFontSize // Schriftgröße zurücksetzen
        roundLabel.fontSize = originalRoundLabelFontSize // Schriftgröße zurücksetzen
        updateRoundLabel()
        resetSymbolHighlights()

        // Ergebnis-Label zurücksetzen
        resultLabel.text = ""
        resultLabel.alpha = 0
        resultLabel.fontSize = originalResultFontSize

        // Fäuste auf Startpositionen zurücksetzen
        playerSymbol.position = playerOriginalPosition
        computerSymbol.position = computerOriginalPosition

        // Symbole zurück auf Fäuste setzen und Größe zurücksetzen
        let fistTexture = SKTexture(imageNamed: "Faust")
        playerSymbol.texture = fistTexture
        playerSymbol.size = originalPlayerFistSize // Ursprüngliche Größe wiederherstellen

        computerSymbol.texture = fistTexture
        computerSymbol.size = originalComputerFistSize // Ursprüngliche Größe wiederherstellen

        // Touch-Interaktionen wieder aktivieren
        isUserInteractionEnabled = true

        // Physik-Körper aktualisieren
        setupFistPhysics()

        // Feedback-Generator vorbereiten
        feedbackGenerator.prepare()

        // Tutorial-Indikator sichtbar machen und Animation starten
        if let tutorialIndicator = tutorialIndicator {
            tutorialIndicator.isHidden = false
            startTutorialAnimations()
        }
    }

    func setupFistPhysics() {
        // Spielerfaust
        playerSymbol.physicsBody = SKPhysicsBody(texture: playerSymbol.texture!, size: playerSymbol.size)
        playerSymbol.physicsBody?.isDynamic = true // Spielerfaust ist dynamisch
        playerSymbol.physicsBody?.allowsRotation = false // Verhindert das die Spielerfaust sich dreht
        playerSymbol.physicsBody?.affectedByGravity = false // Verhindert das die Faust durch die Schwerkraft nach unten gezogen wird
        playerSymbol.physicsBody?.categoryBitMask = PhysicsCategory.playerFist // Weist dem Physikkörper die Kategorie playerFist zu
        playerSymbol.physicsBody?.contactTestBitMask = PhysicsCategory.computerFist // Spielerfaust soll auf Kontakt zur Computerfaust achten
        playerSymbol.physicsBody?.collisionBitMask = PhysicsCategory.computerFist // Erlaubt physische Interaktionen mit der Computerfaust
        playerSymbol.physicsBody?.friction = 3 // Bestimmt die Reibung an dem Objekt -> führt zu geringerem "Herumspringen der Spielerfaust"
        playerSymbol.physicsBody?.restitution = 0 // Kein Abprallen
        playerSymbol.physicsBody?.linearDamping = 5.0 // Dämpfung, um Fliegen zu verhindern

        // Computerfaust
        computerSymbol.physicsBody = SKPhysicsBody(texture: computerSymbol.texture!, size: computerSymbol.size)
        computerSymbol.physicsBody?.isDynamic = false // Computerfaust ist statisch
        computerSymbol.physicsBody?.allowsRotation = false // Verhindert das sich die Computerfaust dreht
        computerSymbol.physicsBody?.categoryBitMask = PhysicsCategory.computerFist // Weist dem Physikkörper die Kategorie computerFist zu
        computerSymbol.physicsBody?.contactTestBitMask = PhysicsCategory.playerFist // Ermöglicht die Erkennung, wenn die Spielerfaust die Computerfaust berührt.
        computerSymbol.physicsBody?.collisionBitMask = PhysicsCategory.playerFist // Kollision mit Spielerfaust
    }

    // MARK: - Spiel-Logik

    func showResult() {
        // Physik-Körper entfernen, um weitere Kollisionen zu verhindern
        playerSymbol.physicsBody = nil
        computerSymbol.physicsBody = nil

        // Touch-Interaktionen während der Ergebnisanzeige deaktivieren
        isUserInteractionEnabled = false

        // Zeige das ausgewählte Symbol des Spielers
        let selected = selectedSymbol!
        let playerTexture = SKTexture(imageNamed: selected)
        playerSymbol.texture = playerTexture
        playerSymbol.size = CGSize(width: playerTexture.size().width * 0.5, height: playerTexture.size().height * 0.5)

        // Wähle ein zufälliges Symbol für den Computer
        let symbols = ["Stein", "Papier", "Schere"]
        let computerChoice = symbols.randomElement()!
        let computerTexture = SKTexture(imageNamed: computerChoice)
        computerSymbol.texture = computerTexture
        computerSymbol.size = CGSize(width: computerTexture.size().width * 0.5, height: computerTexture.size().height * 0.5)

        // Bestimme den Gewinner
        let result = determineWinner(playerChoice: selectedSymbol!, computerChoice: computerChoice)

        // Zeige das Ergebnis an
        switch result {
        case .win:
            currentRound += 1
            resultLabel.text = "Gewonnen!"
            resultLabel.alpha = 1 // Ergebnis-Label einblenden

            
            // Überprüfung und Aktualisierung des Highscores nach einem Gewinn
            if currentRound > highScore { // Überprüft, ob die aktuelle Runde (currentRound) den gespeicherten Highscore übertrifft
                highScore = currentRound // Setzt den neuen Highscore auf die aktuelle Runde.
                saveHighScore() // Speichert den neuen Highscore in UserDefaults.
                updateHighScoreLabel() // Aktualisiert das Label, um den neuen Highscore anzuzeigen.
            }

            // Feuerwerk anzeigen
            showFirework()

            // Gewinn-Sound abspielen
            playWinSound()

        case .lose:
            currentRound = 1
            resultLabel.text = "Verloren!"
            resultLabel.alpha = 1 // Ergebnis-Label einblenden

            // Verloren-Effekte anzeigen
            showLoseEffect()
            animateLoseLabel()
            playLoseSound()

        case .draw:
            resultLabel.text = "Unentschieden!"
            resultLabel.alpha = 1 // Ergebnis-Label einblenden

            // Unentschieden-Sound abspielen
            playDrawSound()
        }

        updateRoundLabel()

        // Ergebnislabel nach einer 3-sekündigen Pause ausblenden und neue Runde starten
        let wait = SKAction.wait(forDuration: 3.0)
        let hideResultLabel = SKAction.fadeOut(withDuration: 0.5)
        let newRound = SKAction.run { self.startNewRound() }
        let sequence = SKAction.sequence([wait, hideResultLabel, newRound])
        resultLabel.run(sequence)
    }

    func determineWinner(playerChoice: String, computerChoice: String) -> GameResult {
        if playerChoice == computerChoice {
            return .draw // Unentschieden
        } else if (playerChoice == "Stein" && computerChoice == "Schere") ||
                    (playerChoice == "Schere" && computerChoice == "Papier") ||
                    (playerChoice == "Papier" && computerChoice == "Stein") {
            return .win // Spieler gewinnt
        } else {
            return .lose // Spieler verliert
        }
    }

    // MARK: - Touch-Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Überprüft, ob eine Berührung stattgefunden hat, und holt die erste Berührung aus dem Set.
        guard let touch = touches.first else { return }
        
        // Bestimmt die Position der Berührung in der Szene.
        let location = touch.location(in: self)
        
        // Findet alle Nodes, die sich an der Berührungsposition befinden.
        let nodesAtPoint = nodes(at: location)

        // Überprüft, ob der Spieler bereits ein Symbol ausgewählt hat.
        if !hasSelected {
            // Iteriert über alle Nodes, die an der Berührungsposition gefunden wurden.
            for node in nodesAtPoint {
                if node.name == "steinButton" {
                    // Wenn der Spieler "Stein" ausgewählt hat:
                    selectedSymbol = "Stein" // Speichert die Auswahl.
                    animateButtonPress(node) // Spielt die Animation für den Button ab.
                    highlightSelectedSymbol(node) // Hebt das ausgewählte Symbol hervor.
                    hasSelected = true // Markiert, dass der Spieler ein Symbol gewählt hat.
                    countdownLabel.text = "Klopfe 3 Mal gegen die Faust!" // Aktualisiert die Anweisung für den Spieler.
                    adjustFontSizeToFit(label: countdownLabel, maxWidth: self.size.width * 0.7) // Passt die Schriftgröße an die verfügbare Breite an.
                    removeTutorialAnimations() // Entfernt die Tutorial-Animation.
                } else if node.name == "papierButton" {
                    // Wenn der Spieler "Papier" ausgewählt hat:
                    selectedSymbol = "Papier"
                    animateButtonPress(node)
                    highlightSelectedSymbol(node)
                    hasSelected = true
                    countdownLabel.text = "Klopfe 3 Mal gegen die Faust!"
                    adjustFontSizeToFit(label: countdownLabel, maxWidth: self.size.width * 0.7)
                    removeTutorialAnimations()
                } else if node.name == "schereButton" {
                    // Wenn der Spieler "Schere" ausgewählt hat:
                    selectedSymbol = "Schere"
                    animateButtonPress(node)
                    highlightSelectedSymbol(node)
                    hasSelected = true
                    countdownLabel.text = "Klopfe 3 Mal gegen die Faust!"
                    adjustFontSizeToFit(label: countdownLabel, maxWidth: self.size.width * 0.7)
                    removeTutorialAnimations()
                } else if node.name == "backButton" {
                    // Wenn der Zurück-Button angeklickt wurde:
                    goToStartScene() // Wechselt zurück zur Startszene.
                    return // Beendet die Methode, da keine weitere Aktion erforderlich ist.
                }
            }
        } else {
            // Wenn der Spieler bereits ein Symbol ausgewählt hat:
            // Überprüft, ob die Spielerfaust (playerSymbol) an der Berührungsposition liegt.
            if playerSymbol.contains(location) {
                isTouchingFist = true // Markiert, dass die Faust berührt wird.
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasSelected && isTouchingFist else { return } // Nur bewegen, wenn ein Symbol ausgewählt wurde und die Faust berührt wird
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Bewege die Spielerfaust direkt unter den Finger
        playerSymbol.position = location

        // Setze die Geschwindigkeit auf Null, um unerwünschte Bewegungen zu verhindern
        playerSymbol.physicsBody?.velocity = .zero
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchingFist = false
        // Bewege die Spielerfaust zurück zur Originalposition
        playerSymbol.position = playerOriginalPosition
        playerSymbol.physicsBody?.velocity = .zero
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchingFist = false
        // Bewege die Spielerfaust zurück zur Originalposition
        playerSymbol.position = playerOriginalPosition
        playerSymbol.physicsBody?.velocity = .zero
    }

    // MARK: - Physik-Kollisionen

    func didBegin(_ contact: SKPhysicsContact) {  // wird aufgerufen wenn zwei Physikkörper miteinander kollidieren
        let firstBody: SKPhysicsBody      // Variablen um die beteiligten Physikkörper der Kollision zu speichern
        let secondBody: SKPhysicsBody
        // Durch Sortierung anhand der categoryBitMask wird sichergestellt, dass firstBody immer die niedrigere Bitmasken-Kategorie hat. Dies vereinfacht die spätere Vergleichslogik.
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if firstBody.categoryBitMask == PhysicsCategory.playerFist && secondBody.categoryBitMask == PhysicsCategory.computerFist { // Prüfung ob Kollision stattgefunden hat
            // isColliding stellt sicher das eine Kollision nur einmal gzählt wird -> bis Fäuste sich wieder voneinander entfernen
            if !isColliding {
                isColliding = true
                collisionCount += 1
            
                // Haptisches Feedback auslösen
                feedbackGenerator.impactOccurred()

                // Feedback an den Spieler geben
                countdownLabel.text = "Kollisionen: \(collisionCount) / 3"

                if collisionCount >= 3 {
                    // Nach drei Kollisionen das Ergebnis anzeigen
                    showResult()
                }
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        // Nichts tun, das Zurücksetzen erfolgt in der update-Methode
    }

    // MARK: - Hilfsmethoden

    func adjustFontSizeToFit(label: SKLabelNode, maxWidth: CGFloat) {
        let originalFontSize = label.fontSize
        label.fontSize = originalFontSize // Starten Sie mit der aktuellen Schriftgröße

        while label.frame.width > maxWidth && label.fontSize > 10 {
            label.fontSize -= 1
        }
    }

    func setResponsiveFontSize(for label: SKLabelNode, fontSize: CGFloat) {
        label.fontSize = fontSize
    }

    func updateRoundLabel() {
        roundLabel.text = "Runde: \(currentRound)"
    }
    // Methode zur Aktualisierung des Highscore-Labels auf dem Bildschirm
    func updateHighScoreLabel() {
        highScoreLabel.text = "Highscore: \(highScore)" // Setzt dn Text des Labls auf den aktullen Wrt von "highScore"
    }
    // Methode zum Laden des gespeicherten Highscores aus UserDefaults
    func loadHighScore() {
        let defaults = UserDefaults.standard // Zugriff auf die standardmäßigen Benutzereinstellungen
        highScore = defaults.integer(forKey: "HighScore") // Holt den Wert für den Schlüssel "HighScore". Standardwert ist 0, wenn kein Wert existiert.
    }
    // Methode zum Speichern des aktuellen Highscores in UserDefaults
    func saveHighScore() {
        let defaults = UserDefaults.standard // Zugriff auf die standardmäßigen Benutzereinstellungen
        defaults.set(highScore, forKey: "HighScore") // Speichert den aktuellen Highscore unter dem Schlüssel "HighScore".
    }

    // MARK: - Animationsmethoden

    func animateButtonPress(_ node: SKNode) {
        let scaleDown = SKAction.scale(by: 0.9, duration: 0.1) // verkleinert das Symbol leicht
        let scaleUp = SKAction.scale(by: 1/0.9, duration: 0.1) // setzt die Größe wieder auf Originalgröße zurück
        let sequence = SKAction.sequence([scaleDown, scaleUp]) // Definiert die Reihenfolge der Aktion
        node.run(sequence) // Startt die Animation auf dem Symbol
    }
    
    // Hebt das ausgewählte Symbol visuell hervor, indem es eingefärbt wird.
    func highlightSelectedSymbol(_ node: SKNode) {
        // Setze alle Symbole zurück
        resetSymbolHighlights() // Entfernt vorherige Hervorhebungen von allen Symbolen.

        // Überprüft, ob das übergebene Node ein SKSpriteNode ist.
        if let spriteNode = node as? SKSpriteNode {
            spriteNode.color = .green //Setzt die Hervorhebungsfarbe auf Grün.
            spriteNode.colorBlendFactor = 0.3 // Legt die Intensität der Farbüberlagerung auf 30 % fest.
        }
    }
    // Setzt die Hervorhebung aller Symbole zurück.
    func resetSymbolHighlights() {
        let symbols = ["steinButton", "papierButton", "schereButton"] // Namen der Symbole in der Szene.
        // Iteriert über alle Symbolnamen.
        for symbolName in symbols {
            // Findet das Symbol-Node anhand des Namens.
            if let symbolNode = childNode(withName: symbolName) as? SKSpriteNode {
                symbolNode.colorBlendFactor = 0 // Entfernt die Farbüberlagerung, sodass das Symbol wieder normal dargestellt wird.
            }
        }
    }

    // MARK: - Tutorial-Animationen

    func startTutorialAnimations() {
        startFistTutorialAnimation()
        startTutorialIndicatorAnimation()
    }

    func startFistTutorialAnimation() {
        // Bewegung der Spielerfaust nach oben und unten

        // Berechne eine Position leicht oberhalb der Originalposition
        let upwardPosition = CGPoint(
            x: playerOriginalPosition.x,
            y: playerOriginalPosition.y + 50 // Bewege 50 Punkte nach oben
        )

        // Bewegung der Spielerfaust leicht nach oben und zurück
        let moveDuration = 0.5
        let moveUp = SKAction.move(to: upwardPosition, duration: moveDuration)
        let moveDown = SKAction.move(to: playerOriginalPosition, duration: moveDuration)
        let wait = SKAction.wait(forDuration: 0.2)
        let sequence = SKAction.sequence([moveUp, wait, moveDown, wait])
        let repeatAction = SKAction.repeatForever(sequence)

        // Aktion speichern, um sie später stoppen zu können
        tutorialFistAction = repeatAction
        playerSymbol.run(repeatAction, withKey: "tutorialFistAction")
    }

    func startTutorialIndicatorAnimation() {
        if let tutorialIndicator = tutorialIndicator {
            tutorialIndicator.isHidden = false

            // Pulsieren lassen
            let scaleUp = SKAction.scale(to: 0.35, duration: 0.5) // 0.3 * 1.16 ≈ 0.35
            let scaleDown = SKAction.scale(to: 0.3, duration: 0.5)
            let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
            let pulseForever = SKAction.repeatForever(pulseSequence)
            tutorialIndicator.run(pulseForever, withKey: "pulsate")
        }
    }

    func removeTutorialAnimations() {
        // Bewegung der Spielerfaust stoppen
        playerSymbol.removeAction(forKey: "tutorialFistAction")
        playerSymbol.position = playerOriginalPosition

        // Pulsierende Animation des Indikators stoppen und ausblenden
        if let tutorialIndicator = tutorialIndicator {
            tutorialIndicator.removeAction(forKey: "pulsate")
            tutorialIndicator.isHidden = true
        }
    }

    // MARK: - Effekte und Sounds

    func showFirework() {
        // Überprüft, ob die Datei "Firework.sks" geladen werden kann, um ein Partikelsystem zu erstellen.
        if let firework = SKEmitterNode(fileNamed: "Firework.sks") {
            
            // Setzt die Position des Feuerwerks auf die Mitte der Szene (x: 0, y: 0).
            firework.position = CGPoint(x: 0, y: 0)
            
            // Legt die zPosition des Feuerwerks fest, damit es über anderen Elementen angezeigt wird.
            firework.zPosition = 15
            
            // Fügt das Feuerwerk der Szene hinzu, sodass es sichtbar wird.
            addChild(firework)
            
            // Startet eine Sequenz von Aktionen für das Feuerwerk:
            firework.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.5), // Lässt das Feuerwerk für 2,5 Sekunden aktiv bleiben.
                SKAction.removeFromParent()     // Entfernt das Feuerwerk aus der Szene, um Speicher freizugeben.
            ]))
        }
    }

    func showLoseEffect() {
        if let loseEffect = SKEmitterNode(fileNamed: "LoseEffect.sks") {
            loseEffect.position = CGPoint(x: 0, y: 0) // Position anpassen
            loseEffect.zPosition = 15 // Über den anderen Elementen anzeigen
            addChild(loseEffect)

            // Entfernen des Partikelemitters nach der Dauer des Effekts
            let wait = SKAction.wait(forDuration: 2.5)
            let remove = SKAction.removeFromParent()
            loseEffect.run(SKAction.sequence([wait, remove]))

        
        }
    }

    func animateLoseLabel() {
        let shakeAction = SKAction.sequence([
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 20, y: 0, duration: 0.1),
            SKAction.moveBy(x: -20, y: 0, duration: 0.1),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 0, y: 0, duration: 0.05)
        ])
        resultLabel.run(shakeAction)
    }

    // Funktion zum Abspielen des Soundeffekts für einen Sieg
    func playWinSound() {
        // Führt eine Aktion aus, um die Audiodatei "winSound.mp3" abzuspielen.
        // Der Parameter `waitForCompletion: false` sorgt dafür, dass andere Aktionen
        // gleichzeitig ausgeführt werden können, ohne auf das Ende des Sounds zu warten.
        run(SKAction.playSoundFileNamed("winSound.mp3", waitForCompletion: false))
    }

    // Funktion zum Abspielen des Soundeffekts für eine Niederlage
    func playLoseSound() {
        // Führt eine Aktion aus, um die Audiodatei "loseSound.mp3" abzuspielen.
        // `waitForCompletion: false` ermöglicht die parallele Ausführung anderer Aktionen.
        run(SKAction.playSoundFileNamed("loseSound.mp3", waitForCompletion: false))
    }

    // Funktion zum Abspielen des Soundeffekts für ein Unentschieden
    func playDrawSound() {
        // Führt eine Aktion aus, um die Audiodatei "drawSound.mp3" abzuspielen.
        // Der Sound wird abgespielt, ohne den Spielfluss zu unterbrechen.
        run(SKAction.playSoundFileNamed("drawSound.mp3", waitForCompletion: false))
    }

    // MARK: - Navigationsmethoden

    func goToStartScene() {
        if let view = self.view {
            if let startScene = SKScene(fileNamed: "StartScene") {
                startScene.scaleMode = .aspectFill
                view.presentScene(startScene, transition: SKTransition.fade(withDuration: 0.5))
            }
        }
    }
}
