# MediCare Hospital Management System

The complete project source is in the workspace root:

- `pom.xml`
- `database/schema.sql`
- `database/seed.sql`
- `src/main/java/`
- `src/main/webapp/`
- `README.md`

## Build and run

```bash
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql
cp src/main/resources/db.properties.example src/main/resources/db.properties
# Set MySQL values in db.properties, then:
mvn clean test package
```

Deploy `target/medicare.war` to Apache Tomcat 11 and open:

`http://localhost:8080/medicare/login`

Read `README.md` for configuration, the security design, testing checklist, RTU syllabus mapping, troubleshooting, and viva questions.

## Local verification limitation

The current environment has Java but does not have Maven, MySQL, or Tomcat installed, so the WAR could not be generated here. Install those tools, then run the commands above.
