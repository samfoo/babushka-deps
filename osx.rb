dep 'MenuMeters.app' do
  source 'http://www.ragingmenace.com/software/download/MenuMeters.dmg'
end

dep 'VLC.app' do
  source "http://get.videolan.org/vlc/2.1.1/macosx/vlc-2.1.1.dmg"
end

dep 'VirtualBox.app' do
  source "http://download.virtualbox.org/virtualbox/4.3.4/VirtualBox-4.3.4-91027-OSX.dmg"
end

dep 'Vagrant.app' do
  requires 'VirtualBox.app'

  met? {
    "/usr/bin/vagrant".p.exists?
  }

  source "http://files.vagrantup.com/packages/a40522f5fabccb9ddabad03d836e120ff5d14093/Vagrant-1.3.5.dmg"
end

dep 'Dropbox.app' do
  source "https://www.dropbox.com/download?plat=mac"
end

dep 'Alfred.app' do
  source "http://cachefly.alfredapp.com/Alfred_2.1.1_227.zip"
end

dep 'iTerm.app' do
  source "http://iterm2.com/downloads/stable/iTerm2_v1_0_0.zip"
end

dep 'Spectacle.app' do
  source "https://s3.amazonaws.com/spectacle/downloads/Spectacle+0.8.4.zip"
end

dep 'Chromium.app' do
  source "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac/236234/chrome-mac.zip"
end

dep 'Transmission.app' do
  source 'http://download.transmissionbt.com/files/Transmission-2.82.dmg'
end

dep 'all-osx-apps' do
  requires 'MenuMeters.app'
  requires 'VLC.app'
  requires 'VirtualBox.app'
  requires 'Vagrant.app'
  requires 'iTerm.app'
  requires 'Alfred.app'
  requires 'Dropbox.app'
  requires 'Chromium.app'
  requires 'Transmission.app'
end

dep 'set-dock-magnification' do
  met? {
    shell?("defaults read com.apple.dock magnification") &&
      shell("defaults read com.apple.dock magnification").to_i == 1
  }

  meet {
    shell("defaults write com.apple.dock magnification -integer 1")
  }
end

dep 'move-dock-right' do
  met? {
    shell?("defaults read com.apple.dock orientation") &&
      shell("defaults read com.apple.dock orientation") == "right"
  }

  meet {
    shell("defaults write com.apple.dock orientation -string 'right'")
  }
end

dep 'auto-hide-dock' do
  met? {
    shell?("defaults read com.apple.dock autohide") &&
      shell("defaults read com.apple.dock autohide") == "1"
  }

  meet {
    shell("defaults write com.apple.dock autohide -bool true")
    shell("killall -HUP Dock")
  }
end

dep 'disable-widgets' do
  met? {
    cmd = "defaults read com.apple.dashboard mcx-disabled"
    shell?(cmd) &&
      shell(cmd).to_i == 1
  }

  meet {
    shell 'defaults write com.apple.dashboard mcx-disabled -boolean YES'
  }
end

dep 'fast-key-repeat' do
  met? {
    2 == shell('defaults read NSGlobalDomain KeyRepeat').to_i &&
      12 == shell('defaults read NSGlobalDomain InitialKeyRepeat').to_i
  }

  meet {
    shell('defaults write NSGlobalDomain KeyRepeat -int 2')
    shell('defaults write NSGlobalDomain InitialKeyRepeat -int 12')
  }
end

dep 'capslock-to-ctrl' do
  met? {
    cmd = "defaults -currentHost read -g com.apple.keyboard.modifiermapping.1452-610-0"
    shell?(cmd) && shell(cmd) ==
%Q{(
        {
        HIDKeyboardModifierMappingDst = 2;
        HIDKeyboardModifierMappingSrc = 0;
    }
)}
  }

  meet {
    shell("defaults -currentHost write -g com.apple.keyboard.modifiermapping.1452-610-0 -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>2</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>'")
  }
end

dep 'enable-assistive-devices' do
  met? {
    "/private/var/db/.AccessibilityAPIEnabled".p.exists?
  }

  meet {
    shell "sudo touch /private/var/db/.AccessibilityAPIEnabled"
  }
end

dep 'change-shell-to-zsh' do
  requires 'zsh.bin'

  met? {
    current_shell = shell("echo $SHELL")
    current_shell.include?("/usr/local") && current_shell.include?("zsh")
  }

  meet {
    installed_zsh = shell("brew info zsh").split("\n")[2].split(/\s/)[0]
    shell("chsh -s #{installed_zsh}")
    shell("sudo echo '#{installed_zsh}' >> /etc/shells")
  }
end

dep 'all-osx-settings' do
  requires 'capslock-to-ctrl'
  requires 'fast-key-repeat'
  requires 'disable-widgets'
  requires 'move-dock-right'
  requires 'auto-hide-dock'
  requires 'enable-assistive-devices'
  requires 'change-shell-to-zsh'
end
