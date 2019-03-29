FROM registry.opensuse.org/opensuse/leap:15.1

RUN zypper -n ar https://download.opensuse.org/repositories/OBS:/Server:/Unstable/openSUSE_15.1/OBS:Server:Unstable.repo &&\
    zypper -n --gpg-auto-import-keys ref -s &&\
    zypper -n --gpg-auto-import-keys in  --no-recommends obs-server
RUN zypper -n --gpg-auto-import-keys in  --no-recommends mariadb
RUN zypper clean --all

COPY srcserver/wrapper /usr/lib/obs/server/containerwrapper
COPY BSConfig.pm /usr/lib/obs/server/BSConfig.pm


ENTRYPOINT /usr/lib/obs/server/containerwrapper
