
# Status of apm environment

- lxd: fail because atom is not available on arm architecture, thus incompatible with macos silicon
- docker: build succeed but attempting to install an apm plugin produce:
  ```bash
  apm install minimap
  Installing minimap to /home/nikita/.atom/packages /usr/share/atom/resources/app/apm/lib/install.js:256
            if (body.releases.latest) {
                              ^
  TypeError: Cannot read property 'latest' of undefined
  ```
