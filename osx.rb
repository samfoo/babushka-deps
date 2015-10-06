dep 'MenuMeters.app' do
  source 'http://www.ragingmenace.com/software/download/MenuMeters.dmg'
end

dep 'VLC.app' do
  source "http://get.videolan.org/vlc/2.2.0/macosx/vlc-2.2.0.dmg"
end

dep 'VirtualBox.installer' do
  source "http://download.virtualbox.org/virtualbox/4.3.8/VirtualBox-4.3.8-92456-OSX.dmg"
end

# dep 'Vagrant.app' do
#   requires 'VirtualBox.installer'
# 
#   met? {
#     "/usr/bin/vagrant".p.exists?
#   }
# 
#   source "https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2.dmg"
# end

# dep 'Dropbox.app' do
#   source "https://www.dropbox.com/download?plat=mac"
# end

dep 'Alfred.app' do
  source "https://cachefly.alfredapp.com/Alfred_2.8_414.zip"
end

dep 'iTerm.app' do
  source "https://iterm2.com/downloads/stable/iTerm2_v2_0.zip"
end

dep 'Spectacle.app' do
  source "https://s3.amazonaws.com/spectacle/downloads/Spectacle+0.8.8.zip"
end

dep 'Chromium.app' do
  source "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac/273149/chrome-mac.zip"
end

dep 'FirefoxDeveloperEdition.app' do
  source "https://download-installer.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-aurora/firefox-43.0a2.en-US.mac.dmg"
end

dep 'Transmission.app' do
  source 'https://transmission.cachefly.net/Transmission-2.84.dmg'
end

dep 'MacVim.app' do
  source 'https://github-cloud.s3.amazonaws.com/releases/692798/b87eecb6-c962-11e3-8d73-867380da71e3.tbz?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIMWPLRQEC4XCWWPA%2F20151005%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20151005T043915Z&X-Amz-Expires=3600&X-Amz-Signature=90d30854b47f88619b0d3c8e5db035cca3533929e68901068abf0d756a2f0b55&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DMacVim-snapshot-73-Mavericks.tbz&response-content-type=application%2Foctet-stream'
end

dep 'all-osx-apps' do
  requires 'MenuMeters.app'
  requires 'VLC.app'
  requires 'VirtualBox.installer'
  # requires 'Vagrant.app'
  requires 'Spectacle.app'
  requires 'iTerm.app'
  requires 'Alfred.app'
  # requires 'Dropbox.app'
  requires 'Chromium.app'
  requires 'Transmission.app'
  requires 'FirefoxDeveloperEdition.app'
  requires 'MacVim.app'
end

dep 'enable-full-disk-encryption' do
  met? {
    shell?("sudo fdesetup status").include? "On"
  }

  meet {
    shell("sudo fdesetup enable -user `whoami`")
  }
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
  def vendor_and_product_id
    keyboard_info = shell("ioreg -n IOHIDKeyboard -r")
    vendor_id = keyboard_info.scan(/"VendorID" = (\d+)/).flatten.first
    product_id = keyboard_info.scan(/"ProductID" = (\d+)/).flatten.first

    [vendor_id, product_id]
  end

  met? {
    vendor_id, product_id = vendor_and_product_id
    cmd = "defaults -currentHost read -g com.apple.keyboard.modifiermapping.#{vendor_id}-#{product_id}-0"
    shell?(cmd) && shell(cmd) ==
%Q{(
        {
        HIDKeyboardModifierMappingDst = 2;
        HIDKeyboardModifierMappingSrc = 0;
    }
)}
  }

  meet {
    vendor_id, product_id = vendor_and_product_id
    shell("defaults -currentHost write -g com.apple.keyboard.modifiermapping.#{vendor_id}-#{product_id}-0 -array '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer><key>HIDKeyboardModifierMappingDst</key><integer>2</integer></dict>'")
  }
end

dep 'all-osx-settings' do
  requires 'capslock-to-ctrl'
  requires 'fast-key-repeat'
  requires 'disable-widgets'
  requires 'move-dock-right'
  requires 'auto-hide-dock'
end
