# PM2 monitoring

By-default the daemon user for pm2 will be `enrise`. In case you want it to run on a different username you can configure this in your pillar

```yaml
node:
  pm2:
    daemon-user: otherusername
```
