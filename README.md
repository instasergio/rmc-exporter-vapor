# rmc-exporter-vapor

Tool for making playlists with tracks from Radio Monte Carlo SPb

Fulfills two playlists

for all, new first [Radio Monte Carlo SPB](https://open.spotify.com/playlist/32jmNqf6iLAf3oqhmNNspd?si=1cd50e46c8074c96)  
for last 10, new last [Radio Monte Carlo SPB Live](https://open.spotify.com/playlist/6ohV6Zqtj1yFrgvygwfFf3?si=6702055800f74eb7)

## Refresh token persistence

The app stores the Spotify refresh token on disk so the container can restart without re-auth.

By default the token is read from and written to `/data/refresh_token`. You can override the
path with `REFRESH_TOKEN_PATH` and mount a volume to persist the file.

## Docker (local)

Build and run:

```bash
docker build -t rmc-exporter-vapor:local .
docker run --rm -p 4357:8080 \
  -e CLIENT_ID=... \
  -e CLIENT_SECRET=... \
  -e REDIRECT_URL=... \
  -v rmc_data:/data \
  rmc-exporter-vapor:local
```

Or via compose (builds locally):

```bash
docker compose up -d --build
```

## Docker Hub (multi-arch push)

This image can be pushed as a multi-arch manifest for both `linux/amd64` and `linux/arm64` (RPi).

```bash
docker login
docker buildx create --use --name rmc-builder || docker buildx use rmc-builder
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t <dockerhub-username>/rmc-exporter-vapor:latest \
  --push .
```

## Portainer / Raspberry Pi deploy

Use `docker-compose.image.yml` as a Portainer Stack (it pulls from Docker Hub):

```bash
IMAGE=<dockerhub-username>/rmc-exporter-vapor:latest
HOST_PORT=4357
CLIENT_ID=...
CLIENT_SECRET=...
REDIRECT_URL=...
```
