# Docker AUTOMATIC1111 CPU Version (linux-x86_64)

A Docker container to deploy AUTOMATIC1111 environment for running on CPU.

Docker requirements:
---

Add buildkit to: /etc/docker/daemon.json
---
```
{
  "features": {
    "buildkit" : true
  }
}
```

Build Docker image:
---

```
$ docker build -f Dockerfile -t -t local/automatic1111cpu:latest .
```

Deploy container:
---

**Workaround for initial deployment:** Due to an error on the first deployment **it's mandatory to compose up twice**. Runs fine after that.

```
$ docker compose -f docker-compose.yaml up -d
```

Re-run container:
---

```
$ docker start automatic1111cpu
```

Add Models:
---

Add your model files to directory **models**, loras to **loras**, textual inversions to **embeddings** and lycoris to **lycoris**. Any output is written to **outputs**. The directory **repositories** is a cache to accelerate Docker container deployment.

Connect to web gui:
---

URL: http://127.0.0.1:7860