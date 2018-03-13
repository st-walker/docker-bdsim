# Dockerfile for BDSIM.  This image consists of 4 stages:
# Compile ROOT, then CLHEP+Geant4, then BDSIM, and finally copy all
# four to a new stage.
# The directory to mount is /mnt/bdsim/.
# Bump the labels at the bottom when updating any of the dependencies
# or BDSIM itself

# STAGE: COMPILE ROOT
FROM bdsim-compiler-base:v1.0-rc as root-builder
ENV ROOT_VERSION 6.12.06

ADD sources/root_v${ROOT_VERSION}.source.tar /var/tmp/

WORKDIR /bdsim/root-install/
WORKDIR /var/tmp/root-build/

RUN apt-get update \
    && apt-get install -y \
    libx11-dev \
    libxext-dev \
    libxft-dev \
    python \
    dpkg-dev \
    libxpm-dev \
    && cmake ../root-${ROOT_VERSION} \
    -DCMAKE_INSTALL_PREFIX=/bdsim/root-install \
    -Dcastor=OFF \
    -Ddavix=OFF \
    -Dfail-on-missing=ON \
    -Dfftw3=OFF \
    -Dfitsio=OFF \
    -Dgfal=OFF \
    -Dmathmore=OFF \
    -Dminimal=ON \
    -Dmysql=OFF \
    -Dopengl=OFF \
    -Doracle=OFF \
    -Dpgsql=OFF \
    -Dpythia6=OFF \
    -Dpythia8=OFF \
    -Dpython=OFF \
    -Droofit=OFF \
    -Dsqlite=OFF \
    -Dssl=OFF \
    -Dtmva=OFF \
    -Dx11=OFF \
    -Dxml=OFF \
    -Dxrootd=OFF \
    && rm -rf /var/lib/apt/lists/* \
    && make -j 4 install

# STAGE: COMPILE CLHEP AND GEANT4
FROM bdsim-compiler-base:v1.0-rc as geant4-builder
# Because the extracted source and the tarball for some reason have
# different versioning formats, define two envs for G4 here.
ENV G4_VERSION_A 10.03.p03
ENV G4_VERSION_B 10.3.3


# COMPILE CLHEP
COPY sources/CLHEP /var/tmp/CLHEP/

WORKDIR /var-tmp/clhep-install
WORKDIR /var/tmp/clhep-build

RUN apt-get update \
    && apt-get install -y \
    libxerces-c-dev \
    libexpat1-dev \
    && cmake ../CLHEP \
    -DCMAKE_INSTALL_PREFIX=/bdsim/clhep-install \
    && rm -rf /var/lib/apt/lists/* \
    && make -j4 install

# COMPILE GEANT4
ADD sources/geant4.${G4_VERSION_A}.tar /var/tmp/

WORKDIR /bdsim/geant4-install/

COPY sources/geant4-data /bdsim/geant4-install/share/Geant4-${G4_VERSION_B}/data/
WORKDIR /bdsim/geant4-install/share/Geant4-${G4_VERSION_B}/data/
RUN for f in *; do tar xf $f; rm $f; done

WORKDIR /var/tmp/geant4-build/

RUN cmake ../geant4.${G4_VERSION_A} \
    -DCMAKE_INSTALL_PREFIX=/bdsim//geant4-install \
    -DGEANT4_USE_SYSTEM_CLHEP=ON \
    -DGEANT4_USE_GDML=ON \
    -DCLHEP_ROOT_DIR=/bdsim/clhep-install \
    && rm -rf /var/lib/apt/lists/* \
    && make -j4 install

# STAGE: COMPILE BDSIM
FROM bdsim-compiler-base:v1.0-rc as bdsim-build
ENV CLHEP_VERSION 2.4.0.2

COPY --from=root-builder /bdsim/root-install /bdsim/root-install
COPY --from=geant4-builder /bdsim/geant4-install /bdsim/geant4-install
COPY --from=geant4-builder /bdsim/clhep-install/ /bdsim/clhep-install

COPY sources/bdsim /var/tmp/bdsim/

WORKDIR /bdsim/bdsim-install/
WORKDIR /var/tmp/bdsim-build/


RUN apt-get update \
    && apt-get install -y \
    bash \
    bison \
    flex \
    libgzstream-dev \
    libxerces-c-dev \
    libxft-dev \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"] # To source thisroot.sh
RUN source /bdsim/root-install/bin/thisroot.sh \
    && source /bdsim/geant4-install/bin/geant4.sh \
    && cmake ../bdsim \
    -DUSE_GDML=ON \
    -DCMAKE_INSTALL_PREFIX=/bdsim/bdsim-install/ \
    -DUSE_EVENTDISPLAY=OFF \
    -DCLHEP_DIR=/bdsim/clhep-install/lib/CLHEP-${CLHEP_VERSION}/ \
    && make -j4 install

# STAGE: COPY ROOT+CLHEP+G4+BDSIM to new stage.
FROM debian:stretch-slim
COPY --from=root-builder /bdsim/root-install /bdsim/root-install
COPY --from=geant4-builder /bdsim/geant4-install /bdsim/geant4-install
COPY --from=geant4-builder /bdsim/clhep-install/ /bdsim/clhep-install
COPY --from=bdsim-build /bdsim/bdsim-install/ /bdsim/bdsim-install/

RUN apt-get update \
    && apt-get install -y \
    libxerces-c-dev \
    libxft-dev \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /mnt/bdsim/

COPY entry-point.sh /bdsim/entry-point.sh
ENTRYPOINT ["/bdsim/entry-point.sh"]

LABEL maintainer="zwap082@live.rhul.ac.uk"
# # Remember to bump these when updating the ENV commands found further down.
LABEL bdsim_version="v1.0-rc"
LABEL g4_version="10.3.3"
LABEL root_version="6.12.06"
LABEL clhep_version="2.4.0.2"
