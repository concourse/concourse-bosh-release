# Shipping 4.2.x Patches

There are certain steps to be taken before shipping, this doc is intended to
help you out with following the right steps.


## Before

Make sure that `version` is currently set to a release-candidate of the version
that you're aiming to ship.

For instance, if the last release was `4.2.5`, you should make sure that the
pipeline is currently running on `4.2.6-rc.N`.

If you notice that the pipeline is not running on RCs of the target version, run
`bump-patch`.


## During

The jobs will be kicked off whenever a new version of `rc` gets bumped.

To do so, run `bump-rc`.


## Ready to ship

Once you're sure that you got a working version that you want to ship (e.g.,
`4.2.6-rc.42`), the next step is promoting that RC to a final release version
(i.e., 4.2.6).

To do so, run `promote-rc`.

Once the pipeline finishes running, run the `shipit` job to get the contents of
that version published.


## After

Once the pipeline finished, make sure you leave the pipeline in a good state for
next iterations (i.e., continuously running release-candidates on what the next
patch will be).

To do so, run `bump-patch`.



# Testing the Windows worker

```bash
# cook up some windows-worker-only bosh deployment


# hit garden, expect a 404
bosh ssh windows-worker -c 'curl http://127.0.0.1:7777'

# hit baggageclaim, expect a 404
bosh ssh windows-worker -c 'curl http://127.0.0.1:7788'
```

Sample Manifest with Windows Worker
```
---
name: concourse-424-windows

releases:
- name: concourse
  version: 4.2.4+dev.1
- name: garden-runc
  version: latest
- name: postgres
  version: latest

instance_groups:
- name: concourse
  instances: 1
  networks: [{name: test}]
  azs: [z1]
  persistent_disk: 10240
  vm_type: web
  stemcell: xenial
  jobs:
  - release: concourse
    name: atc
    properties:
      add_local_users:
      - some-user:$2a$10$ElspuoVbekkuIlqvk25HN.9DRwGpkS0mUluTjrhsOMKhcGKNUHHvC
      main_team:
        auth:
          allow_all_users: true
      token_signing_key: ((token_signing_key))
      log_level: debug
      postgresql:
        database: &db-name atc
        role: &db-role
          name: atc
          password: dummy-password

  - release: concourse
    name: tsa
    properties:
      log_level: debug
      host_key: ((tsa_host_key))
      token_signing_key: ((token_signing_key))
      authorized_keys: [((worker_key.public_key))]

  - release: postgres
    name: postgres
    properties:
      databases:
        port: 5432
        databases:
        - name: *db-name
        roles:
        - *db-role

- name: concourse-windows-worker
  instances: 1
  networks: [{name: test}]
  azs: [z1]
  persistent_disk: 50240
  vm_type: worker
  stemcell: windows
  jobs:
  - name: houdini-windows
    release: concourse
    provides: {garden: {as: windows-garden}}
  - name: baggageclaim-windows
    release: concourse
    provides: {baggageclaim: {as: windows-baggageclaim}}
  - name: worker-windows
    release: concourse
    consumes:
      baggageclaim: {from: windows-baggageclaim}
      garden: {from: windows-garden}
    properties:
      tsa:
        worker_key: ((worker_key))

variables:
- name: token_signing_key
  type: rsa
- name: tsa_host_key
  type: ssh
- name: worker_key
  type: ssh

stemcells:
- alias: xenial
  os: ubuntu-xenial
  version: latest
- alias: windows
  os: windows2016
  version: latest

update:
  canaries: 1
  max_in_flight: 3
  serial: false
  canary_watch_time: 1000-300000
  update_watch_time: 1000-300000
```

# changing the version of golang

https://github.com/bosh-packages/golang-release has some pretty tidy steps.

Note: To bump the version of a package, BOSH will need to upload the blobs to the [blobstore](https://bosh.io/docs/release-blobstore/) configured under `config/final.yml`. To get the credentials for it, BOSH will look for a `private.yml`. To fill it with the credentials to the blobstore, you can retrieve that from Vault (see https://github.com/pivotal/concourse-ops/wiki/Operating-Vault#reading-secrets), currently at the key  `/concourse/main/concourse/concourse_artifacts_json_key`.
