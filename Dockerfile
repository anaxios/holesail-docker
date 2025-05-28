FROM node:lts-slim AS base

RUN npm install -g holesail@2.1.0

FROM base AS dev

WORKDIR /
COPY run.sh .
COPY fetch-my-mc-connector.js .
RUN chmod +x run.sh

ENV MODE=server
ENV HOST=0.0.0.0
ENV PORT=8989
ENV PUBLIC=true
ENV USERNAME=admin
ENV PASSWORD=admin
ENV ROLE=user 
ENV KEY=""
ENV MY_MC_API_KEY=""
#ENV FORCE ""

CMD [ "/usr/bin/bash", "/run.sh" ]
