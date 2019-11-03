
pipeline {
    agent any
    environment {
        JOB_NAME = "Build Jenkins Pipeline for Sensor API Gateway"
    }

    stages {

        stage ('Preconditions') {
            steps {
                cleanWs()
                checkout scm
            }
        }

        stage ('Build Master Branch') {
            when { 
                branch 'master'
            }
            steps {
                echo "Building from master Branch"
            }
        }
        stage ('Build Feature Branch') {
            when { 
                not { 
                  branch 'master'
                }
            }
            steps {
                echo 'Building non-master branch'
                sh 'pwd'
                sh 'npm install'
            }
        }
        stage ('Run Tests') {
            when { 
                not { 
                  branch 'master'
                }
            }
            steps {
                echo "Run Unit Tests BEGIN"
                sh 'npm run test-in-pipeline'
                echo "Run Unit Tests END"
            }
        }
        stage ('SonarQube Scan') {
            when { 
                not { 
                  branch 'master'
                }
            }
            steps {
                // This is logical name of sonar server defined in Jenkins console
                withSonarQubeEnv('kube-sonar-server') {
                    sh 'npm run sonar-scanner'
                }
            }
        }
        stage ('SonarQube Quality Gate') {
            when { 
                not { 
                  branch 'master'
                }
            }
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    // Note: Webhook to Jenkins must be setup in Sonar!
                    waitForQualityGate abortPipeline: true
                }
            }
        }
 
        stage ('Deploy Application') {
            when { 
                not { 
                  branch 'master'
                }
            }
            steps {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'aws-key', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    script {
                        def tfHome = tool name: 'terraform-0.12.10'
                        env.PATH = "${tfHome}:${env.PATH}"
                    }

                    echo 'Build ZIP File(s) For Deployment'
                    sh 'npm run build'
                
                    // Run Terraform
                    dir("dist") {
                        echo 'Terraform Stuff'
                        sh 'ls -l'
                        sh 'terraform --version'
                        sh 'terraform init'
                        sh 'terraform plan -var-file="vars/dev-us-east-1.tfvars" -out=plan'
                        sh 'terraform apply plan'
                    }
                }
 
            }
        }
    }
}
