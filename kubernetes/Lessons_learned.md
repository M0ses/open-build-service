* open "journald -f" on each node incl. master
* su needs an privileged container

* PODS:
  * obs-worker 
    * bs_worker

  * obs-repserver
    * bs_repserver
    * bs_sched *
    * bs_dispatch
    * bs_signer
    * bs_warden
    * bs_publish

  * obs-srcserver
    * bs_srcserver
    * bs_deltastore
    * bs_dodup
    * bs_servicedispatch

  * obs-service
    * bs_service
  *obs-cloudupload
    * bs_clouduploadserver
    * bs_clouduploadworker
  * obs-signd
    * signd
