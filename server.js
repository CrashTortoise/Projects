const http = require('node:http');
const { createTabApp } = require('./src/app');
const { loadConfig } = require('./src/config');

const config = loadConfig();
const app = createTabApp(config);
const server = http.createServer(app.handler);

server.listen(config.port, config.host, () => {
  console.log(`Project TAB is running at http://${config.host}:${config.port}`);
  if (config.demoPasswordInUse) {
    console.warn('WARNING: Using the development administrator password. Set TAB_ADMIN_PASSWORD before production use.');
    console.warn(`Development login: ${config.adminUsername} / ${config.adminPassword}`);
  }
});

function shutdown(signal) {
  console.log(`\n${signal} received. Shutting down Project TAB.`);
  server.close(() => {
    app.close();
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10000).unref();
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
