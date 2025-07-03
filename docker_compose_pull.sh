docker compose -f docker-compose.yml \
    -f traefik/docker-compose.traefik.yml \
    -f kitchen_owl/docker-compose.kitchenowl.yml \
    -f actual/docker-compose.actual.yml \
    -f immich/docker-compose.immich.yml \
    -f paperless/docker-compose.paperless.yml \
    --env-file paperless/paperless.env \
    --env-file immich/immich.env \
    pull -d