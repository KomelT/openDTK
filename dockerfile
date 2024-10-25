FROM qgis/qgis:latest

WORKDIR /app

COPY . /app

RUN apt-get update && apt-get install -y curl jq unzip python3 osmctools osm2pgsql postgis postgresql-client

ENV QT_QPA_PLATFORM="offscreen"

CMD ["/app/scripts/entrypoint.sh"]