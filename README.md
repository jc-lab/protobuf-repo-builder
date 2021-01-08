# protobuf-repo-builder

Build the protobuf repository(npm/java/...) automatically.

# Required protobuf project structure

* your files
* .pbrepo (directory)
  - config.yaml
  - version
  - java-project (optional, defined by config.yaml)
  - node-project (optional, defined by config.yaml)



Base repository projects:

* [java-project example](https://github.com/jc-lab/protobuf-example-repo-java)
* [node-project example](https://github.com/jc-lab/protobuf-example-repo-nodejs)



**config.yaml** example:

```yaml
namespace: myproto1
package-name: com.example.myproto1
filters:
  - '.*\.proto'
pipeline:
  - type: java
    path: .pbrepo/java-project
    srcPath: src/main/java
    commands:
      - 'mkdir -p ./src/main/protobuf/'
      - 'cp $PROTO_FILES_ABS ./src/main/protobuf/'
      - 'chmod +x gradlew'
      - './gradlew build'
      - './gradlew artifactoryPublish'
  - type: javascript
    path: .pbrepo/node-project
    commands:
      - 'npm install'
      - 'npm run build'
      - 'npm publish'

```

**version** example:
```
1
```


