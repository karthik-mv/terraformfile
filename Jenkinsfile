pipeline {
    agent none
    tools {
        maven "mymaven"  // Specify the Maven tool configuration
    }
    environment {
        DEV_SERVER_IP = 'ec2-user@172.31.16.83'
        //DEPLOY_SERVER_IP = 'ec2-user@172.31.26.244'
        IMAGE_NAME = "karthikmv93/docker"
    }
    parameters {
        string(name: 'Env', defaultValue: 'Test', description: 'Env to deploy')
        booleanParam(name: 'executeTests', defaultValue: true, description: 'Decide to run test cases')
        choice(name: 'APPVERSION', choices: ['1.1', '2.1', '3.1'])
    }
    stages {
        stage('Compile') {
            agent any
            steps {
                echo "Compile the code"
                sh "mvn compile"
            }
        }

        stage('Unit test') {
            when {
                expression {
                    return params.executeTests == true
                }
            }
            agent any
            steps {
                echo "Test the code in ${params.Env}"
                sh "mvn test"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package & Push the Image to Registry') {
            agent any
            steps {
                script {
                    sshagent(['slave2']) {
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                            echo "Package the code ${params.APPVERSION}"
                            // Install Docker on the deploy server
                            sh "ssh -v -o StrictHostKeyChecking=no ${DEV_SERVER_IP} sudo yum install docker -y"
                            sh "ssh -v -o StrictHostKeyChecking=no ${DEV_SERVER_IP} 'bash ~/server-script.sh' ${IMAGE_NAME} ${BUILD_NUMBER}"
                            // Login to Docker Hub and push the image
                            sh "ssh ${DEV_SERVER_IP} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                            sh "ssh ${DEV_SERVER_IP} sudo docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
                        }
                    }
                }
            }
        }

        stage('Provisioning the Infra'){
            agent any
            steps{
                script{
                    dir('terraform'){
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        EC2_PUBLIC_IP = sh{
                            script: "terraform output ec2-ip",
                            returnStdout: true
                        }.trim{}
                     

                    }
                }
            }
        }

        stage('Deploy') {
            agent any  // Ensure the 'Deploy' stage runs on any available agent
            input {
                message "Select the version to deploy"
                ok "OK"
                parameters {
                    choice(name: 'APP', choices: ['1.1', '2.1', '3.1'])
                }
            }
            steps {
                script {
                    sshagent(['slave2']) {
                        echo "waiting for ec2 instance to initialize"
                        sleep(time:90,unit:"SECONDS")
                        echo ${EC2_PUBLIC_IP}
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                            echo "Deploying the code version ${params.APP}"
                            // Install Docker on the deploy server
                            sh "scp -v -o StrictHostKeyChecking=no server-script.sh ${EC2_PUBLIC_IP}:/home/ec2-user"
                            sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo yum install docker -y"
                            sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo systemctl start docker"
                            // Login to Docker Hub and run the container
                            sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                            sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo docker run -itd -p 8080:8080 ${IMAGE_NAME}:${BUILD_NUMBER}"
                        }
                    }
                }
            }
        }
    }
}
