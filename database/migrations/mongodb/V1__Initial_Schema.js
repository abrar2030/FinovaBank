// MongoDB migration script for user profiles
// V1__Initial_Schema.js

db.createCollection("user_profiles", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "email", "firstName", "lastName", "createdAt", "updatedAt"],
      properties: {
        userId: {
          bsonType: "string",
          description: "Unique identifier for the user"
        },
        email: {
          bsonType: "string",
          description: "User's email address"
        },
        firstName: {
          bsonType: "string",
          description: "User's first name"
        },
        lastName: {
          bsonType: "string",
          description: "User's last name"
        },
        phoneNumber: {
          bsonType: "string",
          description: "User's phone number"
        },
        address: {
          bsonType: "object",
          properties: {
            street: { bsonType: "string" },
            city: { bsonType: "string" },
            state: { bsonType: "string" },
            zipCode: { bsonType: "string" },
            country: { bsonType: "string" }
          }
        },
        preferences: {
          bsonType: "object",
          properties: {
            language: { bsonType: "string" },
            theme: { bsonType: "string" },
            notifications: { bsonType: "bool" }
          }
        },
        createdAt: {
          bsonType: "date",
          description: "Date when the user profile was created"
        },
        updatedAt: {
          bsonType: "date",
          description: "Date when the user profile was last updated"
        }
      }
    }
  }
});

db.user_profiles.createIndex({ userId: 1 }, { unique: true });
db.user_profiles.createIndex({ email: 1 }, { unique: true });
