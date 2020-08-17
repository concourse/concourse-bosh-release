The Concourse pipelines validate the flags exposed in the binary match the flags exposed in the BOSH release.

The `ignored-in-concourse` file is used to specify flags that are exposed in the binary, but not expected to be in the BOSH release.

The `ignored-in-distribution` file is used to specify flags that re exposed in the BOSH release, but not expected to be in the binary.

These files are referenced by the [check-distribution-env](https://github.com/concourse/ci/blob/master/tasks/check-distribution-env.yml) task.
