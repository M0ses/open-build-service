FROM registry.opensuse.org/opensuse/leap:15.1

RUN zypper -n ar https://download.opensuse.org/repositories/OBS:/Server:/Unstable/openSUSE_15.1/OBS:Server:Unstable.repo &&\
    zypper -n --gpg-auto-import-keys ref -s &&\
    zypper -n --gpg-auto-import-keys in  --no-recommends mariadb-client iputils curl

RUN zypper clean --all

COPY debug/wrapper /usr/lib/obs/server/containerwrapper

ENTRYPOINT /usr/lib/obs/server/containerwrapper
