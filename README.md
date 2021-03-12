# Example.Umbrella

## How do I run this?

```bash
# Runs the app plus postgresql in docker
docker-compose -f docker-compose.dev.yml
# Creates tha database
docker-compose -f docker-compose.dev.yml run app ./bin/example_umbrella eval "Example.ReleaseTasks.eval_createdb"
```

