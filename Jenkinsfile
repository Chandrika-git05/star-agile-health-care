pipeline {
  agent any
     tools {
       maven 'M2_HOME'
           }
     
  stages {
    stage('Git Checkout') {
      steps {
        echo 'This stage is to clone the repo from github'
        git branch: 'master', url: 'https://github.com/Chandrika-git05/star-agile-health-care.git'
                        }
            }
    stage('Create Package') {
      steps {
        echo 'This stage will compile, test, package my application'
        sh 'mvn package'
                          }
            }
    
     stage('Create Docker Image') {
      steps {
        echo 'This stage will Create a Docker image'
        sh 'sudo docker build -t chandrika5592/healthcaremedicure:1.0 .'
                          }
            }
     stage('Login to Dockerhub') {
      steps {
        echo 'This stage will loginto Dockerhub' 
       withCredentials([usernamePassword(credentialsId: 'dockercreds', passwordVariable: 'dockerpwd', usernameVariable: 'dockerlogin')]) {
       sh 'docker login -u ${dockerlogin} -p ${dockerpwd}'
            }
         }
     }
    stage('Docker Push-Image') {
      steps {
        echo 'This stage will push my new image to the dockerhub'
        sh 'docker push chandrika5592/healthcaremedicure:1.0'
            }
      }
    stage('AWS-Login') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'awslogin', passwordVariable: 'awsaccesskey', usernameVariable: 'awsaccess')]) {
         }
      }
    }
   stage('setting the Kubernetes Cluster') {
    steps {
        dir('terraform_files') {
            sh 'terraform init'
            sh 'terraform validate'
            sh 'terraform apply --auto-approve'
            sh 'sleep 20'
        }
    }
}
/* stage('Deploy to minikube') {
  steps {
    sh 'sudo chmod 600 ./terraform_files/sir.pem'
    sh 'sudo scp -o StrictHostKeyChecking=no -i ./terraform_files/sir.pem ./terraform_files'
  }
} */
  }
}
 
