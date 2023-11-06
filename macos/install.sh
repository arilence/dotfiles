#!/usr/bin/env bash

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

echo "Asking for the administrator password for the duration of this script"
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#################
#### General ####
#################

# Set computer name
HOSTNAME="anthony-macbook"
sudo scutil --set ComputerName $HOSTNAME
sudo scutil --set LocalHostName $HOSTNAME
sudo scutil --set HostName $HOSTNAME
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $HOSTNAME

echo "Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window"
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

echo "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo "Save to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "Prevent Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo "Disable hibernation (speeds up entering sleep mode)"
sudo pmset -a hibernatemode 0

echo "Stop 'Photos.app' from opening automatically when plugging in camera/sd card"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

echo "Disable crash reporting"
defaults write com.apple.CrashReporter DialogType none

echo "Trackpad: enable tap to click for this user and for the login screen"
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Doesn't work currently
# echo "Trackpad: disable notification center on swipe from right edge"
# defaults write com.apple.AppleMultitouch.Trackpad TwoFingerFromRightEdgeSwipeGesture -int 0
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TwoFingerFromRightEdgeSwipeGesture -int 0

echo "Keyboard: Disable press-and-hold for keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo "Keyboard: Set a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 3
defaults write NSGlobalDomain InitialKeyRepeat -int 18

# This doesn't persist between reboots
#echo "Keyboard: Change caps lock to control key"
## Reference:
## - https://developer.apple.com/library/archive/technotes/tn2450/_index.html
## - https://dchakarov.com/blog/macbook-remap-keys/
#hidutil property --set '{"UserKeyMapping":
    #[
     #{"HIDKeyboardModifierMappingSrc":0x700000039,
      #"HIDKeyboardModifierMappingDst":0x7000000e0}
    #]
#}'

echo "Bluetooth: Increase sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

###############
#### Power ####
###############

echo "Disable Hibernation mode"
# 0: Disable hibernation (speeds up entering sleep mode)
# 3: Copy RAM to disk so the system state can still be restored in case of a power failure.
sudo pmset -a hibernatemode 0

################
#### Screen ####
################

echo "Save screenshots to the desktop"
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

echo "Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)"
defaults write com.apple.screencapture type -string "png"

echo "Disable screenshot shadows"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture name "Screenshot"

#echo "Enable subpixel font rendering on non-Apple LCDs"
## Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
#defaults write NSGlobalDomain AppleFontSmoothing -int 1

#echo "Disable Font Smoothing Disabler in macOS Mojave"
## Reference: https://ahmadawais.com/fix-macos-mojave-font-rendering-issue/
#defaults write -g CGFontRenderingFontSmoothingDisabled -bool FALSE

#echo "Enable HiDPI display modes (requires restart)"
#sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

################
#### Finder ####
################

echo "Set Desktop as the default location for new Finder windows"
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

echo "Always open everything in Finder's list view"
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.Finder FXPreferredViewStyle Nlsv
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

echo "Show the ~/Library folder"
chflags nohidden ~/Library

echo "Show the /Volumes folder"
sudo chflags nohidden /Volumes

echo "Show icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

echo "Finder: show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Finder: show path bar"
defaults write com.apple.finder ShowPathbar -bool true

echo "Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "Avoid creating .DS_Store files on non physical volumes/drives"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo "Expand save panel (shows folder explorer instead of just file name) in finder by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo "Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "Use current folder for search default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "Remove recent tags"
defaults write com.apple.finder ShowRecentTags 0

echo "Keep folders on top when sorting by name"
defaults write com.apple.finder _FXSortFoldersFirst -bool true

echo "Disable the warning before emptying the Trash"
defaults write com.apple.finder WarnOnEmptyTrash -bool false

echo "Enable snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

echo "Increase grid spacing for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist

echo "Increase the size of icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist

##############
#### Dock ####
##############

echo "Set the icon size of Dock items to 64 pixels"
defaults write com.apple.dock tilesize -int 64

echo "Set minimize/maximize window effect to genie"
# Valid options: genie, suck, scale
defaults write com.apple.dock mineffect -string "genie"

echo "Don't minimize windows into their application's icon"
defaults write com.apple.dock minimize-to-application -bool false

echo "Show indicator lights for open applications in the Dock"
defaults write com.apple.dock show-process-indicators -bool true

echo "Animate opening applications from the Dock"
defaults write com.apple.dock launchanim -bool true

echo "Disable upward two-finger swipe to show app windows"
defaults write com.apple.dock scroll-to-open -bool false; killall Dock

echo "Automatically hide and show the dock"
defaults write com.apple.dock autohide -bool true

echo "Disables the slight delay when hoving to show the dock in "Auto-Hide" mode"
defaults write com.apple.dock autohide-delay -float 0; killall Dock

echo "Make Dock icons of hidden applications translucent"
defaults write com.apple.dock showhidden -bool true

echo "Don't show recent applications in Dock"
defaults write com.apple.dock show-recents -bool false

echo "Disable the Launchpad gesture (pinch with thumb and three fingers)"
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

##########################
#### Activity Monitor ####
##########################

echo "Show the main window when launching Activity Monitor"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

echo "Show all processes in Activity Monitor"
defaults write com.apple.ActivityMonitor ShowCategory -int 0

echo "Sort Activity Monitor results by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

################
#### Safari ####
################

echo "Show the full URL in the address bar (note: this still hides the scheme)"
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

echo "Enable the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

echo "Add a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

echo "Disable search data leaking in safari"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
defaults write com.apple.Safari.plist WebsiteSpecificSearchEnabled -bool NO

###################
#### Spotlight ####
###################

echo "Change indexing order and disable some search results"
defaults write com.apple.spotlight orderedItems -array \
'{"enabled" = 1;"name" = "APPLICATIONS";}' \
'{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
'{"enabled" = 1;"name" = "DIRECTORIES";}' \
'{"enabled" = 1;"name" = "PDF";}' \
'{"enabled" = 1;"name" = "FONTS";}' \
'{"enabled" = 0;"name" = "DOCUMENTS";}' \
'{"enabled" = 0;"name" = "MESSAGES";}' \
'{"enabled" = 0;"name" = "CONTACT";}' \
'{"enabled" = 0;"name" = "EVENT_TODO";}' \
'{"enabled" = 0;"name" = "IMAGES";}' \
'{"enabled" = 0;"name" = "BOOKMARKS";}' \
'{"enabled" = 0;"name" = "MUSIC";}' \
'{"enabled" = 0;"name" = "MOVIES";}' \
'{"enabled" = 0;"name" = "PRESENTATIONS";}' \
'{"enabled" = 0;"name" = "SPREADSHEETS";}' \
'{"enabled" = 0;"name" = "SOURCE";}' \
'{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
'{"enabled" = 0;"name" = "MENU_OTHER";}' \
'{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
'{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
'{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
'{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
# Load new settings before rebuilding the index
killall mds > /dev/null 2>&1
# Make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null
# Rebuild the index from scratch
sudo mdutil -E / > /dev/null

####################################
#### Kill affected applications ####
####################################

echo "Activating plist changes"
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

#echo "Killing affected applications"
#for app in "Activity Monitor" \
      #"Dock" \
      #"Finder" \
      #"Photos" \
      #"Safari" \
      #"cfprefsd" \
      #"SystemUIServer"; do
#killall "${app}" > /dev/null 2>&1
#done

echo "Done. Restart computer to reflect all changes"
