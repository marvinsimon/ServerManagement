docker compose -f docker-compose.yml \
    -f traefik/docker-compose.traefik.yml \
    -f kitchen_owl/docker-compose.kitchenowl.yml \
    -f actual/docker-compose.actual.yml \
    -f immich/docker-compose.immich.yml \
    -f paperless/docker-compose.paperless.yml \
    -f openweb_ui/docker-compose.openweb_ui.yml \
    -f planka/docker-compose.planka.yml \
    -f uptime_kuma/docker-compose.uptime_kuma.yml \
    -f anubis/docker-compose.anubis.yml \
    -f memos/docker-compose.memos.yml \
    -f radicale/docker-compose.radicale.yml \
    --env-file paperless/paperless.env \
    --env-file immich/immich.env \
    --env-file planka/planka.env \
    pull