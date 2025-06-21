# Docker container for MusicBrainz Picard
[![Release](https://img.shields.io/github/release/jlesage/docker-musicbrainz-picard.svg?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-musicbrainz-picard/releases/latest)
[![Docker Image Size](https://img.shields.io/docker/image-size/jlesage/musicbrainz-picard/latest?logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/musicbrainz-picard/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/jlesage/musicbrainz-picard?label=Pulls&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/musicbrainz-picard)
[![Docker Stars](https://img.shields.io/docker/stars/jlesage/musicbrainz-picard?label=Stars&logo=docker&style=for-the-badge)](https://hub.docker.com/r/jlesage/musicbrainz-picard)
[![Build Status](https://img.shields.io/github/actions/workflow/status/jlesage/docker-musicbrainz-picard/build-image.yml?logo=github&branch=master&style=for-the-badge)](https://github.com/jlesage/docker-musicbrainz-picard/actions/workflows/build-image.yml)
[![Source](https://img.shields.io/badge/Source-GitHub-blue?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-musicbrainz-picard)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg?style=for-the-badge)](https://paypal.me/JocelynLeSage)

This is a Docker container for [MusicBrainz Picard](https://picard.musicbrainz.org).

The graphical user interface (GUI) of the application can be accessed through a
modern web browser, requiring no installation or configuration on the client

---

[![MusicBrainz Picard logo](https://images.weserv.nl/?url=raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/musicbrainz-picard-icon.png&w=110)](https://picard.musicbrainz.org)[![MusicBrainz Picard](https://images.placeholders.dev/?width=576&height=110&fontFamily=monospace&fontWeight=400&fontSize=52&text=MusicBrainz%20Picard&bgColor=rgba(0,0,0,0.0)&textColor=rgba(121,121,121,1))](https://picard.musicbrainz.org)

MusicBrainz Picard is a cross-platform music tagger powered by the MusicBrainz
database.

---

## Quick Start

**NOTE**:
    The Docker command provided in this quick start is an example, and parameters
    should be adjusted to suit your needs.

Launch the MusicBrainz Picard docker container with the following command:
```shell
docker run -d \
    --name=musicbrainz-picard \
    -p 5800:5800 \
    -v /docker/appdata/musicbrainz-picard:/config:rw \
    -v /home/user:/storage:rw \
    --device /dev/sr0 \
    jlesage/musicbrainz-picard
```

Where:

  - `/docker/appdata/musicbrainz-picard`: Stores the application's configuration, state, logs, and any files requiring persistency.
  - `/home/user`: Contains files from the host that need to be accessible to the application.
  - `/dev/sr0`: This is the Linux device file representing the optical drive.

Access the MusicBrainz Picard GUI by browsing to `http://your-host-ip:5800`.
Files from the host appear under the `/storage` folder in the container.

## Documentation

Full documentation is available at https://github.com/jlesage/docker-musicbrainz-picard.

## Support or Contact

Having troubles with the container or have questions? Please
[create a new issue](https://github.com/jlesage/docker-musicbrainz-picard/issues).

For other Dockerized applications, visit https://jlesage.github.io/docker-apps.
