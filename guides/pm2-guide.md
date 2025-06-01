ssh root@<DROPLET_IP>

cd /var/www
npx create-next-app nextjs

cd nextjs

npm install

npm run build

npm start

## PM2

sudo npm install -g pm2

cd /var/www/nextjs

pm2 start npm --name "nextjs" -- start

pm2 startup

pm2 save
