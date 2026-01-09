| Maven Phase | What It Creates                                    |
| ----------- | -------------------------------------------------- |
| compile     | `target/classes/`                                  |
| test        | `target/test-classes/`, `target/surefire-reports/` |
| package     | `target/app-name.jar` or `.war`                    |
| install     | Artifact in `~/.m2/repository`                     |
| deploy      | Artifact in remote repo                            |
---------------------------------------------------------------------
/app
├── pom.xml
├── src
│   ├── main
│   │   ├── java
│   │   └── resources
│   └── test
│       └── java
└── target
    ├── classes/              # created in compile phase
    ├── test-classes/         # created in test phase
    ├── surefire-reports/     # created in test phase
    ├── myapp.jar             # created in package phase
    └── maven-archiver/
---------------------------------------------------------------------
| Tech         | Build Output Folder |
| ------------ | ------------------- |
| Java (Maven) | `target/`           |
| Python       | `site-packages/`    |
| Node.js      | `node_modules/`     |
---------------------------------------------------------------------
/app
├── node_modules/        # created by npm install
├── package.json
├── package-lock.json
├── server.js
├── src/
└── dist/                # created by npm run build (optional)
-----------------------------------------------------------------------
| Code | Meaning               | Example         |
| ---- | --------------------- | --------------- |
| 500  | Internal Server Error | App crash       |
| 502  | Bad Gateway           | Upstream failed |
| 503  | Service Unavailable   | App down        |
| 504  | Gateway Timeout       | Dependency slow |
----------------------------------------------------------------------
| Code | Meaning           | Example          |
| ---- | ----------------- | ---------------- |
| 400  | Bad Request       | Invalid payload  |
| 401  | Unauthorized      | No auth token    |
| 403  | Forbidden         | No permission    |
| 404  | Not Found         | Resource missing |
| 409  | Conflict          | Duplicate record |
| 429  | Too Many Requests | Rate limiting    |
--------------------------------------------------------------------------------
