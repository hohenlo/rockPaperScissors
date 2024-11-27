//
//  StartScene.swift
//  rockPaperScissors
//
//  Created by Leo Hohenberger on 06.11.24.
//

import Foundation
import SpriteKit

// MARK: - StartScene: Einstiegspunkt der App
// Diese Klasse repräsentiert die Startszene des Spiels, die die Begrüßungsanimationen und Buttons für Benutzeraktionen anzeigt.

class StartScene: SKScene {

    // MARK: - UI-Elemente
    private var groundNode: SKSpriteNode! // Unsichtbarer Boden in der Szene, für die Physik und Kollisionen.
    private var newGameButton: SKShapeNode! // Button, um ein neues Spiel zu starten.
    private var resetHighscoreButton: SKShapeNode! // Button, um den Highscore zurückzusetzen.

    // MARK: - Lifecycle Methods
    
    // Wird aufgerufen, sobald die Szene dem View hinzugefügt wird.
    override func didMove(to view: SKView) {
        configurePhysicsWorld() // Konfiguriert die Physik-Einstellungen der Szene.
        setupGround() // Erstellt den statischen Boden.
        animateGreetingElements() // Startet die Begrüßungsanimationen.
    }

    // MARK: - Scene Setup
    
    // Konfiguriert die Physik-Einstellungen der Szene.
    private func configurePhysicsWorld() {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8) // Setzt die Schwerkraft auf Standard-Wert.
    }
    
    // Erstellt einen statischen Boden am unteren Rand der Szene.
    private func setupGround() {
        let groundHeight: CGFloat = 50 // Höhe des Bodens.
        groundNode = SKSpriteNode(color: .clear, size: CGSize(width: self.size.width, height: groundHeight)) // Unsichtbarer Boden-Knoten.
        groundNode.position = CGPoint(x: 0, y: -self.size.height / 2 + groundHeight / 2) // Positioniert den Boden unten in der Szene.
        groundNode.zPosition = 1 // Setzt die Sichtbarkeitsebene.

        // Fügt einen Physik-Körper hinzu, damit Objekte auf den Boden treffen können.
        groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
        groundNode.physicsBody?.isDynamic = false // Boden bleibt statisch.

        addChild(groundNode) // Fügt den Boden zur Szene hinzu.
    }
    
    // MARK: - Animations
    
    // Führt die Begrüßungsanimationen für Texte und Symbole aus.
    private func animateGreetingElements() {
        let labels = ["schereLabel", "steinLabel", "papierLabel"] // Namen der Begrüßungs-Labels.
        animateLabelsSequentially(labels, delayFactor: 0.5) // Startet die Animation für die Labels mit zeitlicher Verzögerung.

        let symbols = ["schereSymbol", "steinSymbol", "papierSymbol", "faustSymbol"] // Namen der Symbole.
        animateSymbolsSequentially(symbols, delayFactor: 0.5, scaleUpSize: 1.2, targetSize: 0.7) // Animiert die Symbole mit Pop-Up-Effekt.

        let buttonDelay = SKAction.wait(forDuration: 3.5) // Wartet 3,5 Sekunden, bevor die Buttons angezeigt werden.
        run(buttonDelay) {
            self.showButtons() // Zeigt die Buttons nach der Verzögerung an.
        }
    }
    
    // Animiert die Labels mit einer zeitlichen Verzögerung.
    private func animateLabelsSequentially(_ labelNames: [String], delayFactor: Double) {
        for (index, labelName) in labelNames.enumerated() {
            if let label = childNode(withName: labelName) as? SKLabelNode { // Sucht das Label anhand des Namens.
                label.alpha = 0 // Setzt das Label zunächst auf unsichtbar.
                let delay = SKAction.wait(forDuration: Double(index) * delayFactor) // Verzögerung basierend auf dem Index.
                let fadeIn = SKAction.fadeIn(withDuration: 0.5) // Animation zum Einblenden.
                let sequence = SKAction.sequence([delay, fadeIn]) // Kombination aus Verzögerung und Einblenden.
                label.run(sequence) // Startet die Animation.
            }
        }
    }
    
    // Animiert Symbole mit Pop-Up- und Skalierungseffekten.
    private func animateSymbolsSequentially(_ symbolNames: [String], delayFactor: Double, scaleUpSize: CGFloat, targetSize: CGFloat) {
        for (index, symbolName) in symbolNames.enumerated() {
            if let symbol = childNode(withName: symbolName) as? SKSpriteNode { // Sucht das Symbol anhand des Namens.
                symbol.setScale(0) // Setzt die Skalierung auf 0, um unsichtbar zu starten.

                let delay = SKAction.wait(forDuration: Double(index) * delayFactor + 1.5) // Verzögert die Animation.
                let popUp = SKAction.scale(to: scaleUpSize, duration: 0.3) // Vergrößert das Symbol auf 1,2.
                let settleDown = SKAction.scale(to: targetSize, duration: 0.2) // Reduziert die Größe auf 0,7.
                let sequence = SKAction.sequence([delay, popUp, settleDown]) // Führt die Aktionen nacheinander aus.
                symbol.run(sequence) // Startet die Animation.
            }
        }
    }
    
    // MARK: - Button Setup and Actions
    
    // Zeigt die Buttons "Neues Spiel" und "Highscore zurücksetzen" mit Fade-In-Animation an.
    private func showButtons() {
        configureNewGameButton() // Erstellt den "Neues Spiel"-Button.
        configureResetHighscoreButton() // Erstellt den "Highscore zurücksetzen"-Button.

        let fadeIn = SKAction.fadeIn(withDuration: 0.5) // Erstellt eine Fade-In-Animation.
        newGameButton.run(fadeIn) // Zeigt den "Neues Spiel"-Button an.
        resetHighscoreButton.run(fadeIn) // Zeigt den "Highscore zurücksetzen"-Button an.
    }
    
    // Erstellt und konfiguriert den "Neues Spiel"-Button.
    private func configureNewGameButton() {
        let buttonSize = CGSize(width: 450, height: 75) // Größe des Buttons.
        newGameButton = createButton(with: buttonSize, text: "Neues Spiel", position: CGPoint(x: 0, y: 200)) // Erstellt den Button.
        newGameButton.name = "newGameButton" // Setzt den Namen des Buttons.
        addChild(newGameButton) // Fügt den Button zur Szene hinzu.
    }
    
    // Erstellt und konfiguriert den "Highscore zurücksetzen"-Button.
    private func configureResetHighscoreButton() {
        let buttonSize = CGSize(width: 450, height: 75) // Größe des Buttons.
        resetHighscoreButton = createButton(with: buttonSize, text: "Highscore zurücksetzen", position: CGPoint(x: 0, y: 100)) // Erstellt den Button.
        resetHighscoreButton.name = "resetHighscoreButton" // Setzt den Namen des Buttons.
        addChild(resetHighscoreButton) // Fügt den Button zur Szene hinzu.
    }
    
    // Erstellt einen generischen Button mit Text.
    private func createButton(with size: CGSize, text: String, position: CGPoint) -> SKShapeNode {
        let button = SKShapeNode(rectOf: size, cornerRadius: 10) // Erstellt einen rechteckigen Button mit abgerundeten Ecken.
        button.fillColor = .lightGray // Setzt die Füllfarbe des Buttons.
        button.strokeColor = .black // Setzt die Farbe des Rahmens.
        button.lineWidth = 2 // Breite des Rahmens.
        button.position = position // Position des Buttons in der Szene.
        button.zPosition = 10 // Sichtbarkeitsebene des Buttons.
        button.alpha = 0 // Startet unsichtbar.

        let label = SKLabelNode(text: text) // Erstellt einen Text für den Button.
        label.fontName = "Chalkduster" // Schriftart des Textes.
        label.fontSize = 30 // Schriftgröße.
        label.fontColor = .black // Farbe des Textes.
        label.verticalAlignmentMode = .center // Zentriert den Text vertikal im Button.
        label.zPosition = 11 // Setzt den Text über den Button.
        button.addChild(label) // Fügt den Text zum Button hinzu.

        return button // Gibt den fertigen Button zurück.
    }
    
    // MARK: - Button Touch Handling

    // Behandelt Berührungen auf der Szene.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } // Überprüft, ob eine Berührung existiert, ansonsten Abbruch.
        let location = touch.location(in: self) // Ermittelt die Position der Berührung innerhalb der Szene.
        
        // Überprüft, ob der "Neues Spiel"-Button gedrückt wurde.
        handleButtonPress(for: location, button: newGameButton) {
            self.startNewGame() // Startet ein neues Spiel, wenn der Button gedrückt wird.
        }
        
        // Überprüft, ob der "Highscore zurücksetzen"-Button gedrückt wurde.
        handleButtonPress(for: location, button: resetHighscoreButton) {
            self.resetHighScore() // Setzt den Highscore zurück.
            self.displayResetConfirmation() // Zeigt eine Bestätigungsnachricht an.
        }
    }

    // Behandelt das Drücken eines Buttons.
    //
    // - Parameters:
    //  - location: Die Position der Berührung.
    //  - button: Der Button, der überprüft wird.
    //   - action: Die Aktion, die ausgeführt werden soll, wenn der Button gedrückt wurde.
    private func handleButtonPress(for location: CGPoint, button: SKShapeNode?, action: @escaping () -> Void) {
        guard let button = button, button.contains(location) else { return } // Überprüft, ob die Berührung den Button getroffen hat.
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1) // Erstellt eine Aktion, die den Button leicht verkleinert.
        button.run(scaleDown) { // Führt die Verkleinerung aus und wartet auf Abschluss.
            button.run(SKAction.scale(to: 1.0, duration: 0.1)) // Vergrößert den Button wieder auf die Originalgröße.
            action() // Führt die übergebene Aktion aus.
        }
    }

    // MARK: - Game Actions

    // Startet ein neues Spiel mit einer Animation, bei der Symbole herunterfallen.
    private func startNewGame() {
        animateSymbolDrop() // Startet die Animation für das Herunterfallen der Symbole.
        let wait = SKAction.wait(forDuration: 3.0) // Wartet 3 Sekunden, bevor die Szene gewechselt wird.
        let transitionAction = SKAction.run { [weak self] in // Definiert eine Aktion, um zur nächsten Szene zu wechseln.
            guard let gameScene = SKScene(fileNamed: "GameScene") else { return } // Lädt die nächste Szene (GameScene).
            gameScene.scaleMode = .aspectFill // Stellt sicher, dass die Szene den gesamten Bildschirm füllt.
            let transition = SKTransition.fade(withDuration: 1.0) // Erstellt eine Übergangsanimation (Fade-In/Out).
            self?.view?.presentScene(gameScene, transition: transition) // Präsentiert die neue Szene mit dem Übergang.
        }
        run(SKAction.sequence([wait, transitionAction])) // Führt die Warteschleife und den Szenenwechsel aus.
    }

    // Animiert das Herunterfallen der Symbole.
    //
    // Diese Methode weist den Symbolen Physik-Eigenschaften zu, sodass sie wie fallende Objekte wirken.
    private func animateSymbolDrop() {
        let symbols = ["schereSymbol", "steinSymbol", "papierSymbol", "faustSymbol"] // Namen der Symbole.
        for symbolName in symbols { // Iteriert über alle Symbole.
            if let symbol = childNode(withName: symbolName) as? SKSpriteNode { // Sucht das Symbol in der Szene.
                symbol.removeAllActions() // Entfernt eventuell vorherige Animationen des Symbols.
                symbol.setScale(0.7) // Setzt die Skalierung auf die Standardgröße.
                symbol.physicsBody = SKPhysicsBody(texture: symbol.texture!, size: symbol.size) // Fügt einen Physik-Körper hinzu.
                symbol.physicsBody?.isDynamic = true // Ermöglicht Bewegung durch Physik.
                symbol.physicsBody?.affectedByGravity = true // Aktiviert die Schwerkraft auf das Symbol.
                symbol.physicsBody?.allowsRotation = true // Erlaubt das Drehen des Symbols.
                symbol.physicsBody?.restitution = 0.5 // Setzt die Elastizität (Symbol springt leicht ab).
            }
        }
    }

    // Setzt den Highscore zurück.
    private func resetHighScore() {
        let defaults = UserDefaults.standard // Zugriff auf den lokalen Speicher (UserDefaults).
        defaults.set(0, forKey: "HighScore") // Setzt den Wert für "HighScore" auf 0.
    }

    // Zeigt eine Bestätigung nach dem Zurücksetzen des Highscores an.
    private func displayResetConfirmation() {
        let label = SKLabelNode(text: "Highscore zurückgesetzt!") // Erstellt ein Label mit dem Bestätigungstext.
        label.fontName = "Chalkduster" // Setzt die Schriftart.
        label.fontSize = 30 // Setzt die Schriftgröße.
        label.fontColor = .gray // Setzt die Schriftfarbe.
        label.position = CGPoint(x: 0, y: -200) // Positioniert das Label in der Szene.
        label.zPosition = 15 // Setzt die Sichtbarkeitsebene des Labels.
        label.alpha = 0 // Startet unsichtbar.
        addChild(label) // Fügt das Label zur Szene hinzu.

        let fadeIn = SKAction.fadeIn(withDuration: 0.5) // Erstellt eine Aktion zum Einblenden.
        let wait = SKAction.wait(forDuration: 2.0) // Wartet 2 Sekunden, bevor das Label ausgeblendet wird.
        let fadeOut = SKAction.fadeOut(withDuration: 0.5) // Erstellt eine Aktion zum Ausblenden.
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, SKAction.removeFromParent()]) // Kombiniert alle Aktionen.
        label.run(sequence) // Führt die Animationen aus.
    }
    }
