# rmc-exporter-vapor

Tool for making playlists with tracks from Radio Monte Carlo SPb

Fulfills two playlists

for all, new first [Radio Monte Carlo SPB](https://open.spotify.com/playlist/32jmNqf6iLAf3oqhmNNspd?si=1cd50e46c8074c96)  
for last 10, new last [Radio Monte Carlo SPB Live](https://open.spotify.com/playlist/6ohV6Zqtj1yFrgvygwfFf3?si=6702055800f74eb7)

## Refresh token persistence

The app stores the Spotify refresh token on disk so the container can restart without re-auth.

By default the token is read from and written to `/data/refresh_token`. You can override the
path with `REFRESH_TOKEN_PATH` and mount a volume to persist the file.
