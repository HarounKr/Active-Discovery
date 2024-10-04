# Liste des ports à ouvrir pour la communication AD entre DCs
$ports = @(
    53,     # DNS
    88,     # Kerberos
    123,    # NTP
    135,    # RPC Endpoint Mapper
    389,    # LDAP
    445,    # SMB
    464,    # Kerberos Password Change
    636,    # LDAP SSL
    3268,   # LDAP GC
    3269,   # LDAP GC SSL
    5722,   # DFS-R
    9389,   # AD DS Web Services, PowerShell
    49152,  # Dynamic RPC port range lower bound
    65535   # Dynamic RPC port range upper bound
)

# Création des règles de pare-feu pour les ports
foreach ($port in $ports) {
    $ruleName = "Allow AD DC Communication on port $port"
    
    # Vérification de l'existence de la règle
    $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    if ($existingRule -eq $null) {
        # Créer la règle si elle n'existe pas
        New-NetFirewallRule -DisplayName $ruleName `
                             -Direction Inbound `
                             -Protocol TCP `
                             -LocalPort $port `
                             -Action Allow `
                             -Description "Allow inbound traffic on port $port for AD DC communication"
        Write-Host "Rule created for port $port"
    } else {
        Write-Host "Rule already exists for port $port"
    }
}

# Ajout de la règle pour le protocole ICMP
$icmpRuleName = "Allow ICMP Traffic for AD DC Communication"

# Vérification de l'existence de la règle ICMP
$existingICMPRule = Get-NetFirewallRule -DisplayName $icmpRuleName -ErrorAction SilentlyContinue
if ($existingICMPRule -eq $null) {
    # Créer la règle ICMP si elle n'existe pas
    New-NetFirewallRule -DisplayName $icmpRuleName `
                         -Direction Inbound `
                         -Protocol ICMPv4 `
                         -IcmpType 8 ` 
                         -Action Allow `
                         -Description "Allow ICMP Echo Request (ping) traffic for AD DC communication"
    Write-Host "ICMP rule created"
} else {
    Write-Host "ICMP rule already exists"
}
