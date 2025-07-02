docker compose -f docker-compose.yml \
    -f traefik/docker-compose.traefik.yml \
    -f kitchen_owl/docker-compose.kitchenowl.yml \
    -f actual/docker-compose.actual.yml \
    -f immich/docker-compose.immich.yml \
    --env-files immich/immich.env \
    up -d