# Graphite Carbon Docker Container

## Quick Start

```bash
# start graphite
docker run -d -p "2003:2003" -p "2004:2004" -p "7002:7002" -p "8000:8000" -p "80:80" --name graphite_carbon erwinnttdata/graphite_carbon
# start grafana
docker run -d -p "3000:3000" --link "graphite_carbon:graphine" --name "grafana" grafana/grafana
```

## Description

Since Graphite 1.10.0 is not yet released, the Docker image will be based
on the Git repository master branch. To make the build reproducible, the 
Whisper, Graphite and Carbon versions are fixed on the master's commit hash.

Installs Whitenoise, Whisper, Carbon, Graphine, Gunicorn and Nginx and starts
them via Supervisord. The Graphine web UI can be then accessed
on port 8000 directly or using the Nginx proxy on port 80.

The directory `/var/lib/graphite/storage/whisper` is where the database
is stored and is exported as a volume.

To serve the Graphite Web UI in a URL prefix, override the file
`/opt/graphite/webapp/graphite/local_settings.py`.

## Build

The build and deployment can be started by using the included `Makefile` 
build file.

```
# Build the Docker image.
make build
# Deploy the Docker image.
make deploy DOCKER_HUB_USER=user DOCKER_HUB_PASSWORD='password'
```

To test the build locally, the included `Makefile` also have the goals
* `test-graphine`
  Starts the build Graphine image.
* `test-grafana`
  Starts Grafana that can access the Graphite API.
* `test-seyren`
  Starts Seyren that can access the Graphite API.

# License

*The MIT License (MIT)*

Copyright (c) 2016 Erwin Müller, erwin.mueller@nttdata.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
