// MongoDB migration script for rollback support
// V2__Add_Rollback_Support.js

// Create a collection to track migrations
db.createCollection("schema_migrations", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["version", "type", "script", "installedBy", "installedOn", "executionTime", "success"],
      properties: {
        version: {
          bsonType: "string",
          description: "Migration version identifier"
        },
        description: {
          bsonType: "string",
          description: "Description of the migration"
        },
        type: {
          bsonType: "string",
          description: "Type of migration (up or down)"
        },
        script: {
          bsonType: "string",
          description: "Script content or path"
        },
        installedBy: {
          bsonType: "string",
          description: "User who installed the migration"
        },
        installedOn: {
          bsonType: "date",
          description: "Date when the migration was installed"
        },
        executionTime: {
          bsonType: "int",
          description: "Execution time in milliseconds"
        },
        success: {
          bsonType: "bool",
          description: "Whether the migration was successful"
        }
      }
    }
  }
});

db.schema_migrations.createIndex({ version: 1 }, { unique: true });
