#!/bin/sh
set -ex

OIDC_AGENT_ALIAS=${OIDC_AGENT_ALIAS:-dev-wlcg}

eval $(oidc-agent-service use)
oidc-add --pw-env=OIDC_AGENT_SECRET ${OIDC_AGENT_ALIAS}
