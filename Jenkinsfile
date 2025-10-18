pipeline {
    agent any
    tools {
        maven 'M2_HOME'
    }
    stages {
        stage('Git Checkout') {
            steps {
                echo 'Cloning the repo from GitHub'
                git branch: 'master', url: 'https://github.com/Chandrika-git05/star-agile-health-care.git'
            }
        }

        stage('Build & Package') {
            steps {
                echo 'Compiling, testing, and packaging the application'
                sh 'mvn package'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Creating Docker image'
                sh 'sudo docker build -t chandrika5592/healthcaremedicure:1.0 .'
            }
        }

        stage('Login to DockerHub') {
            steps {
                echo 'Logging into DockerHub'
                withCredentials([usernamePassword(credentialsId: 'dockercreds', passwordVariable: 'dockerpwd', usernameVariable: 'dockerlogin')]) {
                    sh 'docker login -u ${dockerlogin} -p ${dockerpwd}'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to DockerHub'
                sh 'docker push chandrika5592/healthcaremedicure:1.0'
            }
        }

        stage('Terraform Apply') {
            steps {
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
                sh 'sudo chmod 600 /var/lib/jenkins/workspace/Healthcare-medicure/kubernetes/chandrikakey'
                sh 'sudo scp -o StrictHostKeyChecking=no -i /var/lib/jenkins/workspace/Healthcare-medicure/kubernetes/chandrikakey /var/lib/jenkins/workspace/Healthcare-medicure/kubernetes/deployment.yml ubuntu@172.31.20.141:/home/ubuntu/'
                sh 'sudo scp -o StrictHostKeyChecking=no -i /var/lib/jenkins/workspace/Healthcare-medicure/kubernetes/chandrikakey /var/lib/jenkins/workspace/Healthcare-medicure/kubernetes/service.yml ubuntu@172.31.20.141:/home/ubuntu/'

                script {
                    def remote = "/home/ubuntu"
                    def key = "/var/lib/jenkins/workspace/Healthcare-medicure/kubernetes/chandrikakey"
                    def host = "ubuntu@172.31.20.141"

                    sh """
                        ssh -o StrictHostKeyChecking=no -i ${key} ${host} <<'EOF'
                            # Delete old deployment and service to avoid immutable field issues
                            kubectl delete deployment medicure-deployment || true
                            kubectl delete svc medicure-service || true

                            # Apply new deployment and service
                            kubectl apply -f ${remote}/deployment.yml
                            kubectl apply -f ${remote}/service.yml

                            # Start Minikube tunnel in background with sudo
                            nohup sudo minikube tunnel --cleanup > /tmp/minikube-tunnel.log 2>&1 &

                            # Wait for EXTERNAL-IP to be assigned
                            EXTERNAL_IP=""
                            while [ -z \$EXTERNAL_IP ]; do
                                EXTERNAL_IP=\$(kubectl get svc medicure-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                                sleep 5
                            done

                            echo "🎯 Service is accessible at: http://\$EXTERNAL_IP:8085"
EOF
                    """
                }
            }
        }
    }
}
