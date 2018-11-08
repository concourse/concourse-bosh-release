$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

. C:\var\vcap\jobs\worker-windows\config\env.ps1

C:\var\vcap\packages\concourse-windows\concourse\bin\concourse.exe worker
