# gdm3theme-blur

<h1 align="center">
  <br>
  <a href="http://www.github.com/mfabijanic/gdm3theme-blur">
  <img src="https://raw.githubusercontent.com/mfabijanic/mfabijanic.github.io/master/gdm3theme-blur/gdm3theme-blur-01.png" alt="GDM3 Theme Blur" width="800"></a>
  <br>
  GDM3 Theme Blur
  <br>
</h1>

<h4 align="left">
GDM3 Theme Blur is based on themes:<br>
  • <a href="https://www.gnome-look.org/p/1207015/" target="_blank">
  <img src="https://cn.opendesktop.org/cache/85x85-crop/img/0/8/7/0/6e0977f47f85823d318d11d5eac795aaf55e.png"
  alt="High Ubunterra">
  High Ubunterra</a> 1.8 and<br>
  • <a href="https://www.opendesktop.org/p/1241489/" target="_blank">
  <img src="https://cn.opendesktop.org/cache/85x85-crop/img/f/2/f/0/387a128dcff69e8d49716644f271232a2b40.png"
  alt="Ocean Blue">
  Ocean Blue</a> 1.0.<br>
</h4<br><br>

<p align="left>
  • <a href="#prerequisites">Prerequisites</a><br>
  • <a href="#installation">Installation</a><br>
  • <a href="#how-to-use">How To Use</a><br>
  • <a href="#picture-setup-logic">Picture Setup Logic</a><br>
</p>



# GDM3 Theme Blur


Author:  Matej Fabijanić <root4unix@gmail.com>


Description
Theme set 3 pictures: background picture, screensaver picture and lockscreen
wallpaper.
Background picture is original selected picture. Screensaver and lockscreen
pictures are converted in two diferent blur geometry. U can change blur
geometry parameters in scripts: blur_geometry_lockscreen and
blur_geometry_screensaver.

Tested only on Ubuntu 18.04 (GDM3 xorg). I plan to support other
distributions with GDM3.



# <a name="#prerequisites">Prerequisites</a>

ImageMagic: convert



# <a name="#installation">Installation</a>


Extract downloaded file gdm3theme-blur.tar.xz and run setup script

  $ tar -xJf gdm3theme-blur.tar.xz

  $ cd gdm3theme-blur

  $ ./setup.sh -i


Setup script will convert your Gnome wallpaper and set it as blured Lock
screen picture. You can uninstall and install again and every time it will
convert current background picture.


Uninstall

  $ ./setup.sh -u


# <a name="#how-to-use">How to use</a>


Download picture from screenshots
![Wallpaper](http://matej-fabijanic.from.hr/files/2018/11/wallfab.jpg "Default Theme Wallpaper")


Now you just choose another image with right click mouse button. Go to
"Script" and click on "SetAsWallpaper".

SetAsWallpaper will set selected image as Wallpaper and set it as blurred Lock
screen. If selected picture is big it can take a wile.



# <a name="#picture-setup-logic">Picture setup logic</a>

Copy current wallpaper into
$HOME/.cache/gdm3theme-blur/gdm3theme-blur-background.jpg

Convert background to Lockscreen wallpaper:
$HOME/.cache/gdm3theme-blur/gdm3theme-blur-background.jpg ->
/usr/share/backgrounds/gdm3theme-blur-gdmlock.jpg

Convert background to screensaver picture:
$HOME/.cache/gdm3theme-blur/gdm3theme-blur-background.jpg ->
$HOME/.cache/gdm3theme-blur/gdm3theme-blur-screensaver.jpg

