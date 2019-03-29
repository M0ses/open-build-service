FROM registry.opensuse.org/opensuse/leap:15.1

RUN zypper -n ar https://download.opensuse.org/repositories/OBS:/Server:/Unstable/openSUSE_15.1/OBS:Server:Unstable.repo &&\
    zypper -n --gpg-auto-import-keys ref -s &&\
    zypper -n --gpg-auto-import-keys in  --no-recommends obs-api apache2 apache2-mod_xforward rubygem-passenger-apache2

RUN zypper clean --all

COPY frontend-rails/wrapper /usr/lib/obs/server/containerwrapper
# COPY BSConfig.pm /usr/lib/obs/server/BSConfig.pm
COPY frontend-rails/database.yml /srv/www/obs/api/config/database.yml
COPY frontend-rails/options.yml /srv/www/obs/api/config/options.yml

ENTRYPOINT /usr/lib/obs/server/containerwrapper
