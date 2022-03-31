#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

is_root=false

if [ "$([[ $UID -eq 0 ]] || echo "Not root")" = "Not root" ]
   then
      is_root=false
   else
      is_root=true
fi

maysudo=""

if [ "$is_root" = "false" ]
   then
      maysudo="sudo"
   else
      maysudo=""
fi

echo "Installing NodeJS..."
$maysudo apt-get install nodejs npm -y

echo "Creating HTML5 apps directory..."
$maysudo mkdir /1/apps

echo "Creating HTML5 games directory..."
$maysudo mkdir /1/games

echo "Creating html5 directory..."
$maysudo mkdir /1/html5
echo "Adding Color Converter.html5..."
cp -f include/html5/Color\ Converter.html5 /1/html5/

echo "Installing mimetypes and their icons..." # this is continuously adding the same entries to /etc/mime.types and have to be fixed
$maysudo cat >> /etc/mime.types <<EOF
application/x-html5			        html5
application/x-apps			        apps
application/x-game			        game
EOF
$maysudo cat > /usr/share/mime/packages/x-html5.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns='http://www.freedesktop.org/standards/shared-mime-info'>
  <mime-type type="application/x-html5">
    <comment>HTML5 application</comment>
    <generic-icon name="application-x-html5"/>
    <glob pattern="*.html5"/>
  </mime-type>
</mime-info>

EOF
$maysudo cat > /usr/share/mime/packages/x-apps.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns='http://www.freedesktop.org/standards/shared-mime-info'>
  <mime-type type="application/x-apps">
    <comment>Floflis application</comment>
    <generic-icon name="application-x-apps"/>
    <glob pattern="*.apps"/>
  </mime-type>
</mime-info>

EOF
$maysudo cat > /usr/share/mime/packages/x-game.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns='http://www.freedesktop.org/standards/shared-mime-info'>
  <mime-type type="application/x-game">
    <comment>Floflis game</comment>
    <generic-icon name="application-x-game"/>
    <glob pattern="*.game"/>
  </mime-type>
</mime-info>

EOF
$maysudo update-mime-database /usr/share/mime
$maysudo gtk-update-icon-cache /usr/share/icons/gnome/ -f

echo "Installing icons for .apps, .game and .html5 files..."

git clone https://github.com/DaniellMesquita/linux-icon-builder.git

cd linux-icon-builder
sh ./linux-icon-builder "$SCRIPTPATH/include/icons/application-x-apps.png" "mimetypes" "application-x-apps.png"
sh ./linux-icon-builder "$SCRIPTPATH/include/icons/application-x-game.png" "mimetypes" "application-x-game.png"
sh ./linux-icon-builder "$SCRIPTPATH/include/icons/application-x-html5.png" "mimetypes" "application-x-html5.png"
cd icons

if [ ! -e /usr/share/icons/Floflis ]; then
   cp -r -f --preserve=all . /usr/share/icons/Yaru/
else
   cp -r -f --preserve=all . /usr/share/icons/ubuntu/Yaru/
fi

cd "$SCRIPTPATH"
rm -rf linux-icon-builder

echo "Installing handler for .apps, .game and .html5 files..."

git clone https://github.com/Floflis/floflis-application-handler.git

echo "Installing global shared NodeJS modules..."
$maysudo mkdir /1
$maysudo mkdir /1/Floflis
$maysudo mkdir /1/Floflis/libs
tar -C /1/Floflis/libs -xzf include/node_modules.tar.gz
cd /1/Floflis/libs
npm install
$maysudo chmod -R a+rwX /1/Floflis/libs/node_modules && $maysudo chown ${flouser}:${flouser} /1/Floflis/libs/node_modules
npm install
cd "$SCRIPTPATH"
echo "They'll be useful for Floflis Central and other apps/games made with the C2 engine."

# HOME LAYER -->
echo "Installing game-engines lib folder..."
$maysudo mkdir /1/Floflis/libs/game-engines
echo "Installing C2 common libs..."
tar -C /1/Floflis/libs/game-engines -xzf include/Floflis_libs_game-engines_c2.tar.gz
echo "Having common libs, C2 games/apps will be smaller to download (also to store locally)!"
# <-- HOME LAYER

echo "Protecting (read-only) C2 common libs..."
#sudo chmod -R a+rwX ${D} && sudo chown root:root /1/Floflis/libs/game-engines/c2
#sudo chown root:root /1/Floflis/libs/game-engines/c2
#sudo chown root:root /1/Floflis/libs/game-engines/c2 #- credits: https://askubuntu.com/a/193066/1255788
#sudo chmod -R 0444 /1/Floflis/libs/game-engines/c2 #- credits: https://www.cyberciti.biz/faq/howto-set-readonly-file-permission-in-linux-unix/
sudo chmod -R 0555 /1/Floflis/libs/game-engines/c2 #- credits: https://www.cyberciti.biz/faq/howto-set-readonly-file-permission-in-linux-unix/
