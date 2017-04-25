FROM hypriot/rpi-node:6.9

# Set environment variables
# ENV appDir /var/www/app/current
# URL_LAUNCHER_URL
# URL_LAUNCHER_NODE
# URL_LAUNCHER_KIOSK
# URL_LAUNCHER_TITLE
# URL_LAUNCHER_FRAME
# URL_LAUNCHER_CONSOLE
# URL_LAUNCHER_WIDTH
# URL_LAUNCHER_HEIGHT
# URL_LAUNCHER_TOUCH
# URL_LAUNCHER_TOUCH_SIMULATE
# URL_LAUNCHER_ZOOM
# URL_LAUNCHER_OVERLAY_SCROLLBARS

# debian httpredir mirror proxy often ends up with 404s - editing source file to avoid it
RUN sed -i "s!httpredir.debian.org!`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`!" /etc/apt/sources.list

COPY debian-pinning /etc/apt/preferences.d/

# Install other apt deps
RUN apt-get update && apt-get install -y \
  apt-utils \
  clang \
  xserver-xorg-core \
  xserver-xorg-input-all \
  xserver-xorg-video-fbdev \
  xorg \
  libdbus-1-dev \
  libgtk2.0-dev \
  libnotify-dev \
  libgnome-keyring-dev \
  libgconf2-dev \
  libasound2-dev \
  libcap-dev \
  libcups2-dev \
  libxtst-dev \
  libxss1 \
  libnss3-dev \
  fluxbox \
  libsmbclient \
  libssh-4 \
  fbset \
  libexpat-dev && rm -rf /var/lib/apt/lists/*

# Set Xorg and FLUXBOX preferences
RUN mkdir ~/.fluxbox
RUN echo "xset s off" > ~/.fluxbox/startup && echo "xserver-command=X -s 0 dpms" >> ~/.fluxbox/startup
RUN echo "#!/bin/bash" > /etc/X11/xinit/xserverrc \
  && echo "" >> /etc/X11/xinit/xserverrc \
  && echo 'exec /usr/bin/X -s 0 dpms -nocursor -nolisten tcp "$@"' >> /etc/X11/xinit/xserverrc

# Move to app dir
WORKDIR /usr/src/app
RUN git clone https://github.com/estebanrfp/resin-electronjs.git /usr/src/app/
# Move package.json to filesystem
COPY ./app/package.json ./

# Install npm modules for the application
RUN JOBS=MAX npm install --unsafe-perm --production \
	&& npm cache clean && node_modules/.bin/electron-rebuild

# Move app to filesystem
COPY ./app ./

RUN npm i -g pm2

RUN ls -al
## uncomment if you want systemd
#ENV INITSYSTEM on

# Start app
# CMD ["bash", "/usr/src/app/start.sh"]
CMD ["pm2-dev", "/usr/src/app/process.yml"]
