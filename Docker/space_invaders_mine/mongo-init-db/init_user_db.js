// init-mongo.js
db.getSiblingDB('admin').createUser({
    user: "admin",
    pwd: "adminPassword",  // Replace with a secure password
    roles: [{ role: "userAdminAnyDatabase", db: "admin" }]
});

db.getSiblingDB('space-inv').createUser({
    user: "space-inv",
    pwd: "space-inv",  // Replace with a secure password
    roles: [{ role: "readWrite", db: "space-inv" }]
});

db.getSiblingDB('space-inv').createCollection("init");
db.getSiblingDB('space-inv').init.insert({name: "init"});
