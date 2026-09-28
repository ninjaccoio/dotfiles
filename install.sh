#!/usr/bin/env bash

# ==================================================
# Shell options
# ==================================================

# -e
#   Termina immediatamente lo script se un comando fallisce.
#
# -u
#   Genera un errore se proviamo a usare una variabile non definita.
#
# -o pipefail
#   Se usiamo una pipeline (es. comando1 | comando2), la pipeline viene
#   considerata fallita se fallisce uno qualsiasi dei comandi.
#
# Queste opzioni rendono lo script più sicuro: preferiamo fermarci
# piuttosto che continuare dopo un errore.
set -euo pipefail


# ==================================================
# Paths
# ==================================================

# BASH_SOURCE[0] contiene il percorso di questo script.
#
# dirname prende solamente la directory che lo contiene.
#
# cd entra in quella directory.
#
# pwd restituisce il percorso assoluto.
#
# In questo modo NON assumiamo che i dotfiles siano in ~/dotfiles.
# Il repository può essere clonato ovunque.
#
# Esempio:
#
#   ~/dotfiles/install.sh
#
# oppure:
#
#   ~/projects/dotfiles/install.sh
#
# funzioneranno entrambi.
DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Directory standard in cui le applicazioni Linux cercano
# gran parte delle configurazioni dell'utente.
CONFIG="$HOME/.config"

# Directory in cui salveremo eventuali configurazioni già esistenti.
#
# Il timestamp evita di sovrascrivere backup precedenti.
#
# Esempio:
#
#   ~/.dotfiles-backup/20260928-103500/
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"


# ==================================================
# Functions
# ==================================================

# --------------------------------------------------
# link_config
# --------------------------------------------------
#
# Crea un symbolic link tra un file/directory nel repository
# dei dotfiles e la posizione in cui il programma si aspetta
# di trovare la configurazione.
#
# Riceve due argomenti:
#
#   $1 = source
#   $2 = target
#
# Esempio:
#
#   link_config \
#       "$DOTFILES/hypr/notebook" \
#       "$HOME/.config/hypr"
#
# Se il target:
#
#   - non esiste:
#       crea semplicemente il symlink
#
#   - è già un symlink:
#       rimuove il vecchio symlink e crea quello nuovo
#
#   - è un file/directory reale:
#       prima lo sposta nella directory di backup
#
link_config() {
    local source="$1"
    local target="$2"
    local name

    # basename rimuove tutto il percorso e mantiene solo
    # l'ultimo componente.
    #
    # Esempio:
    #
    #   /home/user/.config/hypr
    #
    # diventa:
    #
    #   hypr
    name="$(basename "$target")"

    # Prima di creare il link controlliamo che la sorgente
    # esista realmente nel repository.
    #
    # In caso contrario probabilmente il repository è incompleto
    # oppure abbiamo sbagliato il percorso.
    if [[ ! -e "$source" ]]; then
        echo "ERROR: Source does not exist: $source"
        exit 1
    fi

    echo "==> Configuring $name..."

    # -L restituisce true se il target è un symbolic link.
    #
    # In questo caso possiamo rimuovere tranquillamente il link.
    # rm rimuove SOLO il symlink, non ciò a cui punta.
    if [[ -L "$target" ]]; then
        echo "    Replacing existing symlink."
        rm "$target"

    # -e restituisce true se il target esiste.
    #
    # Arriviamo qui solamente se NON è un symlink, perché
    # il caso precedente è già stato gestito.
    #
    # Significa quindi che abbiamo trovato una vera configurazione
    # dell'utente: file o directory.
    elif [[ -e "$target" ]]; then
        echo "    Existing configuration found."
        echo "    Backing up to $BACKUP_DIR/$name"

        # Creiamo la directory di backup solo quando serve.
        #
        # -p evita errori se esiste già.
        mkdir -p "$BACKUP_DIR"

        # Spostiamo la vecchia configurazione invece di eliminarla.
        mv "$target" "$BACKUP_DIR/$name"
    fi

    # Creiamo il symbolic link.
    #
    # ln -s SOURCE TARGET
    ln -s "$source" "$target"

    echo "    $target -> $source"
}


# --------------------------------------------------
# install_arch_packages
# --------------------------------------------------
#
# Installa i pacchetti necessari sulle distribuzioni
# appartenenti alla famiglia Arch Linux.
#
# Al momento supportiamo:
#
#   - Arch Linux
#   - CachyOS
#
install_arch_packages() {
    echo "==> Installing packages with pacman..."

    # --needed:
    #   non reinstalla un pacchetto se è già installato
    #   nella versione richiesta.
    #
    # Questo rende sicuro rieseguire install.sh più volte.
    sudo pacman -S --needed \
        hyprland \
        quickshell \
        sddm

    # ------------------------------------------------
    # paru
    # ------------------------------------------------
    #
    # command -v cerca un comando nel PATH.
    #
    # >/dev/null 2>&1 nasconde sia stdout che stderr perché
    # ci interessa solamente sapere se il comando esiste.
    #
    # ! inverte il risultato:
    #
    #   se paru NON esiste -> entra nell'if
    #
    if ! command -v paru >/dev/null 2>&1; then
        echo
        echo "==> Installing paru..."

        # CachyOS distribuisce paru nei propri repository.
        #
        # Su Arch Linux puro questo potrebbe non essere disponibile
        # direttamente tramite pacman.
        #
        # Per questo distinguiamo CachyOS da Arch.
        if [[ "$DISTRO_ID" == "cachyos" ]]; then
            sudo pacman -S --needed paru
        else
            echo "ERROR: paru is required but is not installed."
            echo "Install paru first, then run this installer again."
            exit 1
        fi
    fi

    # ------------------------------------------------
    # AUR packages
    # ------------------------------------------------

    echo
    echo "==> Installing AUR packages with paru..."

    # visual-studio-code-bin è il pacchetto che stiamo usando
    # per la build ufficiale Microsoft di VS Code.
    paru -S --needed \
        visual-studio-code-bin \
        sddm-silent-theme
}


# --------------------------------------------------
# install_debian_packages
# --------------------------------------------------
#
# Punto di ingresso per Debian e distribuzioni Debian-based.
#
# IMPORTANTE:
#
# Non proviamo a tradurre automaticamente i nomi dei pacchetti Arch
# nei nomi Debian.
#
# Repository, disponibilità e metodi di installazione possono essere
# diversi tra le due distribuzioni.
#
# Aggiungeremo qui i pacchetti Debian man mano che verificheremo
# realmente come vogliamo installarli.
#
install_debian_packages() {
    echo "==> Debian-based distribution detected."

    # Aggiorna l'indice locale dei pacchetti disponibili.
    sudo apt update

    echo
    echo "ERROR: Debian package installation is not configured yet."
    echo "Add the Debian packages to install_debian_packages()."
    exit 1
}


# --------------------------------------------------
# detect_distribution
# --------------------------------------------------
#
# Determina automaticamente quale distribuzione Linux
# stiamo utilizzando.
#
# Lo standard /etc/os-release contiene informazioni come:
#
#   ID=arch
#
# oppure:
#
#   ID=cachyos
#   ID_LIKE=arch
#
# oppure:
#
#   ID=ubuntu
#   ID_LIKE=debian
#
detect_distribution() {

    # Se /etc/os-release non esiste non abbiamo un metodo
    # affidabile per determinare la distribuzione.
    if [[ ! -f /etc/os-release ]]; then
        echo "ERROR: Cannot detect Linux distribution."
        exit 1
    fi

    # "source" esegue il contenuto del file nella shell corrente.
    #
    # Dopo questa istruzione possiamo usare direttamente variabili
    # definite da /etc/os-release, come:
    #
    #   $ID
    #   $ID_LIKE
    #   $PRETTY_NAME
    #
    source /etc/os-release

    # Salviamo ID in una nostra variabile.
    #
    # Esempi:
    #
    #   arch
    #   cachyos
    #   debian
    #   ubuntu
    DISTRO_ID="$ID"

    # Alcune distribuzioni non definiscono ID_LIKE.
    #
    # ${ID_LIKE:-}
    #
    # significa:
    #
    #   usa ID_LIKE se esiste,
    #   altrimenti usa una stringa vuota.
    #
    # Questo è importante perché abbiamo `set -u`.
    DISTRO_LIKE="${ID_LIKE:-}"

    echo "==> Detected distribution: ${PRETTY_NAME:-$DISTRO_ID}"
}


# --------------------------------------------------
# install_packages
# --------------------------------------------------
#
# Decide quale funzione utilizzare per installare i pacchetti
# in base alla distribuzione rilevata.
#
install_packages() {

    case "$DISTRO_ID" in

        # Distribuzioni gestite direttamente come Arch.
        arch|cachyos)
            install_arch_packages
            ;;

        # Distribuzioni gestite direttamente come Debian.
        debian|ubuntu)
            install_debian_packages
            ;;

        *)

            # Alcune derivate potrebbero avere un ID diverso ma
            # dichiarare la famiglia tramite ID_LIKE.
            #
            # Esempio concettuale:
            #
            #   ID=qualcosa
            #   ID_LIKE=arch
            #
            # Controlliamo quindi anche quella informazione.
            if [[ " $DISTRO_LIKE " == *" arch "* ]]; then

                install_arch_packages

            elif [[ " $DISTRO_LIKE " == *" debian "* ]]; then

                install_debian_packages

            else

                echo "ERROR: Unsupported distribution: $DISTRO_ID"
                exit 1

            fi
            ;;
    esac
}


# ==================================================
# Header
# ==================================================

echo "================================"
echo "       Dotfiles installer"
echo "================================"
echo


# ==================================================
# Distribution
# ==================================================

# La distribuzione viene rilevata automaticamente.
#
# Non chiediamo all'utente qualcosa che il sistema operativo
# può già comunicarci in maniera affidabile.
detect_distribution

echo


# ==================================================
# Machine selection
# ==================================================

# Questa invece è una scelta che il sistema NON può dedurre.
#
# Vogliamo esplicitamente decidere quale configurazione
# installare su questa macchina.
echo "Select machine:"
echo
echo "  1) Notebook"
echo "  2) Desktop"
echo

read -rp "> " choice

case "$choice" in
    1)
        MACHINE="notebook"
        ;;
    2)
        MACHINE="desktop"
        ;;
    *)
        echo "ERROR: Invalid option."
        exit 1
        ;;
esac

echo
echo "Selected machine: $MACHINE"
echo


# ==================================================
# Validate dotfiles
# ==================================================

# Prima di installare o modificare qualsiasi configurazione
# controlliamo che il repository contenga ciò che ci aspettiamo.
#
# In questo modo, se manca qualcosa, falliamo subito.
[[ -d "$DOTFILES/hypr/$MACHINE" ]] || {
    echo "ERROR: Missing Hyprland configuration for $MACHINE."
    exit 1
}

[[ -d "$DOTFILES/quickshell/$MACHINE" ]] || {
    echo "ERROR: Missing Quickshell configuration for $MACHINE."
    exit 1
}


# ==================================================
# Packages
# ==================================================

# install_packages sceglierà automaticamente pacman/paru
# oppure apt in base alla distribuzione rilevata.
install_packages

# ==================================================
# SDDM
# ==================================================
#
# SDDM è il display manager utilizzato dalla nostra rice.
#
# Il pacchetto `sddm-silent-theme`, installato tramite paru,
# mantiene il codice originale di SilentSDDM in:
#
#   /usr/share/sddm/themes/silent/
#
# Non modifichiamo direttamente quei file perché appartengono
# al package manager.
#
# Nel repository manteniamo invece solamente:
#
#   sddm/sddm.conf
#       configurazione generale di SDDM
#
#   sddm/silent.conf
#       nostre personalizzazioni di SilentSDDM
#

echo "==> Configuring SDDM..."


# --------------------------------------------------
# SDDM configuration
# --------------------------------------------------
#
# Le configurazioni locali di SDDM possono essere messe in:
#
#   /etc/sddm.conf.d/
#
# Su una macchina nuova questa directory potrebbe non esistere,
# quindi la creiamo prima.
#
sudo mkdir -p /etc/sddm.conf.d


# Installiamo la configurazione generale di SDDM.
#
# A differenza delle configurazioni dentro ~/.config, qui NON
# utilizziamo un symbolic link verso il repository.
#
# Il greeter SDDM viene eseguito come utente `sddm`, che non può
# attraversare la nostra home directory privata.
#
# `install` copia il file nella destinazione e permette anche
# di impostarne esplicitamente i permessi.
#
# -D:
#   crea le directory intermedie mancanti.
#
# -m 644:
#   assegna questi permessi:
#
#       owner: lettura + scrittura
#       group: lettura
#       others: lettura
#
# In questo modo SDDM può leggere il file.
#
sudo install -Dm644 \
    "$DOTFILES/sddm/sddm.conf" \
    /etc/sddm.conf.d/10-dotfiles.conf


# --------------------------------------------------
# SilentSDDM preset
# --------------------------------------------------
#
# SilentSDDM contiene diversi preset ufficiali in:
#
#   /usr/share/sddm/themes/silent/configs/
#
# Noi utilizziamo il preset "silvia" originale.
#
# Non manteniamo una copia di silvia.conf nei dotfiles:
# utilizziamo direttamente quella fornita dal pacchetto
# sddm-silent-theme.
#
# Il file metadata.desktop contiene una riga:
#
#   ConfigFile=configs/default.conf
#
# che indica a SilentSDDM quale preset caricare.
#
# La sostituiamo con:
#
#   ConfigFile=configs/silvia.conf
#

SILENT_SDDM_METADATA="/usr/share/sddm/themes/silent/metadata.desktop"

# Verifichiamo che SilentSDDM sia stato installato correttamente
# prima di provare a modificarne la configurazione.
if [[ ! -f "$SILENT_SDDM_METADATA" ]]; then
    echo "ERROR: SilentSDDM metadata.desktop not found."
    exit 1
fi

# sed:
#
#   -i
#       modifica direttamente il file.
#
#   ^ConfigFile=
#       cerca una riga che INIZIA con "ConfigFile=".
#
#   .*
#       indica qualsiasi contenuto successivo.
#
# Quindi, indipendentemente dal preset attualmente selezionato,
# la riga diventerà:
#
#   ConfigFile=configs/silvia.conf
#
sudo sed -i \
    's|^ConfigFile=.*|ConfigFile=configs/silvia.conf|' \
    "$SILENT_SDDM_METADATA"


# --------------------------------------------------
# Enable SDDM
# --------------------------------------------------
#
# Installare SDDM non significa avviarlo automaticamente.
#
# `enable` configura systemd affinché SDDM venga avviato
# durante i boot successivi.
#
# NON utilizziamo `--now`, perché non vogliamo avviare o
# riavviare il display manager mentre install.sh è in esecuzione.
#
sudo systemctl enable sddm.service


# ==================================================
# Configuration directory
# ==================================================

# ~/.config dovrebbe normalmente esistere, ma non vogliamo
# assumere che sia così su una macchina appena installata.
#
# mkdir -p:
#
#   - crea la directory se manca
#   - non genera errore se esiste già
mkdir -p "$CONFIG"


# ==================================================
# Hyprland
# ==================================================

# Hyprland NON punta all'intera directory hypr del repository.
#
# Punta direttamente alla configurazione specifica della macchina.
#
# Notebook:
#
#   ~/.config/hypr -> <repo>/hypr/notebook
#
# Desktop:
#
#   ~/.config/hypr -> <repo>/hypr/desktop
#
link_config \
    "$DOTFILES/hypr/$MACHINE" \
    "$CONFIG/hypr"


# ==================================================
# Quickshell
# ==================================================

# Per Quickshell manteniamo invece visibile l'intera directory.
#
#   ~/.config/quickshell -> <repo>/quickshell
#
# Questo ci permette di avere:
#
#   quickshell/
#       shared/
#       notebook/
#       desktop/
#
# e usare le configurazioni nominate di Quickshell.
link_config \
    "$DOTFILES/quickshell" \
    "$CONFIG/quickshell"

# ==================================================
# VS Code
# ==================================================

# VS Code salva le configurazioni dell'utente in:
#
#   ~/.config/Code/User/
#
# A differenza di Hyprland e Quickshell, NON vogliamo creare
# un symlink dell'intera directory "User".
#
# Questa directory contiene infatti anche dati gestiti internamente
# da VS Code, come:
#
#   - History
#   - globalStorage
#   - workspaceStorage
#
# Vogliamo quindi mantenere nei dotfiles solamente i singoli file
# che rappresentano realmente la nostra configurazione.


# Su una macchina nuova questa directory potrebbe non esistere
# perché VS Code potrebbe non essere mai stato avviato.
#
# La creiamo quindi noi.
#
# -p significa:
#
#   - crea anche eventuali directory intermedie mancanti
#   - non genera errore se la directory esiste già
mkdir -p "$CONFIG/Code/User"


# Creiamo il symlink del file settings.json.
#
# Source:
#
#   <repo>/vscode/settings.json
#
# Target:
#
#   ~/.config/Code/User/settings.json
#
# Il risultato sarà:
#
#   ~/.config/Code/User/settings.json
#       ->
#   <repo>/vscode/settings.json
#
# Da questo momento, quando VS Code modifica settings.json,
# sta in realtà modificando direttamente il file presente
# nel repository dei dotfiles.
link_config \
    "$DOTFILES/vscode/settings.json" \
    "$CONFIG/Code/User/settings.json"


# ==================================================
# Done
# ==================================================

echo
echo "================================"
echo "       Installation done!"
echo "================================"
echo
echo "Machine:      $MACHINE"
echo "Distribution: ${PRETTY_NAME:-$DISTRO_ID}"
echo