FROM registry.opensuse.org/opensuse/leap:15.1

RUN zypper -n ar https://download.opensuse.org/repositories/OBS:/Server:/Unstable/openSUSE_15.1/OBS:Server:Unstable.repo &&\
    zypper -n --gpg-auto-import-keys ref -s &&\
    zypper -n in --no-recommends qemu-kvm qemu-tools perl-XML-Structured curl perl-XML-SAX perl-Compress-Zlib perl-TimeDate psmisc bsdtar
#    zypper -n --gpg-auto-import-keys in  --no-recommends obs-server curl
#
#RUN zypper -n in --no-recommends qemu-tools perl-XML-Structured curl

RUN zypper -n clean --all

COPY worker/wrapper /usr/lib/obs/server/containerworker

ENTRYPOINT /usr/lib/obs/server/containerworker
