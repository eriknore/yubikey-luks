info:
	@echo "builddeb      - building debian package for Ubuntu 14.04LTS"
	@echo "ppa-dev       - upload to ppa launchpad. Development"
	@echo "ppa	     - upload to ppa launchpad. Stable"

VERSION=0.4
SRC_DIR = yubikey_luks.orig

ifneq (${DST_DIR},)
	USER=$(shell whoami)
else
	USER=root
endif

debianize:
	rm -fr DEBUILD
	mkdir -p DEBUILD/${SRC_DIR}
	cp -r * DEBUILD/${SRC_DIR} || true
	(cd DEBUILD; tar -zcf yubikey-luks_${VERSION}.orig.tar.gz --exclude=${SRC_DIR}/debian  ${SRC_DIR})

builddeb: debianize
	(cd DEBUILD/${SRC_DIR}; debuild)

ppa-dev: debianize
	(cd DEBUILD/${SRC_DIR}; debuild -S)
	# Upload to launchpad:
	dput ppa:privacyidea/privacyidea-dev DEBUILD/yubikey-luks_${VERSION}-?_source.changes

ppa: debianize
	(cd DEBUILD/${SRC_DIR}; debuild -S)
	# Upload to launchpad:
	dput ppa:privacyidea/privacyidea DEBUILD/yubikey-luks_${VERSION}-?_source.changes

install:
	install -D -o ${USER} -g ${USER} -m755 hook ${DST_DIR}/usr/share/initramfs-tools/hooks/yubikey-luks
	install -D -o ${USER} -g ${USER} -m755 script-top ${DST_DIR}/usr/share/initramfs-tools/scripts/local-top/yubikey-luks
	install -D -o ${USER} -g ${USER} -m755 script-bottom ${DST_DIR}/usr/share/initramfs-tools/scripts/local-bottom/yubikey-luks
	install -D -o ${USER} -g ${USER} -m755 key-script ${DST_DIR}/usr/share/yubikey-luks/ykluks-keyscript
	install -D -o ${USER} -g ${USER} -m755 yubikey-luks-enroll ${DST_DIR}/usr/bin/yubikey-luks-enroll
	install -D -o ${USER} -g ${USER} -m644 yubikey-luks-enroll.1 ${DST_DIR}/usr/man/man1/yubikey-luks-enroll.1
ifeq (${USER},root)
	update-initramfs -u
endif
