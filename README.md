# README - les-03

## Inleiding

In deze repository zijn de uitwerkingen opgenomen van opdracht 1 tot en met 5 van LAB les-03.  
Binnen deze opdrachten is gewerkt met:

- Git en GitHub
- Terraform
- Ansible
- ESXi
- Proxmox community modules

De opdrachten zijn uitgevoerd in meerdere branches, zodat per opdracht of fase een duidelijke scheiding in versiebeheer aanwezig bleef.

---

## Gebruikte technieken

### Git / GitHub
Git is gebruikt voor versiebeheer.  
Er is gewerkt met meerdere branches:
- `test`
- `productie`
- `proxmox`

De repository zelf heet:

- `les-03`

### Terraform
Terraform is gebruikt om virtual machines op ESXi te deployen.

### Ansible
Ansible is gebruikt om de gedeployde VM’s verder te configureren.

### Cloud-init
Cloud-init is gebruikt om de SSH public key automatisch op de VM’s te plaatsen, zodat SSH-login direct mogelijk is na deployment.

### ESXi
ESXi is gebruikt als hypervisorplatform voor opdracht 1 en opdracht 3.

### Proxmox community module
Voor opdracht 5 is de juiste community Proxmox module gebruikt om een backup-playbook op te stellen.

---

# Opdracht 1

## Opdrachtomschrijving
- Maak een nieuwe repository `les-03` aan.
- Maak een nieuwe branch `test` aan en werk voor opdracht 1 en 2 in deze branch.
- Deploy met Terraform één VM.
- Zorg dat ingelogd kan worden op deze VM met een SSH-key.
- Zorg dat automatisch een inventory wordt aangemaakt tijdens deployment.

## Wat is gedaan
Voor opdracht 1 is:
- de repository `les-03` aangemaakt;
- de branch `test` aangemaakt;
- een Terraform-configuratie gemaakt voor het deployen van één Ubuntu VM op ESXi;
- SSH-toegang ingericht met een bestaande public key;
- automatisch een inventorybestand laten genereren bij deployment.

## Gemaakte keuzes
Er is gekozen om:
- vanuit één Terraform manifest te werken;
- een bestaande SSH public key te gebruiken;
- direct een inventorybestand te genereren, zodat Ansible in de volgende opdracht meteen kon worden gebruikt.

## Waarom deze keuzes
### Gebruik van één manifest
Dit houdt de configuratie eenvoudig en overzichtelijk.

### SSH-key in plaats van wachtwoord
Dit is veiliger en sluit beter aan op geautomatiseerd beheer.

### Inventory automatisch genereren
Hierdoor hoefden IP-adressen en hostinformatie niet handmatig te worden overgenomen in Ansible.

---

# Opdracht 2

## Opdrachtomschrijving
In de branch `test`:
- maak playbooks voor de volgende taken:
  - alle packages op een Ubuntu VM updaten
  - `/etc/hosts` aanpassen zodat de ESXi-server wordt toegevoegd met de naam `esxi`
  - een user `test` toevoegen op de VM
  - een lokaal bestand kopiëren naar de VM
  - een playbook maken dat `/etc/` en `/var/www/` back-upt
  - een cronjob toevoegen die dagelijks een backup maakt
  - de backup naar `/tmp` kopiëren
- voer de code uit op de VM van opdracht 1

## Wat is gedaan
In opdracht 2 is op de VM van opdracht 1 met Ansible het volgende uitgevoerd:
- packages geüpdatet;
- `/etc/hosts` aangepast;
- user `test` toegevoegd;
- een lokaal bestand naar de VM gekopieerd;
- backupfunctionaliteit ingericht voor `/etc/` en `/var/www/`;
- een cronjob toegevoegd voor dagelijkse backups;
- backupbestanden naar `/tmp` laten wegschrijven.

## Gemaakte keuzes
Er is gekozen om:
- de taken op te delen in een logische Ansible-structuur;
- gebruik te maken van een inventory uit opdracht 1;
- de backupbestanden in `/tmp` te laten plaatsen, omdat dit expliciet werd gevraagd in de opdracht.

## Waarom deze keuzes
### Gebruik van Ansible
Ansible is geschikt voor configuratiebeheer op bestaande VM’s en sluit logisch aan op de inventory die in opdracht 1 al automatisch werd gemaakt.

### `/etc/hosts` aanpassen via Ansible
Dit is reproduceerbaar en voorkomt handmatige aanpassingen op de VM.

### Backup en cronjob automatiseren
Hierdoor wordt de opdracht niet alleen eenmalig uitgevoerd, maar ook blijvend geconfigureerd.

---

# Opdracht 3

## Opdrachtomschrijving
- Gebruik de repository van opdracht 1
- Maak een nieuwe branch `productie` aan
- Deploy met Terraform drie VM’s vanuit één manifest
- Zorg dat ingelogd kan worden met een SSH-key
- Zorg dat automatisch een inventory wordt aangemaakt
- Er zijn:
  - 2 webservers
  - 1 databaseserver

## Wat is gedaan
In opdracht 3 is in de branch `productie` een Terraform-configuratie gemaakt waarmee op ESXi drie VM’s zijn gedeployed:
- `webserver-1`
- `webserver-2`
- `databaseserver`

Daarnaast is automatisch een inventory aangemaakt met groepen voor:
- webservers
- databaseserver

## Gemaakte keuzes
Er is gekozen voor:
- één manifest voor alle drie de VM’s;
- twee webservers via een herhaalconstructie;
- een aparte resource voor de databaseserver;
- automatische inventorygeneratie;
- gebruik van SSH public key voor toegang.

## Waarom deze keuzes
### Eén manifest
De opdracht vroeg expliciet om één manifest. Daarom zijn alle VM’s vanuit één Terraform-configuratie uitgerold.

### Groepen in inventory
Door direct groepen aan te maken, kon opdracht 4 later eenvoudig gebruikmaken van `[web]` en `[db]`.

### SSH-key toegang
Dit sloot aan op de eerdere opdrachten en maakte geautomatiseerd beheer mogelijk.

---

# Opdracht 4

## Opdrachtomschrijving
In de branch `productie`:
- schrijf een playbook dat op twee webservers `nginx` installeert
- en op de databaseserver `mariadb`
- het playbook moet gebruikmaken van de groepen uit de inventory van opdracht 3

## Wat is gedaan
Voor opdracht 4 is een Ansible playbook geschreven dat:
- op de groep `web` nginx installeert;
- op de groep `db` MariaDB installeert.

Hierbij is gebruikgemaakt van de inventory die automatisch uit Terraform werd gegenereerd in opdracht 3.

## Gemaakte keuzes
Er is gekozen om:
- de inventorygroepen direct te gebruiken;
- webservers en databaseserver in aparte plays of roles te behandelen;
- `become: true` te gebruiken voor pakketinstallatie.

## Waarom deze keuzes
### Groepen uit inventory gebruiken
Dit was expliciet onderdeel van de opdracht en zorgt voor een nette scheiding tussen serverrollen.

### Scheiding tussen web en db
Hierdoor blijft duidelijk welke configuratie op welke systemen van toepassing is.

### Gebruik van `become`
Installatie van nginx en MariaDB vereist rootrechten.

---

# Opdracht 5

## Opdrachtomschrijving
In een branch `proxmox`:
- schrijf een playbook dat van een Proxmox hypervisor alle VM’s back-upt
- gebruik:
  - api gebruiker: `test`
  - api wachtwoord: `test`
  - api host: `node1`
  - storage: `backup_vm`
- gebruik de juiste proxmox community module
- deze opdracht hoeft niet getest te worden

## Wat is gedaan
Voor opdracht 5 is in de branch `proxmox` een playbook geschreven dat:
- verbinding maakt met de Proxmox API;
- de juiste community Proxmox module gebruikt;
- een backup van alle VM’s op de hypervisor kan starten;
- de backup laat opslaan op storage `backup_vm`.

## Gemaakte keuzes
Er is gekozen om:
- een aparte branch `proxmox` te gebruiken;
- een los playbook te maken gericht op Proxmox;
- de juiste community module te gebruiken in plaats van losse shell-commando’s.

## Waarom deze keuzes
### Aparte branch
De opdracht vroeg expliciet om een branch `proxmox`. Daardoor blijft deze opdracht logisch gescheiden van de ESXi-opdrachten.

### Gebruik van de community module
Dit is netter en sluit aan op de opdracht, die expliciet vraagt om de juiste Proxmox community module te gebruiken.

### Niet getest
De opdracht gaf aan dat dit playbook niet getest hoefde te worden. Daarom is deze uitwerking gebaseerd op documentatie en correcte parameterinvoer.

---

# Branch-overzicht

Binnen dit repository zijn de volgende branches gebruikt:

- `test`  
  Voor opdracht 1 en 2

- `productie`  
  Voor opdracht 3 en 4

- `proxmox`  
  Voor opdracht 5

- `main`  
  Uiteindelijk ingericht als hoofdbranch voor het samenbrengen van de opdrachten

## Gemaakte keuze
Omdat de repository oorspronkelijk vanuit `test` was opgezet, is later alsnog een `main` branch aangemaakt om aan de opdracht te voldoen waarin expliciet naar `main` werd verwezen.

## Waarom deze keuze
Dit maakt de repository netter en beter uitlegbaar bij inlevering.

---

# Belangrijkste keuzes samengevat

## 1. Alleen ESXi gebruiken
Hoewel er tussentijds ook met Azure is gewerkt, is uiteindelijk gekozen om dat buiten scope te laten.  
De opdrachten in deze repository richten zich daarom volledig op ESXi en Proxmox.

## 2. SSH met public key
Voor alle VM’s is gekozen voor SSH-key toegang in plaats van wachtwoorden.

## 3. Inventory automatisch genereren
Terraform genereert inventories automatisch, zodat Ansible direct op de juiste hosts kan werken.

## 4. Branches per fase/opdracht
Door branches te gebruiken bleef het werk overzichtelijk en logisch opgesplitst.

## 5. Ansible gebruiken voor configuratie
Terraform is gebruikt voor deployment, Ansible voor configuratiebeheer.  
Deze scheiding is bewust aangehouden.

---

# Conclusie

In deze repository is een volledige workflow opgebouwd waarin:
- infrastructuur met Terraform op ESXi wordt gedeployed;
- SSH-toegang automatisch wordt ingericht;
- inventories automatisch worden gegenereerd;
- configuratiebeheer met Ansible wordt uitgevoerd;
- en een Proxmox backup-playbook wordt opgesteld met de juiste community module.

Hiermee zijn opdracht 1 tot en met 5 op een gestructureerde manier uitgewerkt.

---

# Auteur

**Naam:** Ingmar Renses  
**Repository:** `les-03`
