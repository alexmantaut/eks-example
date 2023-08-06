# EKS Cluster - Node boilerplate

Boilerplate to run nodejs containers behind a LB in AWS, on top of an EKS

## Deployment
```
cd 01-cluster
terraform init
terraform apply
cd ../02-image
AWS_ACCOUNT=<ACCT_NUM> AWS_REGION=<REGION> ./upload-image.sh
cd ../03-deployment
terraform init
terraform apply
```

## Cleanup
```
cd 01-cluster
terraform destroy
cd ../03-deployment
terraform destroy
```
