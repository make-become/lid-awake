// Every string the user sees, in every language the app speaks (as in Claude Switcher).
import Foundation

let languages = ["en", "it", "es", "fr", "de"]

/// First of the user's preferred languages that we have, else English.
let lang: String = {
    if let forced = ProcessInfo.processInfo.environment["LID_AWAKE_LANG"], languages.contains(forced) { return forced }
    for l in Locale.preferredLanguages {
        let code = String(l.prefix(2))
        if languages.contains(code) { return code }
    }
    return "en"
}()

func t(_ key: String, _ args: CVarArg...) -> String {
    let row = strings[key] ?? [:]
    let s = row[lang] ?? row["en"] ?? key
    return args.isEmpty ? s : String(format: s, arguments: args)
}

private let strings: [String: [String: String]] = [
    "stayOn": ["en": "Stay on with the lid closed", "it": "Resta acceso col coperchio chiuso", "es": "Seguir encendido con la tapa cerrada",
               "fr": "Rester allumé capot fermé", "de": "Bei geschlossenem Deckel anbleiben"],
    "isOn": ["en": "On: closing the lid keeps the Mac running", "it": "Attivo: chiudendo il coperchio il Mac resta acceso",
             "es": "Activado: al cerrar la tapa el Mac sigue encendido", "fr": "Activé : capot fermé, le Mac reste allumé",
             "de": "An: Bei geschlossenem Deckel läuft der Mac weiter"],
    "isOff": ["en": "Off: the Mac sleeps when the lid closes", "it": "Spento: il Mac va in stop alla chiusura",
              "es": "Desactivado: el Mac reposa al cerrar la tapa", "fr": "Désactivé : le Mac se met en veille capot fermé",
              "de": "Aus: Der Mac schläft, wenn der Deckel zugeht"],
    "autoOff": ["en": "Turns itself off when the lid opens again", "it": "Si spegne da solo alla riapertura del coperchio",
                "es": "Se desactiva solo al volver a abrir la tapa", "fr": "Se désactive tout seul à la réouverture du capot",
                "de": "Schaltet sich beim Öffnen des Deckels selbst aus"],
    "testBeep": ["en": "Play the lid-closed beep", "it": "Prova il beep di chiusura", "es": "Probar el pitido de cierre",
                 "fr": "Écouter le bip de fermeture", "de": "Schließ-Signal testen"],
    "setup": ["en": "Allow Lid Awake to change sleep…", "it": "Permetti a Lid Awake di cambiare lo stop…",
              "es": "Permitir que Lid Awake cambie el reposo…", "fr": "Autoriser Lid Awake à changer la veille…",
              "de": "Lid Awake erlauben, den Ruhezustand zu ändern…"],
    "removeSetup": ["en": "Remove the permission…", "it": "Rimuovi il permesso…", "es": "Quitar el permiso…",
                    "fr": "Retirer l'autorisation…", "de": "Erlaubnis entfernen…"],
    "atLogin": ["en": "Start at login", "it": "Avvia al login", "es": "Iniciar al iniciar sesión", "fr": "Ouvrir à la connexion",
                "de": "Beim Anmelden starten"],
    "quit": ["en": "Quit Lid Awake (turns it off)", "it": "Esci da Lid Awake (lo spegne)", "es": "Salir de Lid Awake (lo desactiva)",
             "fr": "Quitter Lid Awake (le désactive)", "de": "Lid Awake beenden (schaltet es aus)"],
    "setupPrompt": ["en": "Lid Awake needs to be allowed, once, to turn the Mac's sleep on and off.",
                    "it": "Lid Awake deve essere autorizzato, una volta sola, ad attivare e disattivare lo stop del Mac.",
                    "es": "Lid Awake necesita permiso, una sola vez, para activar y desactivar el reposo del Mac.",
                    "fr": "Lid Awake doit être autorisé, une seule fois, à activer et désactiver la veille du Mac.",
                    "de": "Lid Awake braucht einmalig die Erlaubnis, den Ruhezustand des Mac ein- und auszuschalten."],
    "removePrompt": ["en": "Lid Awake will remove its permission to change sleep.", "it": "Lid Awake rimuoverà il suo permesso di cambiare lo stop.",
                     "es": "Lid Awake quitará su permiso para cambiar el reposo.", "fr": "Lid Awake va retirer son autorisation de changer la veille.",
                     "de": "Lid Awake entfernt seine Erlaubnis, den Ruhezustand zu ändern."],
    "needSetupTitle": ["en": "One-time permission", "it": "Permesso una tantum", "es": "Permiso único", "fr": "Autorisation unique",
                       "de": "Einmalige Erlaubnis"],
    "needSetupText": ["en": "Keeping a Mac on with the lid closed is a system setting that only an administrator can change. Lid Awake installs a rule that lets it change that one setting and nothing else. macOS asks for your password; Lid Awake never sees it.",
                      "it": "Tenere acceso un Mac col coperchio chiuso è un'impostazione di sistema che solo un amministratore può cambiare. Lid Awake installa una regola che gli permette di cambiare quell'impostazione e nient'altro. La password la chiede macOS; Lid Awake non la vede mai.",
                      "es": "Mantener un Mac encendido con la tapa cerrada es un ajuste del sistema que solo un administrador puede cambiar. Lid Awake instala una regla que le permite cambiar ese ajuste y nada más. macOS pide tu contraseña; Lid Awake nunca la ve.",
                      "fr": "Garder un Mac allumé capot fermé est un réglage système que seul un administrateur peut changer. Lid Awake installe une règle qui lui permet de changer ce réglage et rien d'autre. macOS demande votre mot de passe ; Lid Awake ne le voit jamais.",
                      "de": "Einen Mac bei geschlossenem Deckel anzulassen ist eine Systemeinstellung, die nur ein Administrator ändern kann. Lid Awake installiert eine Regel, die ihm genau diese Einstellung erlaubt und sonst nichts. macOS fragt nach deinem Passwort; Lid Awake sieht es nie."],
    "continue": ["en": "Continue…", "it": "Continua…", "es": "Continuar…", "fr": "Continuer…", "de": "Weiter…"],
    "cancel": ["en": "Cancel", "it": "Annulla", "es": "Cancelar", "fr": "Annuler", "de": "Abbrechen"],
    "failed": ["en": "Lid Awake could not change the setting.", "it": "Lid Awake non è riuscito a cambiare l'impostazione.",
               "es": "Lid Awake no pudo cambiar el ajuste.", "fr": "Lid Awake n'a pas pu changer le réglage.",
               "de": "Lid Awake konnte die Einstellung nicht ändern."],
]
