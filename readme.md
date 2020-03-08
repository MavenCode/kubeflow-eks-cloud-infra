
#Setup Requirements
0. Setup Stuff needed to run the app
   - pip3 install awscli --upgrade --user
   - brew install terraform
   - brew install aws-iam-authenticator
   
1. sh tf-{plan,apply}.sh

2. Connecting to the EKS Cluster:
   - Get the Cluster Identity Info -> `aws sts get-caller-identity --profile prod-eks`  
   - Get Kubeconfig Update -> 
      ```
        aws --profile prod-maven \
            --region us-east-2 \
            eks update-kubeconfig \
            --name eks-kfsgm-cluster \
            --role-arn arn:aws:iam::000654207548:user/prod-maven
      ```
        
3. Create new IAM role that can be assumed by the cluster service
        `aws iam create-role \
            --role-name sagemaker-operator-role \
            --assume-role-policy-document file://trust.json \
            --output=text`
   you should see something like this
   
   ```  ROLE    arn:aws:iam::000654207548:role/sagemaker-operator-role  2020-03-08T08:19:27Z    /       AROAQAJX6NI6PQ6JB4HBR   sagemaker-operator-role
        ASSUMEROLEPOLICYDOCUMENT        2012-10-17
        STATEMENT       sts:AssumeRoleWithWebIdentity   Allow
        STRINGEQUALS    sts.amazonaws.com       system:serviceaccount:sagemaker-k8s-operator-system:sagemaker-k8s-operator-default
        PRINCIPAL       arn:aws:iam::000654207548:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/BC11B3572791200BDFC258164CC8C804
    ```
4. Grant the role full access to SageMaker
        `aws iam attach-role-policy \
         --role-name sagemaker-operator-role \
         --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess`
         
5. install the sagemaker operator CRDs -> `kubectl apply -f sagemaker-operator-crd.yaml` and verify the installations `kubectl get crd | grep sagemaker`

6. run the shell script `sagemaker-logs.sh` to get the logs from sagemaker piped to your cli
