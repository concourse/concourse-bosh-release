# Shipping 4.2.x Patches

## Testing the Windows worker

```bash
# cook up some windows-worker-only bosh deployment

# hit garden, expect a 404
bosh ssh windows-worker -c 'curl http://127.0.0.1:7777'

# hit baggageclaim, expect a 404
bosh ssh windows-worker -c 'curl http://127.0.0.1:7788'
```

## changing the version of golang

https://github.com/bosh-packages/golang-release has some pretty tidy steps.
