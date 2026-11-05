// Page languages. The language is ?lang=…, else the last one picked, else the browser's, else English.
(() => {
const CMD = "curl -fsSL https://make-become.github.io/lid-awake/install.sh | sh";
const NAMES = { en: "English", it: "Italiano", es: "Español", fr: "Français", de: "Deutsch" };
const MB = "<a href='https://make-become.github.io/'>make become</a>";
const RULE = "<code>pmset -a disablesleep 0</code> / <code>1</code>";

const T = {
en: {
  lead: "Keep your MacBook running with the lid closed, for that one long job. One switch in the menu bar. When you close the lid it beeps, even on mute, so you know the Mac is still on; it turns itself off when you open the lid again. Free, open source.",
  altOff: "The Lid Awake menu, switched off", altOn: "The Lid Awake menu, switched on",
  installH: "Install", installP: "Paste this in the Terminal:",
  askH: "Or ask Claude to do it", askP: "Paste this in Claude Code or in Claude Desktop (with access to your Mac):",
  prompt: `Install Lid Awake on my Mac: run \`${CMD}\` in the terminal, then tell me whether its icon appeared in the menu bar. Details: https://make-become.github.io/lid-awake/details.html`,
  copy: "Copy", copied: "Copied", more: "More info", unofficial: `A ${MB} project.`,
  back: "← Back", source: "Source code on GitHub",
  whatH: "What it does",
  whatList: `<li><strong>One switch</strong> in the menu bar, <em>Stay on with the lid closed</em>. No Dock icon, no window. The icon is a laptop, red while it is on.</li>
<li><strong>A beep when the lid closes</strong> while it is on, so you know the Mac did not go to sleep. It is audible even when the Mac is muted or at volume 0: the volume goes up for the beep and back to where it was right after.</li>
<li><strong>It turns itself off</strong> when you open the lid again, and when you quit it, when it crashes, and when the Mac restarts. Sleep is never left disabled by accident.</li>
<li><strong>Starts at login</strong> by default; untick <em>Start at login</em> in its menu to stop that.</li>
<li><strong>Languages:</strong> English, Italiano, Español, Français, Deutsch, from your Mac's settings.</li>`,
  whyH: "Why it asks for a permission, once",
  whyP1: `macOS puts a MacBook to sleep when the lid closes, and only one system setting stops that: ${RULE}, which only an administrator can change. The first time you turn the switch on, Lid Awake explains this and macOS asks for your password in its own dialog. Lid Awake never sees or stores it.`,
  whyP2: "What it installs is a rule that lets your user run exactly those two commands without a password, and nothing else. A helper running as root all the time would also work, but it would be a bigger permanent privilege for a single setting, and it would need an Apple developer certificate.",
  diskH: "Everything it puts on your Mac",
  diskIntro: "The complete list. Nothing is sent anywhere.",
  thWhere: "Where", thWhat: "What it is",
  rApp: "The app. About 1 MB.",
  rSudoers: "The one-line rule: your user may run <code>pmset -a disablesleep 0</code> and <code>pmset -a disablesleep 1</code> as administrator. Nothing else.",
  rDaemon: "Runs <code>pmset -a disablesleep 0</code> once when the Mac starts, so a restart always gives you normal sleep back.",
  uninstallH: "Uninstalling",
  uninstallP: "Choose <em>Remove the permission…</em> in its menu (macOS asks for your password once more), quit it, and drag <code>Lid Awake.app</code> to the Trash.",
  installerH: "What the installer does",
  installerP: "It downloads the latest release from GitHub, puts <code>Lid Awake.app</code> in <code>/Applications</code>, removes the download quarantine (the app is open source but not notarised by Apple, so macOS would otherwise refuse to open it) and opens it. Nothing else: the permission is asked for by the app, the first time you need it. You can <a href=\"install.sh\">read it</a> before running it.",
  manualP: "To install by hand: download the zip from the <a href=\"https://github.com/make-become/lid-awake/releases/latest\">latest release</a>, move the app to Applications, and open it the first time with right-click → Open. To build it yourself: <code>git clone</code> the repository and run <code>./build.sh</code>. Needs macOS 13 or later.",
  knowH: "Good to know",
  knowList: `<li>With the lid closed and the Mac on, it keeps running at full speed and can get warm: do not leave it in a closed bag.</li>
<li>The beep plays on the current output: the built-in speakers, or your headphones if they are connected.</li>
<li>Lid Awake turns the setting off when it starts, too: if you set <code>pmset disablesleep 1</code> by hand, starting Lid Awake undoes it.</li>
<li>With an external display, power and keyboard, macOS already keeps a closed MacBook awake (clamshell mode); Lid Awake is for when you have none of those.</li>`,
  footer: `MIT licence · ${MB}`,
},
it: {
  lead: "Tieni acceso il MacBook col coperchio chiuso, per quel lavoro lungo. Un solo interruttore nella barra dei menu. Quando chiudi il coperchio fa un beep, anche col volume a zero, così sai che il Mac è ancora acceso; si spegne da solo quando riapri il coperchio. Gratuito, open source.",
  altOff: "Il menu di Lid Awake, spento", altOn: "Il menu di Lid Awake, attivo",
  installH: "Installa", installP: "Incolla questo nel Terminale:",
  askH: "Oppure chiedi a Claude di farlo", askP: "Incolla questo in Claude Code o in Claude Desktop (con accesso al tuo Mac):",
  prompt: `Installa Lid Awake sul mio Mac: esegui \`${CMD}\` nel terminale, poi dimmi se la sua icona è comparsa nella barra dei menu. Dettagli: https://make-become.github.io/lid-awake/details.html`,
  copy: "Copia", copied: "Copiato", more: "Più informazioni", unofficial: `Un progetto ${MB}.`,
  back: "← Indietro", source: "Codice sorgente su GitHub",
  whatH: "Cosa fa",
  whatList: `<li><strong>Un interruttore</strong> nella barra dei menu, <em>Resta acceso col coperchio chiuso</em>. Niente icona nel Dock, nessuna finestra. L'icona è un portatile, rosso quando è attivo.</li>
<li><strong>Un beep quando chiudi il coperchio</strong> mentre è attivo, così sai che il Mac non è andato in stop. Si sente anche col Mac muto o a volume 0: il volume sale per il beep e torna subito com'era.</li>
<li><strong>Si spegne da solo</strong> quando riapri il coperchio, quando esci dall'app, se l'app va in crash e quando il Mac si riavvia. Lo stop non resta mai disattivato per sbaglio.</li>
<li><strong>Si avvia al login</strong> per default; togli la spunta ad <em>Avvia al login</em> nel suo menu per non farlo.</li>
<li><strong>Lingue:</strong> English, Italiano, Español, Français, Deutsch, dalle impostazioni del Mac.</li>`,
  whyH: "Perché chiede un permesso, una volta",
  whyP1: `macOS mette in stop un MacBook quando si chiude il coperchio, e una sola impostazione di sistema lo impedisce: ${RULE}, che solo un amministratore può cambiare. La prima volta che accendi l'interruttore Lid Awake lo spiega e macOS chiede la password nella sua finestra. Lid Awake non la vede e non la salva mai.`,
  whyP2: "Installa una regola che permette al tuo utente di eseguire esattamente quei due comandi senza password, e nient'altro. Un aiutante sempre attivo come root funzionerebbe lo stesso, ma sarebbe un privilegio permanente più grande per una sola impostazione, e richiederebbe un certificato sviluppatore Apple.",
  diskH: "Tutto quello che mette sul tuo Mac",
  diskIntro: "L'elenco completo. Non manda niente da nessuna parte.",
  thWhere: "Dove", thWhat: "Cos'è",
  rApp: "L'app. Circa 1 MB.",
  rSudoers: "La regola di una riga: il tuo utente può eseguire come amministratore <code>pmset -a disablesleep 0</code> e <code>pmset -a disablesleep 1</code>. Nient'altro.",
  rDaemon: "Esegue <code>pmset -a disablesleep 0</code> una volta all'avvio del Mac, così dopo un riavvio lo stop torna sempre normale.",
  uninstallH: "Disinstallare",
  uninstallP: "Scegli <em>Rimuovi il permesso…</em> nel suo menu (macOS chiede la password un'altra volta), esci e trascina <code>Lid Awake.app</code> nel Cestino.",
  installerH: "Cosa fa l'installer",
  installerP: "Scarica l'ultima versione da GitHub, mette <code>Lid Awake.app</code> in <code>/Applications</code>, toglie la quarantena del download (l'app è open source ma non notarizzata da Apple, altrimenti macOS si rifiuterebbe di aprirla) e la apre. Nient'altro: il permesso lo chiede l'app, la prima volta che serve. Puoi <a href=\"install.sh\">leggerlo</a> prima di eseguirlo.",
  manualP: "Per installarla a mano: scarica lo zip dall'<a href=\"https://github.com/make-become/lid-awake/releases/latest\">ultima versione</a>, sposta l'app in Applicazioni e aprila la prima volta con clic destro → Apri. Per compilarla tu: <code>git clone</code> del repository e <code>./build.sh</code>. Serve macOS 13 o successivo.",
  knowH: "Buono a sapersi",
  knowList: `<li>Col coperchio chiuso e il Mac acceso, il Mac lavora a piena velocità e può scaldarsi: non lasciarlo in una borsa chiusa.</li>
<li>Il beep suona sull'uscita audio attuale: gli altoparlanti interni, o le cuffie se sono collegate.</li>
<li>Lid Awake spegne l'impostazione anche quando si avvia: se hai messo <code>pmset disablesleep 1</code> a mano, avviare Lid Awake lo annulla.</li>
<li>Con monitor esterno, alimentazione e tastiera, macOS tiene già sveglio un MacBook chiuso (modalità clamshell); Lid Awake serve quando non hai niente di tutto questo.</li>`,
  footer: `Licenza MIT · ${MB}`,
},
es: {
  lead: "Mantén tu MacBook encendido con la tapa cerrada, para ese trabajo largo. Un solo interruptor en la barra de menús. Al cerrar la tapa suena un pitido, incluso en silencio, para que sepas que el Mac sigue encendido; se desactiva solo al volver a abrir la tapa. Gratis, de código abierto.",
  altOff: "El menú de Lid Awake, desactivado", altOn: "El menú de Lid Awake, activado",
  installH: "Instalar", installP: "Pega esto en el Terminal:",
  askH: "O pídeselo a Claude", askP: "Pega esto en Claude Code o en Claude Desktop (con acceso a tu Mac):",
  prompt: `Instala Lid Awake en mi Mac: ejecuta \`${CMD}\` en el terminal y dime si su icono apareció en la barra de menús. Detalles: https://make-become.github.io/lid-awake/details.html`,
  copy: "Copiar", copied: "Copiado", more: "Más información", unofficial: `Un proyecto de ${MB}.`,
  back: "← Volver", source: "Código fuente en GitHub",
  whatH: "Qué hace",
  whatList: `<li><strong>Un interruptor</strong> en la barra de menús, <em>Seguir encendido con la tapa cerrada</em>. Sin icono en el Dock, sin ventanas. El icono es un portátil, rojo mientras está activado.</li>
<li><strong>Un pitido al cerrar la tapa</strong> mientras está activado, para que sepas que el Mac no se fue a dormir. Se oye aunque el Mac esté en silencio o a volumen 0: el volumen sube para el pitido y vuelve enseguida a como estaba.</li>
<li><strong>Se desactiva solo</strong> al volver a abrir la tapa, al salir de la app, si la app falla y al reiniciar el Mac. El reposo nunca queda desactivado por error.</li>
<li><strong>Se inicia al iniciar sesión</strong> por defecto; desmarca <em>Iniciar al iniciar sesión</em> en su menú para evitarlo.</li>
<li><strong>Idiomas:</strong> English, Italiano, Español, Français, Deutsch, según los ajustes del Mac.</li>`,
  whyH: "Por qué pide un permiso, una vez",
  whyP1: `macOS pone a dormir un MacBook al cerrar la tapa, y solo un ajuste del sistema lo evita: ${RULE}, que solo un administrador puede cambiar. La primera vez que activas el interruptor, Lid Awake lo explica y macOS pide tu contraseña en su propio diálogo. Lid Awake nunca la ve ni la guarda.`,
  whyP2: "Lo que instala es una regla que deja a tu usuario ejecutar exactamente esos dos comandos sin contraseña, y nada más. Un ayudante funcionando siempre como root también serviría, pero sería un privilegio permanente mayor para un solo ajuste, y necesitaría un certificado de desarrollador de Apple.",
  diskH: "Todo lo que pone en tu Mac",
  diskIntro: "La lista completa. No envía nada a ninguna parte.",
  thWhere: "Dónde", thWhat: "Qué es",
  rApp: "La app. Alrededor de 1 MB.",
  rSudoers: "La regla de una línea: tu usuario puede ejecutar como administrador <code>pmset -a disablesleep 0</code> y <code>pmset -a disablesleep 1</code>. Nada más.",
  rDaemon: "Ejecuta <code>pmset -a disablesleep 0</code> una vez al arrancar el Mac, así un reinicio siempre devuelve el reposo normal.",
  uninstallH: "Desinstalar",
  uninstallP: "Elige <em>Quitar el permiso…</em> en su menú (macOS pide tu contraseña otra vez), sal de la app y arrastra <code>Lid Awake.app</code> a la Papelera.",
  installerH: "Qué hace el instalador",
  installerP: "Descarga la última versión de GitHub, pone <code>Lid Awake.app</code> en <code>/Applications</code>, quita la cuarentena de la descarga (la app es de código abierto pero no está notarizada por Apple, y macOS se negaría a abrirla) y la abre. Nada más: el permiso lo pide la app, la primera vez que hace falta. Puedes <a href=\"install.sh\">leerlo</a> antes de ejecutarlo.",
  manualP: "Para instalarla a mano: descarga el zip de la <a href=\"https://github.com/make-become/lid-awake/releases/latest\">última versión</a>, mueve la app a Aplicaciones y ábrela la primera vez con clic derecho → Abrir. Para compilarla tú: <code>git clone</code> del repositorio y <code>./build.sh</code>. Necesita macOS 13 o posterior.",
  knowH: "Bueno saberlo",
  knowList: `<li>Con la tapa cerrada y el Mac encendido, sigue funcionando a toda velocidad y puede calentarse: no lo dejes en una bolsa cerrada.</li>
<li>El pitido suena por la salida actual: los altavoces internos, o los auriculares si están conectados.</li>
<li>Lid Awake también desactiva el ajuste al iniciarse: si pusiste <code>pmset disablesleep 1</code> a mano, abrir Lid Awake lo deshace.</li>
<li>Con pantalla externa, corriente y teclado, macOS ya mantiene despierto un MacBook cerrado (modo clamshell); Lid Awake es para cuando no tienes nada de eso.</li>`,
  footer: `Licencia MIT · ${MB}`,
},
fr: {
  lead: "Gardez votre MacBook allumé capot fermé, pour ce long travail. Un seul interrupteur dans la barre des menus. Quand vous fermez le capot, il bipe, même en sourdine, pour que vous sachiez que le Mac est toujours allumé ; il se désactive tout seul quand vous rouvrez le capot. Gratuit, open source.",
  altOff: "Le menu de Lid Awake, désactivé", altOn: "Le menu de Lid Awake, activé",
  installH: "Installer", installP: "Collez ceci dans le Terminal :",
  askH: "Ou demandez à Claude", askP: "Collez ceci dans Claude Code ou dans Claude Desktop (avec accès à votre Mac) :",
  prompt: `Installe Lid Awake sur mon Mac : lance \`${CMD}\` dans le terminal, puis dis-moi si son icône est apparue dans la barre des menus. Détails : https://make-become.github.io/lid-awake/details.html`,
  copy: "Copier", copied: "Copié", more: "Plus d'infos", unofficial: `Un projet ${MB}.`,
  back: "← Retour", source: "Code source sur GitHub",
  whatH: "Ce qu'il fait",
  whatList: `<li><strong>Un interrupteur</strong> dans la barre des menus, <em>Rester allumé capot fermé</em>. Pas d'icône dans le Dock, pas de fenêtre. L'icône est un portable, rouge quand il est activé.</li>
<li><strong>Un bip à la fermeture du capot</strong> quand il est activé, pour que vous sachiez que le Mac ne s'est pas mis en veille. Il s'entend même Mac en sourdine ou à volume 0 : le volume monte pour le bip et revient aussitôt comme avant.</li>
<li><strong>Il se désactive tout seul</strong> à la réouverture du capot, quand vous le quittez, s'il plante et au redémarrage du Mac. La veille n'est jamais laissée désactivée par accident.</li>
<li><strong>S'ouvre à la connexion</strong> par défaut ; décochez <em>Ouvrir à la connexion</em> dans son menu pour l'éviter.</li>
<li><strong>Langues :</strong> English, Italiano, Español, Français, Deutsch, selon les réglages du Mac.</li>`,
  whyH: "Pourquoi il demande une autorisation, une fois",
  whyP1: `macOS met un MacBook en veille quand le capot se ferme, et un seul réglage système l'en empêche : ${RULE}, que seul un administrateur peut changer. La première fois que vous activez l'interrupteur, Lid Awake l'explique et macOS demande votre mot de passe dans sa propre fenêtre. Lid Awake ne le voit ni ne le garde jamais.`,
  whyP2: "Ce qu'il installe est une règle qui permet à votre utilisateur de lancer exactement ces deux commandes sans mot de passe, et rien d'autre. Un assistant tournant en permanence en root marcherait aussi, mais ce serait un privilège permanent plus grand pour un seul réglage, et il faudrait un certificat de développeur Apple.",
  diskH: "Tout ce qu'il met sur votre Mac",
  diskIntro: "La liste complète. Rien n'est envoyé nulle part.",
  thWhere: "Où", thWhat: "Ce que c'est",
  rApp: "L'app. Environ 1 Mo.",
  rSudoers: "La règle d'une ligne : votre utilisateur peut lancer en administrateur <code>pmset -a disablesleep 0</code> et <code>pmset -a disablesleep 1</code>. Rien d'autre.",
  rDaemon: "Lance <code>pmset -a disablesleep 0</code> une fois au démarrage du Mac, pour qu'un redémarrage rende toujours la veille normale.",
  uninstallH: "Désinstaller",
  uninstallP: "Choisissez <em>Retirer l'autorisation…</em> dans son menu (macOS redemande votre mot de passe), quittez-le et glissez <code>Lid Awake.app</code> dans la Corbeille.",
  installerH: "Ce que fait l'installateur",
  installerP: "Il télécharge la dernière version depuis GitHub, met <code>Lid Awake.app</code> dans <code>/Applications</code>, retire la quarantaine du téléchargement (l'app est open source mais pas notarisée par Apple, sinon macOS refuserait de l'ouvrir) et l'ouvre. Rien d'autre : l'autorisation est demandée par l'app, la première fois qu'il en faut une. Vous pouvez <a href=\"install.sh\">le lire</a> avant de le lancer.",
  manualP: "Pour installer à la main : téléchargez le zip de la <a href=\"https://github.com/make-become/lid-awake/releases/latest\">dernière version</a>, déplacez l'app dans Applications et ouvrez-la la première fois par clic droit → Ouvrir. Pour la compiler vous-même : <code>git clone</code> du dépôt puis <code>./build.sh</code>. Nécessite macOS 13 ou plus récent.",
  knowH: "Bon à savoir",
  knowList: `<li>Capot fermé et Mac allumé, il tourne à pleine vitesse et peut chauffer : ne le laissez pas dans un sac fermé.</li>
<li>Le bip passe par la sortie audio actuelle : les haut-parleurs intégrés, ou le casque s'il est branché.</li>
<li>Lid Awake désactive aussi le réglage à son démarrage : si vous avez mis <code>pmset disablesleep 1</code> à la main, ouvrir Lid Awake l'annule.</li>
<li>Avec écran externe, alimentation et clavier, macOS garde déjà éveillé un MacBook fermé (mode clamshell) ; Lid Awake sert quand vous n'avez rien de tout cela.</li>`,
  footer: `Licence MIT · ${MB}`,
},
de: {
  lead: "Lass dein MacBook bei geschlossenem Deckel laufen, für diesen einen langen Job. Ein einziger Schalter in der Menüleiste. Beim Zuklappen piept es, auch stummgeschaltet, damit du weißt, dass der Mac noch läuft; beim Aufklappen schaltet es sich selbst aus. Kostenlos, Open Source.",
  altOff: "Das Menü von Lid Awake, ausgeschaltet", altOn: "Das Menü von Lid Awake, eingeschaltet",
  installH: "Installieren", installP: "Füge das im Terminal ein:",
  askH: "Oder lass es Claude machen", askP: "Füge das in Claude Code oder Claude Desktop ein (mit Zugriff auf deinen Mac):",
  prompt: `Installiere Lid Awake auf meinem Mac: führe \`${CMD}\` im Terminal aus und sag mir dann, ob sein Symbol in der Menüleiste erschienen ist. Details: https://make-become.github.io/lid-awake/details.html`,
  copy: "Kopieren", copied: "Kopiert", more: "Mehr Infos", unofficial: `Ein ${MB}-Projekt.`,
  back: "← Zurück", source: "Quellcode auf GitHub",
  whatH: "Was es macht",
  whatList: `<li><strong>Ein Schalter</strong> in der Menüleiste, <em>Bei geschlossenem Deckel anbleiben</em>. Kein Dock-Symbol, kein Fenster. Das Symbol ist ein Laptop, rot, solange er an ist.</li>
<li><strong>Ein Piepton beim Zuklappen</strong>, solange er an ist, damit du weißt, dass der Mac nicht schlafen gegangen ist. Hörbar auch bei stummem Mac oder Lautstärke 0: Die Lautstärke geht für den Ton hoch und gleich danach zurück.</li>
<li><strong>Es schaltet sich selbst aus</strong>, wenn du den Deckel wieder öffnest, die App beendest, sie abstürzt oder der Mac neu startet. Der Ruhezustand bleibt nie aus Versehen abgeschaltet.</li>
<li><strong>Startet beim Anmelden</strong> standardmäßig; entferne im Menü den Haken bei <em>Beim Anmelden starten</em>, um das abzustellen.</li>
<li><strong>Sprachen:</strong> English, Italiano, Español, Français, Deutsch, nach den Einstellungen des Mac.</li>`,
  whyH: "Warum es einmal um Erlaubnis fragt",
  whyP1: `macOS schickt ein MacBook beim Zuklappen schlafen, und nur eine Systemeinstellung verhindert das: ${RULE}, die nur ein Administrator ändern kann. Wenn du den Schalter zum ersten Mal einschaltest, erklärt Lid Awake das, und macOS fragt in seinem eigenen Dialog nach deinem Passwort. Lid Awake sieht oder speichert es nie.`,
  whyP2: "Installiert wird eine Regel, die deinem Benutzer genau diese zwei Befehle ohne Passwort erlaubt, sonst nichts. Ein dauernd als root laufender Helfer ginge auch, wäre aber ein größeres dauerhaftes Privileg für eine einzige Einstellung und bräuchte ein Apple-Entwicklerzertifikat.",
  diskH: "Alles, was es auf deinem Mac ablegt",
  diskIntro: "Die vollständige Liste. Nichts wird irgendwohin gesendet.",
  thWhere: "Wo", thWhat: "Was es ist",
  rApp: "Die App. Etwa 1 MB.",
  rSudoers: "Die einzeilige Regel: Dein Benutzer darf <code>pmset -a disablesleep 0</code> und <code>pmset -a disablesleep 1</code> als Administrator ausführen. Sonst nichts.",
  rDaemon: "Führt beim Start des Mac einmal <code>pmset -a disablesleep 0</code> aus, damit ein Neustart immer den normalen Ruhezustand zurückbringt.",
  uninstallH: "Deinstallieren",
  uninstallP: "Wähle im Menü <em>Erlaubnis entfernen…</em> (macOS fragt noch einmal nach dem Passwort), beende die App und zieh <code>Lid Awake.app</code> in den Papierkorb.",
  installerH: "Was der Installer macht",
  installerP: "Er lädt die neueste Version von GitHub, legt <code>Lid Awake.app</code> in <code>/Applications</code> ab, entfernt die Download-Quarantäne (die App ist Open Source, aber nicht von Apple notarisiert, sonst würde macOS sie nicht öffnen) und öffnet sie. Sonst nichts: Die Erlaubnis fragt die App selbst an, wenn sie sie zum ersten Mal braucht. Du kannst ihn <a href=\"install.sh\">lesen</a>, bevor du ihn ausführst.",
  manualP: "Von Hand installieren: das Zip der <a href=\"https://github.com/make-become/lid-awake/releases/latest\">neuesten Version</a> laden, die App in Programme verschieben und beim ersten Mal per Rechtsklick → Öffnen starten. Selbst bauen: Repository per <code>git clone</code> holen und <code>./build.sh</code> ausführen. Braucht macOS 13 oder neuer.",
  knowH: "Gut zu wissen",
  knowList: `<li>Zugeklappt und eingeschaltet läuft der Mac mit voller Leistung und kann warm werden: nicht in einer geschlossenen Tasche lassen.</li>
<li>Der Ton kommt aus der aktuellen Ausgabe: den eingebauten Lautsprechern oder dem Kopfhörer, wenn einer angeschlossen ist.</li>
<li>Lid Awake schaltet die Einstellung auch beim Start aus: Hast du <code>pmset disablesleep 1</code> von Hand gesetzt, macht der Start von Lid Awake das rückgängig.</li>
<li>Mit externem Bildschirm, Strom und Tastatur hält macOS ein zugeklapptes MacBook schon wach (Clamshell-Modus); Lid Awake ist für den Fall, dass du nichts davon hast.</li>`,
  footer: `MIT-Lizenz · ${MB}`,
},
};

function pick() {
  const q = new URLSearchParams(location.search).get("lang");
  if (q && T[q]) return q;
  try { const s = localStorage.getItem("lang"); if (s && T[s]) return s; } catch (e) {}
  for (const l of navigator.languages || [navigator.language || "en"]) { const c = l.slice(0, 2); if (T[c]) return c; }
  return "en";
}

const lang = pick();
const s = T[lang];
document.documentElement.lang = lang;
document.querySelectorAll("[data-i18n]").forEach(el => { const v = s[el.dataset.i18n]; if (v !== undefined) el.innerHTML = v; });
document.querySelectorAll("[data-i18n-alt]").forEach(el => { el.alt = s[el.dataset.i18nAlt] || ""; });
document.querySelectorAll("[data-i18n-src]").forEach(el => { el.src = el.dataset.i18nSrc.replace("{lang}", lang); });
document.querySelectorAll("[data-keep-lang]").forEach(a => { a.href = a.getAttribute("href").split("?")[0] + "?lang=" + lang; });

// The prompt is shown as text; inline `code` marks stay as typed so the copy is exactly what Claude should read.
document.querySelectorAll("[data-copy]").forEach(b => b.addEventListener("click", async () => {
  const text = document.getElementById(b.dataset.copy).textContent;
  try { await navigator.clipboard.writeText(text); }
  catch (e) { const r = document.createRange(); r.selectNodeContents(document.getElementById(b.dataset.copy)); const sel = getSelection(); sel.removeAllRanges(); sel.addRange(r); document.execCommand("copy"); }
  b.textContent = s.copied; setTimeout(() => { b.textContent = s.copy; }, 1500);
}));

const box = document.querySelector(".langs");
if (box) for (const [code, name] of Object.entries(NAMES)) {
  const a = document.createElement("a");
  a.href = "?lang=" + code; a.textContent = name;
  if (code === lang) a.setAttribute("aria-current", "true");
  a.addEventListener("click", () => { try { localStorage.setItem("lang", code); } catch (e) {} });
  box.appendChild(a);
}
})();
