FROM debian:bullseye

# install base packets
RUN apt-get update
RUN apt-get -y install lib32stdc++6 lib32gcc-s1 
RUN apt-get -y install wget curl vim nginx procps 

# cs source install
RUN mkdir /steamcmd /css
RUN wget -P /steamcmd http://media.steampowered.com/installer/steamcmd_linux.tar.gz
RUN tar -xvzf /steamcmd/steamcmd_linux.tar.gz -C /steamcmd
RUN /steamcmd/steamcmd.sh +force_install_dir /css +login anonymous +app_update 232330 validate +quit || true
RUN /steamcmd/steamcmd.sh +force_install_dir /css +login anonymous +app_update 232330 validate +quit
RUN rm -rf /steamcmd

# install metamod
RUN mkdir -p /metamod
RUN wget -P /metamod https://mms.alliedmods.net/mmsdrop/1.12/mmsource-1.12.0-git1219-linux.tar.gz
RUN tar -xvzf /metamod/mmsource-1.12.0-git1219-linux.tar.gz -C /metamod
RUN mv /metamod/addons /css/cstrike/addons
RUN rm -rf /metamod

# install sourcemod
RUN mkdir -p /sourcemod
RUN wget -P /sourcemod https://sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7221-linux.tar.gz
RUN tar -xvzf /sourcemod/sourcemod-1.12.0-git7221-linux.tar.gz -C /sourcemod
RUN cp -r /sourcemod/* /css/cstrike/
RUN rm -rf /sourcemod

# install mods
RUN apt-get -y install git
RUN git clone https://github.com/Nekromio/Parachute.git
RUN rm -rf /Parachute/LICENSE /Parachute/README.md /Parachute/.git
RUN cp -r /Parachute/* /css/cstrike/
RUN rm -rf /Parachute
COPY configs/parachute.ini /css/cstrike/addons/sourcemod/configs/parachute.ini

# install maps packs
RUN mkdir -p /maps
RUN apt-get -y install unrar-free file unzip
# funpack
RUN wget -O /maps/maps.rar https://gamebanana.com/dl/352726
RUN unrar x /maps/maps.rar /maps
RUN cp /maps/*.bsp /css/cstrike/maps/
RUN rm -rf /maps/*
# little maps
RUN wget -O /maps/maps.rar https://gamebanana.com/dl/312860
RUN unrar x /maps/maps.rar /maps
RUN cp -r /maps/maps/* /css/cstrike/maps/
RUN cp -r /maps/materials/* /css/cstrike/materials/
RUN cp -r /maps/sound/* /css/cstrike/sound/
RUN rm -rf /maps/*
# fun2
RUN wget -O /maps/maps.zip https://gamebanana.com/dl/355210
RUN unzip /maps/maps.zip -d /maps
RUN cp -r /maps/cstrike/* /css/cstrike/
RUN rm -rf /maps/*
# some
RUN wget -O /maps/maps.zip https://gamebanana.com/dl/359158
RUN unrar x /maps/maps.zip /maps
RUN cp -r /maps/*.bsp /css/cstrike/maps/
RUN rm -rf /maps/*
RUN ls /css/cstrike/maps/*.bsp -1 | awk -F '/' '{print $5}' > /css/cstrike/cfg/mapcycle.txt

# copy files
COPY configs/nginx_config.conf /etc/nginx/sites-available/default
COPY configs/server.cfg /css/cstrike/cfg/
COPY kickstart.sh /kickstart.sh
COPY cstrike /css/cstrike

# setting up admin user
RUN useradd -m -u 1000 -s /bin/bash admin
RUN chown -R admin:admin /css
RUN chown -R admin:admin /kickstart.sh
RUN sed -i 's/user www-data;/user admin;/' /etc/nginx/nginx.conf && \
    chown -R admin:admin /var/lib/nginx /var/log/nginx /run
USER admin

CMD /kickstart.sh