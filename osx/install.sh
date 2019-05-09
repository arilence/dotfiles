#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure macOS defaults..."
seek_confirmation "Warning: This step may modify your OS X system defaults."
if is_confirmed; then

    # Adapted from @mathiasbynens's version
    # https://github.com/mathiasbynens/dotfiles/blob/master/.osx

    # Ask for the administrator password upfront
    sudo -v

    # Keep-alive: update existing `sudo` time stamp until `.osx` has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    #################
    #### General ####
    #################

    # Reveal IP address, hostname, OS version, etc. when clicking the clock
    # in the login window
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    # Disable screenshot shadows
    defaults write com.apple.screencapture disable-shadow -bool true
    defaults write com.apple.screencapture name "Screenshot"

    # Enable subpixel font rendering on non-Apple LCDs
    defaults write NSGlobalDomain AppleFontSmoothing -int 2

    # Enable upward two-finger swipe to show app windows
    defaults write com.apple.dock scroll-to-open -bool TRUE; killall Dock

    # Automatically hide and show the dock
    defaults write com.apple.dock autohide -bool true

    # Disables the slight delay when hoving to show the dock in "Auto-Hide" mode
    defaults write com.apple.dock autohide-delay -float 0; killall Dock

    # Disable local Time Machine snapshots
    #sudo tmutil disablelocal

    # Disable hibernation (speeds up entering sleep mode)
    sudo pmset -a hibernatemode 0

    # Stop 'Photos.app' from opening automatically when plugging in camera/sd card
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

    # Enable snap-to-grid for icons in Finder
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist >/dev/null 2>/dev/null
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist >/dev/null 2>/dev/null
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist >/dev/null 2>/dev/null


    ################
    #### Finder ####
    ################

    # Always open everything in Finder's list view.
    defaults write com.apple.Finder FXPreferredViewStyle Nlsv

    # Show the ~/Library folder.
    chflags nohidden ~/Library

    # Show icons for hard drives, servers, and removable media on the desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Finder: show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Avoid creating .DS_Store files on non physical volumes/drives
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Expand save panel (shows folder explorer instead of just file name) in finder by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Use current folder for search default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"


    ##########################
    #### Activity Monitor ####
    ##########################

    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort Activity Monitor results by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0


    #################
    #### Safari ####
    #################

    # Show the full URL in the address bar (note: this still hides the scheme)
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

    # Enable the Develop menu and the Web Inspector in Safari
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

    # Add a context menu item for showing the Web Inspector in web views
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true


    #########################
    #### Privacy Tweaks ####
    #########################

    # Disable crash reporting
    defaults write com.apple.CrashReporter DialogType none

    # Disable search data leaking in safari
    defaults write com.apple.Safari UniversalSearchEnabled -bool false
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true
    defaults write com.apple.Safari.plist WebsiteSpecificSearchEnabled -bool NO


    ####################################
    #### Kill affected applications ####
    ####################################

    for app in "Activity Monitor" "cfprefsd" \
        "Dock" "Finder" "Safari" "SystemUIServer"; do
        killall "${app}" > /dev/null 2>&1
    done


    if [ $? -ne 0 ]; then
        e_error "Configuration failed!"
        exit 1
    fi
    e_success "Success. Note that some of these changes require a logout/restart to take effect."

fi
