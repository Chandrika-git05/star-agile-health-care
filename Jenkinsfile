pipeline {
  agent any
  tools { maven 'M2_HOME' }

  stages {

    stage('Git Checkout') {
      steps {
        git branch: 'master', url: 'https://github.com/Chandrika-git05/star-agile-health-care.git'
      }
    }

    stage('Build Package') {
      steps { sh 'mvn package' }
    }

    stage('Docker Build & Push') {
      steps {
        sh 'sudo docker build -t chandrika5592/healthcaremedicure:1.0 .'
        withCredentials([usernamePassword(credentialsId: 'dockercreds', usernameVariable: 'dockerlogin', passwordVariable: 'dockerpwd')]) {
          sh 'docker login -u ${dockerlogin} -p ${dockerpwd}'
        }
        sh 'docker push chandrika5592/healthcaremedicure:1.0'
      }
    }

    stage('Terraform Apply') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'awslogin', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          dir('kubernetes') {
            withEnv([
              "AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID}",
              "AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY}"
            ]) {
              sh '''
                terraform init
                terraform validate
                terraform apply --auto-approve
                sleep 20
              '''
            }
          }
        }
      }
    }

    stage('Deploy to Minikube EC2 & Get URL') {
      steps {
        echo 'Deploying to Minikube and fetching service URL...'

        sh "chmod 600 ${WORKSPACE}/kubernetes/chandrikakey"

        // Copy YAMLs
        sh """
        scp -o StrictHostKeyChecking=no -i ${WORKSPACE}/kubernetes/chandrikakey \
          ${WORKSPACE}/kubernetes/deployment.yml ubuntu@172.31.20.141:/home/ubuntu/
        scp -o StrictHostKeyChecking=no -i ${WORKSPACE}/kubernetes/chandrikakey \
          ${WORKSPACE}/kubernetes/service.yml ubuntu@172.31.20.141:/home/ubuntu/
        """

        // Apply manifests and wait for pods
        sh """
        ssh -o StrictHostKeyChecking=no -i ${WORKSPACE}/kubernetes/chandrikakey ubuntu@172.31.20.141 '
          # Start Minikube if not running
          minikube status || minikube start --driver=none

          # Apply Deployment & Service
          kubectl apply -f /home/ubuntu/deployment.yml
          kubectl apply -f /home/ubuntu/service.yml

          # Wait for pods to be ready
          kubectl rollout status deployment/medicure-deployment
        '
        """

        // Get NodePort and print full access URL
        sh """
        NODEPORT=\$(ssh -o StrictHostKeyChecking=no -i ${WORKSPACE}/kubernetes/chandrikakey ubuntu@172.31.20.141 '
          kubectl get svc medicure-service -o jsonpath="{.spec.ports[0].nodePort}"
        ')
        echo "🎯 Service is accessible at: http://172.31.20.141:\$NODEPORT"
        """
      }
    }
  }
}
