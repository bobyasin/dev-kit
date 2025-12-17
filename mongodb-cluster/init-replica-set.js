// MongoDB Replica Set Initialization Script

// Wait for MongoDB to be ready
sleep(5000);

// Initialize replica set (this works without auth initially)
try {
  rs.initiate({
    _id: "rs0",
    members: [
      {
        _id: 0,
        host: "mongo-primary:27017",
        priority: 2,
      },
      {
        _id: 1,
        host: "mongo-secondary1:27017",
        priority: 1,
      },
      {
        _id: 2,
        host: "mongo-secondary2:27017",
        priority: 1,
      },
    ],
  });

  print("Replica set initiated successfully!");
} catch (e) {
  print("Replica set may already be initialized: " + e.message);
}

// Wait for replica set to initialize
sleep(15000);

// Create admin user (only works on primary)
try {
  db = db.getSiblingDB("admin");
  db.createUser({
    user: "admin",
    pwd: "adminpass",
    roles: [{ role: "root", db: "admin" }],
  });
  print("Admin user created successfully!");
} catch (e) {
  print("Admin user may already exist: " + e.message);
}

// Create application database and user
try {
  db = db.getSiblingDB("appdb");
  db.createUser({
    user: "appuser",
    pwd: "apppass",
    roles: [{ role: "readWrite", db: "appdb" }],
  });
  print("App user created successfully!");
} catch (e) {
  print("App user may already exist: " + e.message);
}

print("MongoDB Replica Set setup complete!");
print("Admin user: admin / adminpass");
print("App user: appuser / apppass");
