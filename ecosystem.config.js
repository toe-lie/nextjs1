// ecosystem.config.js
module.exports = {
  apps: [
    {
      name: "nextjs1-staging",
      script: "server.js", // Direct server.js execution
      cwd: "/var/www/nextjs1/staging",
      instances: 1,
      exec_mode: "fork",
      env: {
        NODE_ENV: "staging",
        PORT: 3001,
      },
      log_file: "/var/log/nextjs1/staging-combined.log",
      out_file: "/var/log/nextjs1/staging-out.log",
      error_file: "/var/log/nextjs1/staging-error.log",
      time: true,
    },
    {
      name: "nextjs1-production",
      script: "server.js", // Direct server.js execution
      cwd: "/var/www/nextjs1/production",
      instances: "max",
      exec_mode: "cluster",
      env: {
        NODE_ENV: "production",
        PORT: 3000,
      },
      log_file: "/var/log/nextjs1/production-combined.log",
      out_file: "/var/log/nextjs1/production-out.log",
      error_file: "/var/log/nextjs1/production-error.log",
      time: true,
    },
  ],
};
