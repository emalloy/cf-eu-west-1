# cf-eu-west-1
translate terraform declaration to cloudformation


### create
  * random 
    * s3 bucket,
    * iam user
      * inline iam policy granting perms to bucket
   * iam access keypair
### return
   * iam access key
   * iam secret key


### invocation

`_RANDOM=$(apg -n1 -m8 -ML) ./cf_launcher.sh eu-west-1 ${RANDOM} ${RANDOM} ${RANDOM} ${RANDOM} `
