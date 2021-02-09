<###############################################################################################
#
# SFTP Download Assistant 
#
#
# Dieses Script installiert den WinFsp und den sshfs, um ein Netzlaufwerk Verbindung herzustellen. (mit GUI)
#
#
# 09.02.2021   SUSH : V_1.5
#
################################################################################################>

#--------------------------------------------------------------------------------------------------------------------------------------------#
#Speicherort der Files in C:\users\benutzername\downloads
$file = "$env:USERPROFILE\downloads\sshfs-win-3.5.20024-x64*.msi","$env:USERPROFILE\downloads\winfsp-1.8.20276*.msi"
#Entscheidet ob der Downloadbalken angezeigt werden sollte. Stop/ Inquire/ Continue/ SilentlyContinue
$ProgressPreference = "silentlycontinue"

#Conventiert das Icon für das EXE
# This base64 string holds the bytes that make up the orange 'G' icon (just an example for a 32x32 pixel image)
$iconBase64      = "#icon base64 code"
$iconBytes       = [Convert]::FromBase64String($iconBase64)
$stream          = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
$stream.Write($iconBytes, 0, $iconBytes.Length);
$iconImage       = [System.Drawing.Image]::FromStream($stream, $true)
$Icon       = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())

#Checkt ob das Gerät eine Internetverbindung hat. Falls nicht kommt eine Meldung
function internet{

if((Test-Connection www.google.com -Count 1 -Quiet)-eq $false){
$form = New-Object System.Windows.Forms.Form
$form.Text = 'SFTP Assistant'
$form.Size = New-Object System.Drawing.Size(310,140)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'fixeddialog'
$form.TopMost = $true
$form.BackColor = "White"
$form.FormBorderStyle = "fixeddialog"
$form.MaximizeBox = $false
$form.Icon = $icon

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(110,70)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$okButton.Text = 'OK'
$form.Controls.Add($okButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(260,40)
$label.Text = 'Achtung! Keine Internetverbindung vorhanden.'
$form.Controls.Add($label)

$form.ShowDialog()

kill -ProcessName powershell_ise
kill -ProcessName powershell

}
    }

#die erste Funktion ist für den Download und die Installation zuständig
function form1{
if (((Test-Path "C:\Program Files\SSHFS-Win\bin")-and(Test-Path "C:\Program Files (x86)\WinFsp\bin"))-eq $false){
#Ladet die .NET-Erweiterungen (Assemblies)
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

#Die Grundform
$form = New-Object System.Windows.Forms.Form
$form.Text = 'SFTP Assistant'
$form.Size = New-Object System.Drawing.Size(300,280)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'fixeddialog'
$form.BackColor = "White"
$form.FormBorderStyle = "fixeddialog"
$form.MaximizeBox = $false
$form.Icon = $Icon

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(270,60)
$label.Text = 'Bitte klicken Sie auf "Starten", damit im Hintergrund SSHFS-Win und WinFsp installiert werden können.'
$form.Controls.Add($label)

$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,80)
$label1.Size = New-Object System.Drawing.Size(140,23)
$label1.Text = 'Fehlende(s) Produkt(e):'
$form.Controls.Add($label1)

#zeigt das fehlende Produkt an
$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,110)
$label2.Size = New-Object System.Drawing.Size(270,23)
$label2.Text = '- SSHFS-Win'
if((test-path "C:\Program Files\SSHFS-Win\bin")-eq $false){
$form.Controls.Add($label2)
}

#zeigt das fehlende Produkt an
$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(10,140)
$label3.Size = New-Object System.Drawing.Size(270,23)
$label3.Text = '- WinFsp'
if((test-path "C:\Program Files (x86)\WinFsp\bin")-eq $false){
$form.Controls.Add($label3)
}





#Startknopf um die Download zustarten
$start = New-Object System.Windows.Forms.Button
$start.Location = New-Object System.Drawing.Size(100,190)
$start.Size = New-Object System.Drawing.Size(80,30)
$start.Text = "Starten"
$start.Add_Click(
{



#----------------------------------------------------------------------#

#schliesst die Form nach dem erledigen des des Skripts
$form.Close()




#lädt die MSI Dateien herunter via Cloud. Die Files werden im Download Folder gespeichert
foreach($msifile in $file){
#lädt nur die Files herunter wenn sie nicht vorhanden sind
if((Test-Path $msifile)-eq $false){
$ProgressPreference = "silentlycontinue"
Start-BitsTransfer -Source https://./MSI/sshfs-win-3.5.20024-x64.msi -Destination $env:USERPROFILE\downloads\
Start-BitsTransfer -Source https://./MSI/winfsp-1.8.20276.msi -Destination $env:USERPROFILE\downloads\

}


#installiert die MSI Dateien
if (((Test-Path "C:\Program Files\SSHFS-Win\bin"))-eq $false){
$ProgressPreference = "continue"
Start-Process "msiexec.exe" -ArgumentList "/i $env:USERPROFILE\downloads\sshfs-win-3.5.20024-x64.msi /quiet /passive /qn /norestart" -verb runs -Wait
}

if (((Test-Path "C:\Program Files (x86)\WinFsp\bin"))-eq $false){
$ProgressPreference = "continue"
Start-Process "msiexec.exe" -ArgumentList "/i $env:USERPROFILE\downloads\winfsp-1.8.20276.msi /quiet /passive /qn /norestart" -Verb runas -Wait


}

}

#----------------------------------------------------------------------#

#Falls nach der installation immer noch nicht beide Programme installiert sind taucht eine Fehlermeldung auf
If(((Test-Path "C:\Program Files\SSHFS-Win\bin")-and(Test-Path "C:\Program Files (x86)\WinFsp\bin"))-eq $false){


#Die Grundform
$form1 = New-Object System.Windows.Forms.Form
$form1.Text = 'SFTP Assistant'
$form1.Size = New-Object System.Drawing.Size(300,280)
$form1.StartPosition = 'CenterScreen'
$form1.FormBorderStyle = 'fixeddialog'
$form1.BackColor = "White"
$form1.MaximizeBox = $false
$form1.FormBorderStyle = "Fixeddialog"
$form1.Icon = $icon

#Welche Gründe könnte es sein
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(270,120)
$label.Text = 'Etwas ist schiefgelaufen :/

- Versuchen Sie es mit einem Neustart
- Stellen Sie sicher, dass eine Internetverbindung vorhanden ist
- Stellen Sie sicher, dass die Installationen mit Adminrechte durchgeführt werden
- Führen Sie die Installationen erneut durch
- Laden Sie die Programme manuell herunter'
$form1.Controls.Add($label)

#schliesst alle Fenster
$Okbutton = New-Object System.Windows.Forms.Button
$Okbutton.Location = New-Object System.Drawing.Size(50,190)
$Okbutton.Size = New-Object System.Drawing.Size(80,30)
$Okbutton.Text = "Verstanden"
$Okbutton.DialogResult = [System.Windows.Forms.DialogResult]::Ok 

$form1.AcceptButton = $Okbutton

$form1.Controls.Add($Okbutton)

#führt ein Neustart durch
$neustart = New-Object System.Windows.Forms.Button
$neustart.Location = New-Object System.Drawing.Size(150,190)
$neustart.Size = New-Object System.Drawing.Size(80,30)
$neustart.Text = "Neustarten"
$neustart.Add_Click({
#----------------------------------------------------------------------#

#Die Grundform (Absicherung damit man nicht ausversehen auf Neustart klickt)
$form2 = New-Object System.Windows.Forms.Form
$form2.Text = 'SFTP Assistant'
$form2.Size = New-Object System.Drawing.Size(280,150)
$form2.StartPosition = 'CenterScreen'
$form2.FormBorderStyle = 'fixeddialog'
$form2.BackColor = "White"
$form2.MaximizeBox = $false
$form2.Icon = $icon

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(270,30)
$label.Text = 'Sind Sie sicher, dass sie neustarten möchten?'

$form2.Controls.Add($label)


$start = New-Object System.Windows.Forms.Button
$start.Location = New-Object System.Drawing.Size(40,70)
$start.Size = New-Object System.Drawing.Size(80,30)
$start.Text = "Neustarten"
$start.Add_Click({

#Neustart Befehlt
Restart-Computer -ComputerName $env:COMPUTERNAME

})

$form2.Controls.Add($start)


$cancelbutton = New-Object System.Windows.Forms.Button
$cancelbutton.Location = New-Object System.Drawing.Size(140,70)
$cancelbutton.Size = New-Object System.Drawing.Size(80,30)
$cancelbutton.Text = "Abbrechen"
$cancelbutton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form2.CancelButton = $cancelbutton

$form2.Controls.Add($cancelbutton)



$form2.ShowDialog()
})
#----------------------------------------------------------------------#

$form1.Controls.Add($neustart)


[void] $form1.ShowDialog()


}



})

$Form.Controls.Add($start)


#----------------------------------------------------------------------#




[void] $form.ShowDialog()


}
}
#--------------------------------------------------------------------------------------------------------------------------------------------#
#erstellt das Verzeichnis
New-Item -Path c:\SFTP -ItemType Directory -ErrorAction SilentlyContinue -Force | Out-Null
#Lädt den SFTP Tool herunter
Start-BitsTransfer -Source https://./MSI/SFTP_Download_Assistant_GUI_V1.5.ps1 -Destination c:\SFTP
#Der Pfad wo dieses Tool gerade ausgeführt wird
$currentlocation = (Get-Location).Path 
#Der aktueller Pfad mit dem Filename
$quellfile = "$currentlocation\SFTP_Download_Assistant_GUI_V1.5.ps1" 
#Das vorher heruntergeladene Tool ausgewählt damit man ein vergleich durchführen kann
$Zielfile = "c:\SFTP\SFTP_Download_Assistant_GUI_V1.5.ps1" | Sort-Object lastAccessTime -Descending | select -First 1
$txtfile = "C:\SFTP\HIER_NICHTS_SPEICHERN.txt"
if((Test-Path $txtfile)-eq $false){New-Item $txtfile -ItemType File | Out-Null 
$text = "Dieses Verzeichnis ist nicht dazu da, um den SFTP_Download_Assistant_GUI_V1.5.ps1 zu speichern.
Andere Dokumente hier zu speichern, sind auch nicht erwünscht." 
Add-Content -Path $txtfile -Value $text
}
#--------------------------------------------------------------------------------------------------------------------------------------------#

#Ganzer Path mit Filename 
$fullpath = Get-ChildItem $currentlocation -Filter SFTP_Download_Assistant_GUI_V1.5.ps1 | % {$_.FullName}


#fügt ein Ausschluss hinzu
#function Ausschluss{
#
#$defenderlisten = get-MpPreference
#
#foreach($defenderlist in $defenderlisten){
#
#if($defenderlist.exclusionpath -notcontains $fullpath){
#Add-MpPreference -ExclusionPath $fullpath
#
#    
#   }
#
#      }
#
#        }

#--------------------------------------------------------------------------------------------------------------------------------------------#


function update{
#nimmt den Hash Wert der zwei Dateien und vergleicht sie. Ist der Hash Wert nicht gleich kommt die Meldung, dass ein Update verfügbar ist.
if(((Get-FileHash $quellfile).hash -eq (Get-FileHash $Zielfile).hash)-eq $false){

$form = New-Object System.Windows.Forms.Form
$form.Text = 'SFTP Assistant'
$form.Size = New-Object System.Drawing.Size(310,140)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'fixeddialog'
$form.MaximizeBox = $false
$form.TopMost = $true
$form.BackColor = "White"
$form.Icon = $icon

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(60,70)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$okButton.Text = 'Nicht jetzt'
$form.Controls.Add($okButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(260,40)
$label.Text = 'Ein Update ist verfügbar! Bitte laden Sie den neusten Assistant herunter.'
$form.Controls.Add($label)

$updateButton = New-Object System.Windows.Forms.Button
$updateButton.Location = New-Object System.Drawing.Point(160,70)
$updateButton.Size = New-Object System.Drawing.Size(75,23)
$updateButton.Text = 'Updaten'
$form.Controls.Add($updateButton)
$updateButton.add_click{

#lädt den Updater herunter
Start-BitsTransfer -Source https://./MSI/SFTP_Updater.exe -Destination $currentlocation
#führt den Updater aus
Start-Process $currentlocation/SFTP_Updater.exe 


}

$form.ShowDialog()

    }

#löscht den Vergleich Assistant
Remove-Item -Path c:\SFTP\SFTP_Download_Assistant_GUI_V1.5.ps1

}


#--------------------------------------------------------------------------------------------------------------------------------------------#

#Checkt den nächsten freien Laufwerkbuchstabe (D-Z)
$laufwerkbuchstabe = ls function:[d-z]: -n | ?{ !(test-path $_) } | select -First 1 

#Laufwerkbuchstabe ohne ":"
$buchstabe = $laufwerkbuchstabe -replace ':' 


#Funktion Part 2 ist zuständig für die Verbindung zum Netzlaufwerk (Login-Fenster)
function Form2 {

#Ladet die .NET-Erweiterungen (Assemblies)
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")


#Die Grundform
$form = New-Object System.Windows.Forms.Form
$form.Text = 'SFTP Assistant'
$form.Size = New-Object System.Drawing.Size(260,260)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'fixeddialog'
$form.MaximizeBox = $false
$form.TopMost = $true
$form.BackColor = "White"
$form.Icon = $icon


$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(30,190)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$form.Controls.Add($okButton)


#löscht noch den Updater falls es noch drauf ist. Siehe function Updater
if(Test-Path $currentlocation/SFTP_Updater.exe){
Remove-Item -Path $currentlocation/SFTP_Updater.exe
}

#--------------------------------------------------------------------------------------------------------------------------------------------#


#nach dem OK Button werden die Inhalte der Textboxe umgewandelt                               
$okButton.add_click({
 
$benutzername = $textBox.Text
$passwort = $textBox1.text
#$securepw = $passwort | ConvertTo-SecureString -AsPlainText -Force
$Ordner = "\\sshfs\"

#credential für die Authentifizierung zum Netzlaufwerk
#$credential = New-Object System.Management.Automation.PSCredential ($benutzername, $securepw)


#ist der wichtigster Teil im Part 2. Ist dafür da, mit dem Netzlaufwerk zu verbinden
cmd.exe /c "net use $laufwerkbuchstabe $Ordner $passwort /user:$benutzername /persistent:yes"
#----------------------------------------------------------------------#

#laufwerkbuchstabe herausfinden welches dem SFTP-Netzlaufwerk gegeben wurde
$psdrive = Get-WmiObject win32_logicaldisk | ? {$_.providername -like "\\sshfs\*"}
$bestehenderlaufwerkbuchstabe = $psdrive.deviceid

#----------------------------------------------------------------------#

if($bestehenderlaufwerkbuchstabe){
#Fehlermeldung falls die Verbindung zum Netzlaufwerk fehlschlägt (Wenn es schon eine Verbindung gibt)
if((Test-Path $laufwerkbuchstabe)-eq $false){

$form = New-Object System.Windows.Forms.Form
$form.Text = 'SFTP Assistant'
$form.Size = New-Object System.Drawing.Size(310,200)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'fixeddialog'
$form.MaximizeBox = $false
$form.TopMost = $true
$form.BackColor = "White"
$form.Icon = $icon

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(110,130)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$okButton.Text = 'OK'
$form.Controls.Add($okButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(260,110)
$label.Text = 'Anmeldung fehlgeschlagen...

Mögliche Fehler:

- Falscher Benutzername oder Passwort
- Das Netzlaufwerk exestiert bereits'
$form.Controls.Add($label)

$form.ShowDialog()

#laufwerkbuchstabe herausfinden welches dem SFTP-Netzlaufwerk gegeben wurde
$psdrive = Get-WmiObject win32_logicaldisk | ? {$_.providername -like "\\sshfs\*"}
$bestehenderlaufwerkbuchstabe = $psdrive.deviceid


foreach($bestehenderlaufwerkbuchstaben in $bestehenderlaufwerkbuchstabe){
Start-Process "$bestehenderlaufwerkbuchstaben"
}

    }
        }   
#----------------------------------------------------------------------#

foreach($bestehenderlaufwerkbuchstaben in $bestehenderlaufwerkbuchstabe){
if(Test-Path "$bestehenderlaufwerkbuchstaben"){

#ändert den Anzeigename des Netzlaufwerks
New-ItemProperty -Path "HKCU:\software\microsoft\windows\currentversion\explorer\mountpoints2\##sshfs#..." -name _LabelFromReg -PropertyType string -Value "SFTP" -Force

$form.Close()

#öffnet die Laufwerkverbindung
Start-Process "$bestehenderlaufwerkbuchstaben"
#schliesst sich selber (Nur exe)
kill -ProcessName powershell_ise
kill -ProcessName powershell


}
   }
       
#----------------------------------------------------------------------#


#Fehlermeldung falls die Verbindung zum Netzlaufwerk fehlschlägt (Wenn es noch keine Verbindungen gibt)
if($bestehenderlaufwerkbuchstabe.Length -eq 0){

$form = New-Object System.Windows.Forms.Form
$form.Text = 'SFTP Assistant'
$form.Size = New-Object System.Drawing.Size(310,140)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'fixeddialog'
$form.MaximizeBox = $false
$form.TopMost = $true
$form.BackColor = "White"
$form.Icon = $icon

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(110,70)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$okButton.Text = 'OK'
$form.Controls.Add($okButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(260,40)
$label.Text = 'Falscher Benutzername oder Passwort.'
$form.Controls.Add($label)

$form.ShowDialog()
}
    
#----------------------------------------------------------------------#  


#Entfernt die MSI Dateien wenn beide Programme erfolgreich installiert wurden
if((Test-Path "C:\Program Files\SSHFS-Win\bin")-and(Test-Path "C:\Program Files (x86)\WinFsp\bin")){
foreach($msifile in $file){


Remove-Item -Path $msifile -Force


}
   }

 
#Schaut ob die Netzlaufverbindung schon steht, wenn ja schliesst er das Programm und öffnet den Explorer mit der Verbindung zum Netzlaufwerk
 if(Test-Path "$bestehenderlaufwerkbuchstaben"){


Start-Process "$bestehenderlaufwerkbuchstaben"
exit

   }

})

#----------------------------------------------------------------------##----------------------------------------------------------------------#

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(140,190)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)


$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(200,30)
$label.Text = "Anmeldung an Ihren Netzlaufwerk"
$form.Controls.Add($label)


$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,50)
$label1.Size = New-Object System.Drawing.Size(260,23)
$label1.Text = 'Benutzername:'
$form.Controls.Add($label1)


$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,75)
$textBox.Size = New-Object System.Drawing.Size(230,30)
$form.Controls.Add($textBox)
#Wenn man im Passwortfeld Enter klickt wird der OK Button ausgeführt
$textBox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
      
       $okButton.PerformClick()

      }
       })


$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,120)
$label2.Size = New-Object System.Drawing.Size(260,23)
$label2.Text = 'Passwort:'
$form.Controls.Add($label2)



$textBox1 = New-Object System.Windows.Forms.MaskedTextBox
$textBox1.Location = New-Object System.Drawing.Point(10,145)
$textBox1.Size = New-Object System.Drawing.Size(230,30)
$textBox1.PasswordChar = '*'
$form.Controls.Add($textBox1)
#Wenn man im Passwortfeld Enter klickt wird der OK Button ausgeführt
$textBox1.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
      
       $okButton.PerformClick()

    }
})



$form.ShowDialog()



}



#----------------------------------------------------------------------#
#Fügt ein Ausschluss im Defender hinzu

Ausschluss

#--------------------------------------------------------------------------------------------------------------------------------------------#
#Tested ob Internet vorhanden ist
internet

#----------------------------------------------------------------------#
#Checkt ob eine neue Version draussen ist
update

#----------------------------------------------------------------------#

#Führt die Funktion einmal durch
form1


#----------------------------------------------------------------------#


#führt Part 2 aus wenn beide Programme installiert wurden, sonst erscheint das Login Fenster nicht
if (((Test-Path "C:\Program Files\SSHFS-Win\bin")-and(Test-Path "C:\Program Files (x86)\WinFsp\bin"))-eq $true){

Form2

}
#----------------------------------------------------------------------#





