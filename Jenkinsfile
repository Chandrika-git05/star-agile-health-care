pipeline {
  agent any

  tools {
    maven 'M2_HOME'
  }

  stages {

    stage('Git Checkout') {
      steps {
        echo '📥 Cloning repository from GitHub...'
        git branch: 'master', url: 'https://github.com/Chandrika-git05/star-agile-health-care.git'
      }
    }

    stage('Create Package') {
      steps {
        echo '📦 Building and packaging the application...'
        sh 'mvn package'
      }
    }

    stage('Create Docker Image') {
      steps {
        echo '🐳 Building Docker image...'
        sh 'sudo docker build -t chandrika5592/healthcaremedicure:1.0 .'
      }
    }

    stage('Login to Dockerhub') {
      steps {
        echo '🔐 Logging into Docker Hub...'
        withCredentials([usernamePassword(credentialsId: 'dockercreds', passwordVariable: 'dockerpwd', usernameVariable: 'dockerlogin')]) {
          sh 'docker login -u ${dockerlogin} -p ${dockerpwd}'
        }
      }
    }

    stage('Docker Push-Image') {
      steps {
        echo '⬆️ Pushing Docker image to Docker Hub...'
        sh 'docker push chandrika5592/healthcaremedicure:1.0'
      }
    }

    stage('Terraform Apply') {
      steps {
        echo '⚙️ Running Terraform to provision infrastructure...'
        withCredentials([usernamePassword(credentialsId: 'awslogin', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
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

    stage('Deploy to Kubernetes') {
      steps {
        echo '🚀 Deploying application to Kubernetes EC2...'

        // Set correct permissions for SSH key
        sh 'sudo chmod 600 ${WORKSPACE}/kubernetes/chandrikakey'

        // Copy deployment and service files to Kubernetes node
        sh 'sudo scp -o StrictHostKeyChecking=no -i ${WORKSPACE}/kubernetes/chandrikakey ${WORKSPACE}/kubernetes/deployment.yml ubuntu@172.31.20.141:/home/ubuntu/'
        sh 'sudo scp -o StrictHostKeyChecking=no -i ${WORKSPACE}/kubernetes/chandrikakey ${WORKSPACE}/kubernetes/service.yml ubuntu@172.31.20.141:/home/ubuntu/'

        // Apply the manifests remotely
        script {
          sh '''
          ssh -o StrictHostKeyChecking=no -i ${WORKSPACE}/kubernetes/chandrikakey ubuntu@172.31.20.141 "
            kubectl apply -f /home/ubuntu/deployment.yml
            kubectl apply -f /home/ubuntu/service.yml
          "
          '''
        }
      }
    }
  }
}
