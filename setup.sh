#!/bin/bash
#
# description: GDM3 Theme Blur
#

work="$(cd $(dirname $0) && pwd)"


# App Name
app_name="gdm3theme-blur"
# GDM3 Theme CSS
gdm3_theme_css="gdm3-blur.css"
# GDM3 Theme CSS Template
gdm3_theme_css_template="${gdm3_theme_css}.template"
# App cache directory
cache_dir="$HOME/.cache/$app_name"

# 3 picture: Screensaver, Lockscreen wallpaper, Background
# set 2 differen blury geometry... then we have original and 2 blurry image

# Background Picture
background_picture="${cache_dir}/${app_name}-background.jpg"
# Converted for Screensaver Picture
screensaver_picture="$cache_dir/${app_name}-screensaver.jpg"
# Converted blurry image for Lockscreen wallpaper
lockscreen_wallpaper="/usr/share/backgrounds/${app_name}-lockscreen.jpg"

# Lockscreen Wallpaper Blur Geometry
[[ -z "$blur_geometry_lockscreen" ]] && blur_geometry_lockscreen="0x5"
# Screensaver Picture Blur Geometry
[[ -z "$blur_geometry_screensaver" ]] && blur_geometry_screensaver="0x15"


usage() {
  cat << EOF
Usage: $(basename $0) {-i|-u} -l -h

Options:
  -i      Install theme
  -u      Uninstall theme
  -l      List files, for development
  -h      Help
EOF
}

log_info() {
  echo -en "INFO: $1"
}

# Check if OS is supported
os_check() {
  # /etc/os-release doesn't exists. Ubuntu have /etc/os-release
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [ "$ID" = "ubuntu" ]; then
      if [ "$VERSION_ID" = "17.10" ] || [ "$VERSION_ID" = "18.04" ]; then
        os="$ID"
      fi
    fi
  fi
}

list_files() {
  echo "============================================================"
  echo "# /etc/alternatives/gdm3.css"
  ls -lh /etc/alternatives/gdm3.css
  echo
  echo "============================================================"
  echo "# ${cache_dir}"
  ls -lh "${cache_dir}/"
  echo
  echo "============================================================"
  echo "# $HOME/.cache/wallpaper/"
  ls -lh $HOME/.cache/wallpaper/
  echo
  echo "============================================================"
  echo "# $HOME/.fonts/"
  ls -lh $HOME/.fonts/
  echo
  echo "============================================================"
  echo "# $HOME/.local/share/nautilus/scripts/"
  ls -lh $HOME/.local/share/nautilus/scripts/
  echo
  echo "============================================================"
  echo "# ${lockscreen_wallpaper}"
  ls -lh "${lockscreen_wallpaper}"
  echo
  echo "============================================================"
  echo "# /usr/share/gnome-shell/theme/*.{css,bak}"
  ls -lh /usr/share/gnome-shell/theme/*.{css,bak,orig}
}

# Get Background Picture (current Wallpaper)
get_background_picture() {
  # "%20" is " " (space)
  gsettings get org.gnome.desktop.background picture-uri | sed s#file:\/\/##g | sed s/%20/" "/g | awk -F "'" '{print $2}'
}

# Get Screensaver Picture
get_screensaver_picture() {
  gsettings get org.gnome.desktop.screensaver picture-uri | sed s#file:\/\/##g | sed s/%20/" "/g | awk -F "'" '{print $2}'
}

convert_picture() {
  blur_geometry="$1"
  src_picture="$2"
  dst_picture="$3"
  sudo="$4"

  # if arg4 is sudo
  [[ "$sudo" = "sudo" ]] && sudo="/usr/bin/sudo"

  # Make your wallpaper blurry
  # /usr/share/backgrounds/LOCKSCREEN_WALLPAPER_NAME
  log_info "Convert Wallpaper:          \"${src_picture}\" -> \"${dst_picture}\"\n"
  # Make your wallpaper blurry
  if [[ $gui -eq 1 ]]; then
    ( $sudo convert -blur ${blur_geometry} "${src_picture}" "${dst_picture}" ) \
      | zenity --progress --pulsate --auto-close --no-cancel --title="Image Converter" --text="Making blurry picture: ${dst_picture}" 2>/dev/null
    [ $? -eq -1 ] && zenity --error --text="Image Converter canceled."
  else
    $sudo convert -blur ${blur_geometry} "${src_picture}" "${dst_picture}"
  fi
}

install() {
  if [ -f "/usr/share/gnome-shell/theme/${gdm3_theme_css}" ]; then
    echo "File exists: /usr/share/gnome-shell/theme/${gdm3_theme_css}"
    echo "Theme is already installed. Abort installation."
    exit 1
  fi

  # Move original ubuntu.css file
  if [ ! -f /usr/share/gnome-shell/theme/ubuntu.css.orig ]; then
    log_info "Move:                       \"/usr/share/gnome-shell/theme/ubuntu.css\" -> \"/usr/share/gnome-shell/theme/ubuntu.css.orig\"\n"
    sudo mv /usr/share/gnome-shell/theme/ubuntu.css /usr/share/gnome-shell/theme/ubuntu.css.orig
    if [[ $? -ne 0 ]]; then
      echo "Installation Aborted."
      exit 1
    fi
  fi

  # Replace %LOCKSCREEN_WALLPAPER% in GDM3 Theme CSS Template
  log_info "Make GDM3 Theme file:       \"/usr/share/gnome-shell/theme/${gdm3_theme_css}\"\n"
  # Run command in shell when you use redirection
  sudo sh -c "sed s#%LOCKSCREEN_WALLPAPER%#"${lockscreen_wallpaper}"#g ${gdm3_theme_css_template} > /usr/share/gnome-shell/theme/${gdm3_theme_css}"
  if [[ $? -ne 0 ]]; then
    echo "Installation Aborted."
    exit 1
  fi

  # Symlink "gdm3theme-blur"
  cd /usr/share/gnome-shell/theme/
  log_info "Make Symbolic Link:         \"/usr/share/gnome-shell/theme/ubuntu.css\" -> \"${gdm3_theme_css}\"\n"
  sudo ln -s ${gdm3_theme_css} ubuntu.css
  cd - &>/dev/null

  # Update Alternative gdm3.css - now use our CSS theme
  log_info "Alternative gdm3.css:       $(sudo update-alternatives --install /usr/share/gnome-shell/theme/gdm3.css gdm3.css /usr/share/gnome-shell/theme/${gdm3_theme_css} 100)\n"
  if [[ $? -ne 0 ]]; then
    echo "Installation Aborted."
    exit 1
  fi
  
  # Nautilus Script SetAsWallpaper
  if [[ ! -d ~/.local/share/nautilus/scripts/ ]]; then
    echo "~/.local/share/nautilus/scripts/ doesn't exists. Make directory."
    mkdir -p "$HOME"/.local/share/nautilus/scripts/
  fi
  log_info "Copy Nautilus script:       \"SetAsWallpaper\" -> \"$HOME/.local/share/nautilus/scripts/\"\n"
  cp "$work"/SetAsWallpaper ~/.local/share/nautilus/scripts/
  chmod +x ~/.local/share/nautilus/scripts/SetAsWallpaper

  # Fonts install
  log_info "Copy fonts:                 \".fonts\" -> \"$HOME/\"\n"
  cp -af "$work"/.fonts ~/

  # Cache
  log_info "Remove cached Wallpapers:   \"$HOME/.cache/wallpaper/*\"\n"
  rm -f $HOME/.cache/wallpaper/*

  # Get current background picture
  picture="$(get_background_picture)"

  # Set current wallpaper as blurry image
  # Background Picture
  # If cached picture already set as wallpaper
  if [ "$background_picture" = "$picture" ]; then
    log_info "Wallpaper is already set:   \"$picture\"\n"
  else
    log_info "Copy Current Wallpaper:     \"$background_picture\" -> "${picture}/"\n"
    cp "${picture}" "${background_picture}"
  fi

  # Wallpaper name without full path
  picture_filename="$(echo "$picture" | awk -F "/" '{print $NF}')"

  # Make your wallpaper blurry
  # Locksceen Wallpaper: example /usr/share/backgrounds/LOCKSCREEN_WALLPAPER.jpg
  # Screensaver Picture: example $HOME/.cache/gdm3theme-blur/picture.jpg
  convert_picture "${blur_geometry_lockscreen}" "$background_picture" "$lockscreen_wallpaper" sudo
  convert_picture "${blur_geometry_screensaver}" "$background_picture" "$screensaver_picture"

  # Set Screensaver Picture: "file://$HOME/.cache/gdm3theme-blur/gdm3-blur-screensaver.jpg"
  log_info "Set Screensaver Picture:    \"${screensaver_picture}\"\n"
  gsettings set org.gnome.desktop.screensaver picture-uri "file://${screensaver_picture}"

  echo
  log_info "Background Picture:         \"${background_picture}\"\n"
  log_info "Lockscreen Wallpaper:       \"${lockscreen_wallpaper}\"\n"
  log_info "Screensaver Picture:        \"${screensaver_picture}\"\n"
}

uninstall() {
  if [ ! -f "/usr/share/gnome-shell/theme/${gdm3_theme_css}" ]; then
    log_info "Theme isn't installed. Abort uninstall.\n"
    exit 1
  fi
  # Remove Link, back to Vanilla GDM
  if [ -L "/usr/share/gnome-shell/theme/ubuntu.css" ]; then
    sudo rm /usr/share/gnome-shell/theme/ubuntu.css
  fi
  # Back to original ubuntu.css
  if [ -f "/usr/share/gnome-shell/theme/ubuntu.css.orig" ]; then
    if [ ! -f "/usr/share/gnome-shell/theme/ubuntu.css" ]; then
      sudo mv /usr/share/gnome-shell/theme/ubuntu.css.orig /usr/share/gnome-shell/theme/ubuntu.css
    fi
  fi

  # Remove GDM3 Theme CSS Alternative
  sudo update-alternatives --remove gdm3.css /usr/share/gnome-shell/theme/${gdm3_theme_css}
  if [[ $? -ne 0 ]]; then
    log_info "Uninstall Aborted.\n"
    exit 1
  fi
  # Remove GDM3 CSS Theme
  sudo rm /usr/share/gnome-shell/theme/${gdm3_theme_css}
  # Set default CSS (Ubuntu GDM3 CSS: /usr/share/gnome-shell/theme/ubuntu.css)
  log_info "Alternative gdm3.css:           $(sudo update-alternatives --install /usr/share/gnome-shell/theme/gdm3.css gdm3.css ${gdm3_css} 10)\n"

  log_info "Remove fonts:                 \"~/.fonts/Montserrat\"\n"
  rm -rf "$HOME"/.fonts/Montserrat
  log_info "Remove Nautilus script:       \"$HOME/.local/share/nautilus/scripts/SetAsWallpaper\"\n"
  rm -f "$HOME"/.local/share/nautilus/scripts/SetAsWallpaper
  log_info "Remove Locksceen Wallpaper:   \"${lockscreen_wallpaper}\"\n"
  sudo rm -f "${lockscreen_wallpaper}"

  # Set Background Picture as Screensaver Picture
  # Probably cached image is set as wallpaper
  screensaver_picture="$(get_background_picture)"
  log_info "Set Screensaver Picture:      \"${screensaver_picture}\"\n"
  gsettings set org.gnome.desktop.screensaver picture-uri "file://${screensaver_picture}"

  echo
  log_info "Cache directory \"$cache_dir\" isn't removed.\n"
}


#----------------------------- Main
if [[ -z "$cache_dir" ]]; then
  echo "ERROR: variable \$cache_dir isn't defined in script. This is DANGEROUS."
  exit 1
fi

if [[ -z "$lockscreen_wallpaper" ]]; then
  echo "ERROR: variable \$lockscreen_wallpaper isn't defined in script. This is DANGEROUS."
  exit 1
fi

# If zenity is in $PATH and DISPLAY is set then user GUI
(which zenity &>/dev/null) && [ ! -z "$DISPLAY" ] && gui=1

# Set variable $os
os_check

log_info "OS:                         $VERSION\n"
log_info "OS (distribution ID):       $os\n"
echo

# If variable $os is empty then OS isn't supported
if [ -z "$os" ]; then
  echo "OS isn't supported. Now i supported only Ubuntu 17.10 and 18.04."
  exit 1
fi

# veriable $os from function os_check
case $os in
  ubuntu)
    # Ubuntu GDM3 CSS
    # Ubunu replace original gdm3.css from Gnome Vanilla
    gdm3_css="/usr/share/gnome-shell/theme/ubuntu.css"
    ;;
esac

# Command Line Arguments
while getopts "liuh" opt; do
  case $opt in
    l)  list_files  ;;
    i)  install ;;
    u)  uninstall ;;
    h)  usage ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

[ $# -eq 0 ] && usage

