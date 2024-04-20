# [DE] Powershell-SimpleMCServerUpdater
Dieses Skript dient zum teilautomatisierten Updaten von Minecraft-Servern (Paper, Spigot, Bukkit) und dessen Plugins.

Es bereitet die im Verzeichnis enthaltenen .jar-Dateien für den Upload vor und prüft Dateiabhängigkeiten.
Es sortiert veraltete Plugins und Serverversionen aus und lädt nur die jeweils neuste Verstion auf den Server hoch.
Im Anschluss startet es den Server Automatisch neu.


<h2> Wie benutzen? </h2>
<ol>
    <li>Verschiebe das Skript in den Zielordner.</li>
    <li>Öffne das Skript in einem Codeeditor und trage FTP- und MCRcon-Logindaten ein.</li>
    <li>Starte das Skript um zu Testen, ob alle Logindaten korrekt eingetragen wurden. (Anzeige ist beim erststart im DEBUG-Modus) </li>
    <li>Nach der (erfolgreichen) Prüfung, wirst du gefragt ob du das Skript im DEBUG-Modus fortsetzen willst.
    <li>Beende es an dieser Stelle indem du es schließt.</li>
    <li>Lade die zu aktualisierenden Plugins und Serverversionen in die dafür erstellten Ordner.</li>
    <li>Starte das Skript erneut.</li>
    <li>Überprüfe den Erfolg des Updates und erhalte Infos zu den aktualisierten Versionen und Plugins.</li>
</ol>



# [EN] Powershell-SimpleMCServerUpdater
This script is used for semi-automated updating of Minecraft servers (Paper, Spigot, Bukkit) and their plugins.

It prepares the .jar files contained in the directory for upload and checks file dependencies.
It sorts out outdated plugins and server versions and only uploads the latest version to the server.
It then restarts the server automatically.

<h2> How to use it? </h2>
<ol>
    <li>Move the script to the target folder.</li>
    <li>Open the script in a code editor and enter the FTP and MCRcon login data.</li>
    <li>Run the script to test whether all login data has been entered correctly. (Display is in DEBUG mode at first start) </li>
    <li>After the (successful) check, you will be asked if you want to continue the script in DEBUG mode.</li>
    <li>End it at this point by closing it.</li>
    <li>Load the plugins and server versions to be updated into the folders created for this purpose.</li>
    <li>Restart the script.</li>
    <li>Check the success of the update and receive information about the updated versions and plugins.</li>
</ol>




<!-- Verschiebe das Skript in das Verzeichnis, in welchem es zukünftig arbeiten soll.
Öffne die .ps1 Datei mit Notepad++ oder einem anderen Codeeditor. 
Trage im Teil "In diesem Abschnitt können alle nötigen Variablen und Logindaten festgelegt werden." deine Logindaten für MCRcon und FTP ein und speichere das Skript.
Starte das Skript.
Beim Erststart wird das Skript im DEBUG-Modus ausgeführt um alle nötigen Ordner zu erstellen und deine eingetragenen Logindaten zu prüfen.
Wenn alles korrekt war, wirst du gefragt, ob du das Skript im DEBUG-Modus fortsetzen willst. Beende das Skript an dieser Stelle.
Lade nun deine zu Updatenden Plugins und ServerVersionen in die dafür erstellten Ordner.
Starte das Skript erneut.
Nach Abschluss wird dir angezeigt, ob alles geklappt hat. Wenn ja, werden die Außerdem die neue Serverversion und alle erfolgreich Installieren Plugins angezeigt.-->
