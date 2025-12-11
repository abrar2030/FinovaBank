// MongoDB rollback script
// R2__Rollback_V2.js

// Drop the migrations tracking collection
db.schema_migrations.drop();
