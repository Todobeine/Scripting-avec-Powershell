# Fonction pour mettre en pause l'exécution et afficher un message
function pause ($message="Appuyer sur la touche continuer") {
    Write-Host -NoNewline $message
    $null = $Host.UI.RawUI.Readkey("noecho,includekeydown")  # Attend une entrée clavier sans écho
    Write-Host ""
}

# Fonction pour créer une VM Windows Server Core 2022
function win22core () {
    $nomvm = read-host "Saisir le nom de la vm"  # Nom de la VM
    $taillememoire = Read-Host "Saisir la memoire desiree"  # Taille mémoire
    $memory = Invoke-Expression $taillememoire  # Évaluer la mémoire saisie
    Get-VMSwitch | Format-Table  # Liste les commutateurs réseau disponibles
    $commutateur = Read-Host "Saisir le commutateur"  # Choix du commutateur
    # Création de la VM avec les paramètres saisis
    New-VM -Name "$nomvm" -Path "D:\VM" -MemoryStartupBytes $memory -Generation 1 -Switch $commutateur
    # Copie du disque système préparé dans le dossier de la VM
    Copy-Item -Path "C:\Users\lucas\Desktop\Sysprep\WSERVERCOREsysprep.vhdx" -Destination "D:\VM\$nomvm\$nomvm.vhdx"
    Add-VMHardDiskDrive -VMname "$nomvm" -Path "D:\VM\$nomvm\$nomvm.vhdx"  # Attache le disque dur
    Set-VM -Name "$nomvm" -ProcessorCount 2  # Configure 2 processeurs
    Set-VM -Name "$nomvm" -CheckpointType Disabled  # Désactive les points de contrôle
    Start-VM "$nomvm"  # Démarre la VM
}

# Fonction pour créer une VM Windows Server avec interface graphique
function win22gui () {
    $nomvm = read-host "Saisir le nom de la vm"
    $taillememoire = Read-Host "saisir la memoire desiree"
    $memory = Invoke-Expression $taillememoire
    Get-VMSwitch | Format-Table
    $commutateur = Read-Host "Saisir le commutateur"
    New-VM -Name "$nomvm" -Path "D:\VM" -MemoryStartupBytes $memory -Generation 1 -Switch $commutateur
    # Copie du disque système préparé avec interface graphique
    Copy-Item -Path "C:\Users\lucas\Desktop\Sysprep\WSERVERsysprepGUI.vhdx" -Destination "D:\VM\$nomvm\$nomvm.vhdx"
    Add-VMHardDiskDrive -VMname "$nomvm" -Path "D:\VM\$nomvm\$nomvm.vhdx"
    Set-VM -Name "$nomvm" -ProcessorCount 2
    Set-VM -Name "$nomvm" -CheckpointType Disabled
    Start-VM "$nomvm"
}

# Fonction pour changer l'adresse IP et renommer la machine
function newip() {
    Get-NetIPAddress | Format-Table  # Affiche les configurations réseau actuelles
    $intindex = Read-Host "Saisir l'interface index de la carte reseau"
    $iphost = Read-Host "Saisir la nouvelle ip de la machine"
    $mask = Read-Host "Saisir le CIDR du reseau"
    $ipgw = Read-Host "Saisir la passerelle par defaut"
    Remove-NetRoute -InterfaceIndex $intindex -Confirm:$false  # Supprime les routes actuelles
    Remove-NetIPAddress -InterfaceIndex $intindex -Confirm:$false  # Supprime l'ancienne IP
    # Configure la nouvelle IP
    New-NetIPAddress -interfaceindex $intindex -AddressFamily IPv4 -IPAddress $iphost -PrefixLength $mask -DefaultGateway $ipgw
    $namepc = Read-Host "Saisir le nouveau nom de la machine"
    Rename-Computer -NewName $namepc  # Renomme la machine
    Shutdown -t 0 -r  # Redémarre immédiatement
}

# Fonction pour configurer un Active Directory avec structure Corporate
function addscorp() {
    Get-Disk | Format-Table  # Liste les disques
    $diskbdd = Read-Host "Saisir le numéro de disque pour la BDD"
    Initialize-Disk -Number $diskbdd  # Initialise le disque pour la base de données
    New-Partition -DiskNumber $diskbdd -DriveLetter B -Size 4GB
    Format-Volume -DriveLetter B -FileSystem NTFS -Confirm:$false -NewFileSystemLabel BDD
    # Répète la configuration pour LOGS et SYSVOL
    Get-Disk | Format-Table
    $disklogs = Read-Host "Saisir le numéro de disque pour la LOGS"
    Initialize-Disk -Number $disklogs
    New-Partition -DiskNumber $disklogs -DriveLetter L -Size 4GB
    Format-Volume -DriveLetter L -FileSystem NTFS -Confirm:$false -NewFileSystemLabel LOGS
    $disksysvol = Read-Host "Saisir le numéro de disque pour la SYSVOL"
    Initialize-Disk -Number $disksysvol
    New-Partition -DiskNumber $disksysvol -DriveLetter S -Size 4GB
    Format-Volume -DriveLetter S -FileSystem NTFS -Confirm:$false -NewFileSystemLabel SYSVOL
    # Configuration du domaine Active Directory
    $namedomaine = Read-Host "Saisir le nom de domaine"
    $netbiosname = Read-Host "Saisir le nom netbios"
    Add-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -IncludeAllSubFeature
    Import-Module ADDSDeployment
    Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "B:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName $namedomaine `
    -DomainNetbiosName $netbiosname `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "L:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "S:\SYSVOL" `
    -Force:$true
}

# Fonction pour installer un contrôleur de domaine Active Directory
function adds() {
    $namedomaine = Read-Host "Saisir le nom de domaine" # Demande le nom de domaine
    $netbiosname = Read-Host "Saisir le nom netbios"   # Demande le nom NetBIOS
    Add-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -IncludeAllSubFeature # Installe les fonctionnalités AD DS
    Import-Module ADDSDeployment # Charge le module AD DS Deployment
    Install-ADDSForest ` # Configure un nouveau domaine forestier
    -CreateDnsDelegation:$false ` # Ne crée pas de délégation DNS
    -DatabasePath "B:\Windows\NTDS" ` # Chemin de la base de données Active Directory
    -DomainMode "WinThreshold" ` # Définit le mode de domaine
    -DomainName $namedomaine ` # Utilise le nom de domaine fourni
    -DomainNetbiosName $netbiosname ` # Utilise le nom NetBIOS fourni
    -ForestMode "WinThreshold" ` # Définit le mode de la forêt
    -InstallDns:$true ` # Installe le serveur DNS
    -LogPath "L:\Windows\NTDS" ` # Chemin des journaux
    -NoRebootOnCompletion:$false ` # Redémarre la machine une fois terminé
    -SysvolPath "C:\Windows\SYSVOL" ` # Chemin pour SYSVOL
    -Force:$true # Force l'exécution sans confirmation supplémentaire
}

# Fonction pour configurer une zone DNS inversée
function reverse() {
    Get-DnsClientServerAddress | Format-Table # Affiche les adresses des serveurs DNS
    $indexint = Read-Host "Saisir l'interface index" # Demande l'index de l'interface réseau
    $serverad = Read-Host "Saisir l'IP du serveur DNS" # Demande l'adresse IP du serveur DNS
    Get-DnsClientServerAddress -InterfaceIndex $indexint -AddressFamily IPv6 | Set-DnsClientServerAddress -ResetServerAddresses # Réinitialise les adresses DNS IPv6
    Set-DnsClientServerAddress -InterfaceIndex $indexint -ServerAddresses $serverad # Configure le serveur DNS principal
    $zoneinverse = Read-Host "Saisir l'ip du reseau au format IP/CIDR" # Demande la plage du réseau
    Add-DnsServerPrimaryZone -NetworkId $zoneinverse -ReplicationScope Domain -DynamicUpdate Secure # Ajoute une zone DNS inversée
    ipconfig /registerdns # Enregistre les DNS
}

# Fonction pour ajouter 3 disques durs virtuels à une VM
function disk3() {
    Get-VM | Select-Object Name, State | Format-Table # Liste les VMs disponibles
    $vmname2 = Read-Host "Saisir le nom de la VM" # Demande le nom de la VM
    $cheminVMsup = "D:\VM\$vmname2" # Définit le chemin de stockage des disques virtuels
    # Création des disques virtuels
    New-VHD -Path $cheminVMsup"\bdd.vhdx" -SizeBytes 4196MB # Crée un disque pour la base de données
    New-VHD -Path $cheminVMsup"\logs.vhdx" -SizeBytes 4196MB # Crée un disque pour les journaux
    New-VHD -Path $cheminVMsup"\sysvol.vhdx" -SizeBytes 4196MB # Crée un disque pour SYSVOL
    # Attache les disques à la VM
    Add-VMHardDiskDrive -VMName $vmname2 -ControllerType SCSI -ControllerNumber 0 -Path $cheminVMsup"\bdd.vhdx"
    Add-VMHardDiskDrive -VMName $vmname2 -ControllerType SCSI -ControllerNumber 0 -Path $cheminVMsup"\logs.vhdx"
    Add-VMHardDiskDrive -VMName $vmname2 -ControllerType SCSI -ControllerNumber 0 -Path $cheminVMsup"\sysvol.vhdx"
}

# Fonction pour configurer une adresse IP et joindre un domaine
function ipad2() {
    Get-DnsClientServerAddress | Format-Table # Affiche les adresses des serveurs DNS
    $ideint = Read-Host "Saisir l'interface index" # Demande l'index de l'interface réseau
    $dnsad = Read-Host "Saisir le dns du domain AD" # Demande l'adresse DNS du domaine AD
    Set-DnsClientServerAddress -InterfaceIndex $ideint -ServerAddresses $dnsad # Configure l'adresse DNS
    $addomain = Read-Host "Saisir le domaine à joindre" # Demande le nom du domaine
    $credentials = Get-Credential # Demande les informations d'identification pour la jonction
    Add-Computer -DomainName $addomain -Restart -Credential $credentials # Joint l'ordinateur au domaine et redémarre
}

# Fonction pour configurer un contrôleur de domaine secondaire avec des disques dédiés
function adredonde() {
    Get-Disk | Format-Table # Affiche la liste des disques disponibles
    $diskbdd = Read-Host "Saisir le numero de disque pour la BDD" # Demande le disque pour la base de données
    Initialize-Disk -Number $diskbdd # Initialise le disque
    New-Partition -DiskNumber $diskbdd -DriveLetter B -Size 4GB # Crée une partition pour la base de données
    Format-Volume -DriveLetter B -FileSystem NTFS -Confirm:$false -NewFileSystemLabel BDD # Formate le volume

    $disklogs = Read-Host "Saisir le numero de disque pour les LOGS" # Répète pour les journaux
    Initialize-Disk -Number $disklogs
    New-Partition -DiskNumber $disklogs -DriveLetter L -Size 4GB
    Format-Volume -DriveLetter L -FileSystem NTFS -Confirm:$false -NewFileSystemLabel LOGS

    $disksysvol = Read-Host "Saisir le numero de disque pour le SYSVOL" # Répète pour SYSVOL
    Initialize-Disk -Number $disksysvol
    New-Partition -DiskNumber $disksysvol -DriveLetter S -Size 4GB
    Format-Volume -DriveLetter S -FileSystem NTFS -Confirm:$false -NewFileSystemLabel SYSVOL

    $namadom = Read-Host "Saisir le nom de domaine" # Demande le nom du domaine
    Add-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -IncludeAllSubFeature # Installe les services AD DS
    Import-Module ADDSDeployment # Charge le module AD DS Deployment
    Install-ADDSDomainController ` # Configure le contrôleur de domaine
    -NoGlobalCatalog:$false `
    -CreateDnsDelegation:$false `
    -DatabasePath "B:\NTDS" `
    -DomainName $namadom `
    -InstallDns:$true `
    -LogPath "L:\NTDS" `
    -SysvolPath "S:\SYSVOL" `
    -Force:$true
}

# Fonction pour configurer un serveur DNS
function dnsad2() {
    Get-DnsClientServerAddress | Format-Table # Affiche les adresses des serveurs DNS
    $indexint = Read-Host "Saisir l'interface index" # Demande l'index de l'interface réseau
    $serverad = Read-Host "Saisir l'IP du serveur DNS" # Demande l'adresse IP du serveur DNS
    Get-DnsClientServerAddress -InterfaceIndex $indexint -AddressFamily IPv6 | Set-DnsClientServerAddress -ResetServerAddresses # Réinitialise IPv6
    Set-DnsClientServerAddress -InterfaceIndex $indexint -ServerAddresses $serverad # Configure IPv4
}

# Fonction pour configurer un serveur DHCP
function dhcp() {
    $rangedeb = Read-Host "Saisir le debut de l'etendue" # Demande le début de la plage d'adresses
    $rangefin = Read-Host "Saisir la fin de l'etendue" # Demande la fin de la plage d'adresses
    $maskdhcp = Read-Host "Saisir le masque" # Demande le masque de sous-réseau
    $networkdhcp = Read-Host "Saisir l'adresse du reseau" # Demande l'adresse réseau
    $domainedhcp = Read-Host "Saisir le nom de domaine" # Demande le nom de domaine
    $dnsdhcp = Read-Host "Saisir le dns du domaine" # Demande l'adresse DNS
    $gwdhcp = Read-Host "Saisir la passerelle" # Demande la passerelle
    $dhcpname = Read-Host "Saisir le nom de l'etendue" # Nom de l'étendue DHCP
    $fqdndhcp = Read-Host "Saisir le FQDN du serveur DHCP (namenetbois,nomdedomaine)" # FQDN du serveur DHCP

    Install-WindowsFeature DHCP -IncludeManagementTools # Installe les services DHCP
    Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -value 2 # Configure DHCP
    Add-DHCPServerv4Scope -Name $dhcpname -StartRange $rangedeb -EndRange $rangefin -SubnetMask $maskdhcp -state active # Ajoute une étendue DHCP
    Set-DhcpServerv4OptionValue $networkdhcp -DnsDomain $domainedhcp -DnsServer $dnsdhcp -Router $gwdhcp # Configure les options DHCP
    Add-DhcpServerInDC -DNSName $fqdndhcp # Ajoute le serveur DHCP dans le domaine
}

# Fonction principale pour afficher un menu interactif
function menu() {
    Clear-Host
    Write-Host "Menu Script"
    # Affiche les options disponibles
    Write-Host "1: Creation VM Windows Server Core 2022"
    Write-Host "2: Creation VM Windows Server Graphique 2022"
    Write-host "3: Changer IP de la machine"
    Write-host "4: Installation ADDS"
    Write-host "5: Installation active directory Corporate"
    Write-host "6: Gestion DNS et zone inversee"
    Write-host "7: Ajouter 3 disques dur à une VM (AD Corporate)"
    Write-host "8: AD2 changer IP et jointure de domaine"
    Write-host "9: Installation AD secondaire (Corporate)"
    Write-host "10: Installation DNS AD"
    Write-host "11: Serveur DHCP"
    Write-Host "q: Quitter le script"
    $choix = Read-Host "votre choix" # Demande le choix de l'utilisateur
    switch ($choix) {
        # Chaque choix appelle la fonction correspondante
        1 {win22core;pause;menu}
        2 {win22gui;pause;menu}
        3 {newip;pause;menu}
        4 {adds;pause;menu}
        5 {addscorp;pause;menu}
        6 {reverse;pause;menu}
        7 {disk3;pause;menu}
        8 {ipad2;pause;menu}
        9 {adredonde;pause;menu}
        10 {dnsad2;pause;menu}
        11 {dhcp;pause;menu}
        q {exit} # Quitte le script
        default {menu} # Retourne au menu si une option invalide est entrée
    }
}
menu # Lance le menu principal
