/etc/mongo.config
storage:
  dbPath: /var/mongodb/db1
  
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod1.log
net:
  bindIp: 127.0.0.1
  port: 27017
replication:
  replSetName: rs0
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
  fork: true

Create directory: (Mac)
    sudo mkdir -p /usr/local/var/mongodb/db1 /usr/local/var/mongodb/db2 /usr/local/var/mongodb/db3
    sudo mkdir -p /usr/local/var/mongodb/db{1,2,3}

    sudo mkdir -p /usr/local/var/log/mongodb
    sudo chown -R $(whoami) /usr/local/var/mongodb /usr/local/var/log/mongodb

Start mongo
    mongod --config <path-to-config>