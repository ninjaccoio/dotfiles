# dotfiles

My personal CachyOS + Hyprland configuration.

Run `bash install.sh` as your regular user. The installer currently supports
CachyOS, Arch Linux and Arch derivatives, and asks which machine configuration to use.
On Arch and other derivatives, install `paru` first. Debian/Ubuntu package
installation is not implemented. Only the notebook
configuration is currently included; desktop installation requires adding
`hypr/desktop` and `quickshell/desktop` first.

The installer installs packages, configures the SilentSDDM silvia preset, enables
SDDM for subsequent boots, and links Hyprland, Quickshell and VS Code settings.
Existing user configuration files are moved to `~/.dotfiles-backup/`.

VS Code extensions are installed from `vscode/extensions.txt` and require internet
access. Optional `vscode/keybindings.json` and `vscode/snippets/` are also linked
when present. Extensions retain their own login/setup requirements.

Brave is installed through `brave-bin`. Installing the package does not restore
its appearance or extensions.

VS Code appearance is stored in `vscode/settings.json`; on this machine it is
already symlinked, so changes made in VS Code update the repository file.
After adding/removing extensions, update the list before committing:

```sh
code --list-extensions > vscode/extensions.txt
```

To restore Brave extensions, themes and supported settings, use
[Brave Sync](https://support.brave.com/hc/en-us/articles/360021218111-How-do-I-set-up-Sync).
On the configured PC, open `brave://settings/braveSync`, create a Sync chain
and enable the relevant data categories. After running `install.sh` on a new
PC, join that chain from the same page and enable those categories there too.
Joining the chain requires a manual step; the installer does not enroll devices.
Check appearance afterwards because some local settings may need to be reapplied.
Extension-specific data may also require the extension's own export/import.
Keep the Sync code outside this repository; do not commit the browser profile.
