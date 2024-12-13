# Script PowerShell d'Administration Windows Server

## Description globale

Ce script PowerShell est conçu comme un outil polyvalent pour l'administration et la configuration de serveurs Windows dans un environnement virtualisé ou physique. Il est orienté vers la mise en place et la gestion de services critiques tels que **Active Directory (AD), DNS, DHCP**, ainsi que la gestion des machines virtuelles (VM). Il s'adresse aussi bien aux étudiants en administration réseau qu'aux administrateurs système cherchant à automatiser les tâches répétitives.

---

## Fonctionnalités principales

### 1. **Création et gestion des machines virtuelles (VM)**
- Création de VM Windows Server Core 2022 (mode minimal sans interface graphique).
- Création de VM Windows Server avec interface graphique (GUI).
- Ajout de disques supplémentaires pour des rôles spécifiques, comme **BDD, LOGS et SYSVOL**.

---

### 2. **Configuration réseau**
- Modification de l'adresse IP d'une machine.
- Configuration des serveurs DNS et ajout de zones inversées.
- Ajout d'une machine au domaine Active Directory (jointure de domaine).

---

### 3. **Installation et configuration des rôles Windows Server**
- Installation d'Active Directory Domain Services (ADDS) avec :
  - Création d'une forêt AD.
  - Ajout d'un contrôleur de domaine secondaire.
- Configuration d'un serveur DNS pour l'AD.
- Installation et configuration d'un serveur DHCP, avec création d'étendue d'adresses IP.

---

### 4. **Automatisation des tâches critiques**
- Gestion et partitionnement des disques pour des rôles spécifiques (BDD, LOGS, SYSVOL).
- Changement de nom d’hôte et redémarrage automatisé après certaines configurations.
- Ajout et configuration d'un serveur AD Corporate.

---

### 5. **Interface utilisateur interactive**
- Un menu simple permettant de naviguer entre les fonctionnalités.
- Collecte des paramètres directement auprès de l'utilisateur via des invites dynamiques.

---

## Cas d'utilisation

- **Formation et apprentissage :**
  - Idéal pour les étudiants en administration réseau, couvrant des concepts tels que la virtualisation, la configuration réseau et l'installation de services essentiels.
- **Déploiement rapide :**
  - Automatisation de tâches répétitives pour accélérer le déploiement d'environnements de test ou de production.
- **Administration simplifiée :**
  - Centralise plusieurs outils en un seul script avec une interface intuitive.

---

## Structure et organisation

### **Fonctions principales**
- Chaque tâche est encapsulée dans une fonction autonome, ce qui facilite la maintenance et la réutilisation.
- Les fonctions incluent des instructions pas à pas pour guider l'utilisateur.

### **Interface interactive**
- La fonction `menu` centralise l'exécution des différentes fonctionnalités.
- L'utilisateur choisit l'option souhaitée via un menu numéroté.

### **Flexibilité**
- Le script prend en compte les besoins spécifiques de l'utilisateur, tels que le choix des noms de VM, des IP, ou des configurations réseau.

---

## Menu principal

Voici la liste des options proposées dans le script :

| Option | Fonctionnalité                                            |
|--------|-----------------------------------------------------------|
| 1      | Création d'une VM Windows Server Core 2022               |
| 2      | Création d'une VM Windows Server avec interface graphique |
| 3      | Modification de l'adresse IP de la machine               |
| 4      | Installation d'Active Directory Domain Services (ADDS)   |
| 5      | Installation de l'AD Corporate avec configuration disque  |
| 6      | Configuration de DNS et ajout de zones inversées         |
| 7      | Ajout de 3 disques à une VM pour AD Corporate            |
| 8      | Changement d'IP et jointure de domaine pour une machine  |
| 9      | Installation d'un contrôleur AD secondaire               |
| 10     | Installation de DNS AD                                   |
| 11     | Installation et configuration d'un serveur DHCP          |
| q      | Quitter le script                                        |

---
