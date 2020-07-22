# openjdk-sbt

### Docker image based on amazon linux (latest) containing OpenJDK 8, MAVEN, SBT and GRADLE
  
## How to run docker container to compile sbt app

```bash
docker run -it --rm \
  -v <PATH_TO_YOUR_SCALA_APP_DIR>:/app \
  -v ~/.ivy2:/root/.ivy2 \
  -w /app \
  -p 9000:9000
  rafalsladek/openjdk-sbt \
  sbt run
```
