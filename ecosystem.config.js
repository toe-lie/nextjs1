module.exports = {
  apps: [
    // === Staging apps ===
    {
      name: "nextjs1-staging",
      cwd: "/var/www/nextjs1-staging/.next/standalone",
      script: "server.js",
      env: {
        NODE_ENV: "staging",
        PORT: 3101,
        NEXT_PUBLIC_BASE_URL: "https://nextjs1-staging.oneplatforms.app",
      },
    },
    {
      name: "nextjs2-staging",
      cwd: "/var/www/nextjs2-staging/.next/standalone",
      script: "server.js",
      env: {
        NODE_ENV: "staging",
        PORT: 3102,
        NEXT_PUBLIC_BASE_URL: "https://nextjs2-staging.oneplatforms.app",
      },
    },
    // === Production apps ===
    {
      name: "nextjs1-prod",
      cwd: "/var/www/nextjs1/.next/standalone",
      script: "server.js",
      env: {
        NODE_ENV: "production",
        PORT: 3001,
        NEXT_PUBLIC_BASE_URL: "https://nextjs1.oneplatforms.app",
      },
    },
    {
      name: "nextjs2-prod",
      cwd: "/var/www/nextjs2/.next/standalone",
      script: "server.js",
      env: {
        NODE_ENV: "production",
        PORT: 3002,
        NEXT_PUBLIC_BASE_URL: "https://nextjs2.oneplatforms.app",
      },
    },
  ],
};
