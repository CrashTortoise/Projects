FROM node:24-alpine

LABEL org.opencontainers.image.title="Project TAB"
LABEL org.opencontainers.image.description="Test a Breach — cyber tabletop exercise management platform"

WORKDIR /app
COPY --chown=node:node . .
RUN mkdir -p /app/data && chown -R node:node /app/data

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=8080
ENV TAB_DB_PATH=/app/data/project-tab.db

USER node
EXPOSE 8080
VOLUME ["/app/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q -O - http://127.0.0.1:8080/api/health || exit 1

CMD ["node", "server.js"]
