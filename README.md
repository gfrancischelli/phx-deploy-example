# Example.Umbrella

## How do I run this?

```bash
chmod +x ./start-docker-dev.sh

# Runs the app plus postgresql in docker
./start-docker-dev.sh up
# Creates tha database 
./start-docker-dev.sh run app ./bin/example_umbrella eval "Example.ReleaseTasks.eval_createdb"
```
