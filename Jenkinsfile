pipeline {
    agent any
    tools {
        maven 'maven3'
    }
    
    stages {
        stage('git checkout') {
            steps {
              script {
                git credentialsId: 'github-cred', url: 'https://github.com/vignesh2310/CICD-DEMO.git'
              }
            }
        }

        stage('unit test') {
            steps {
                script {
                    sh 'mvn test'
                }
            }
        }

        stage('integration test') {
            steps {
                script {
                    sh 'mvn verify -DskipUnitTests'
                }
            }
        }

        stage('maven build') {
            steps {
                script {
                    sh 'mvn clean install'
                }
            }
        }

        stage('static code analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonarcred') {
                      sh 'mvn clean package sonar:sonar'
                    }
                }    
            }
        }

        stage('wait for quality gates') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonarcred'
                }
            }
        }

        stage('nexus artifact upload') {
            steps {
                script {
                    nexusArtifactUploader artifacts: 
                    [
                        [
                            artifactId: 'springboot',
                             classifier: '',
                              file: 'target/Uber.jar',
                               type: 'jar'
                        ]
                    ],
                            credentialsId: 'nexuscred',
                                 groupId: 'com.example',
                                  nexusUrl: '3.144.250.162:8081',
                                   nexusVersion: 'nexus3',
                                    protocol: 'http',
                                     repository: 'springapp-release',
                                      version: "${env.JOB_NAME}-${env.BUILD_NUMBER}"    
                }
            }
        }

        stage('build docker image') {
            steps {
                script {
                    sh 'docker build -t $JOB_NAME-uberimage:v1.$BUILD_ID .'
                    sh 'docker image tag $JOB_NAME-uberimage:v1.$BUILD_ID vignesh22310/$JOB_NAME-uberimage:v1.$BUILD_ID'
                    sh 'docker image tag $JOB_NAME-uberimage:v1.$BUILD_ID vignesh22310/$JOB_NAME-uberimage:latest'
                }
            }
        }

        stage('push image to dockerhub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockercred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                   script {
                    
                       sh "docker login -u '$USER' -p '$PASS'"
                       sh 'docker push vignesh22310/$JOB_NAME-uberimage:v1.$BUILD_ID'
                       sh 'docker push vignesh22310/$JOB_NAME-uberimage:latest'
                    
                   }
                } 
            }
        }

        stage('deploy to tomcat') {
            steps {
                script {
                    deploy adapters: [tomcat9(credentialsId: 'tomcat-deployer', path: '', url: 'http://18.223.235.162:8080/')], contextPath: null, war: '**/*.jar'
                   
                    // sshagent(['tomcat-ssh-agent']) {
                    //    sh 'scp -o StrictHostKeyChecking=no target/Uber.jar ubuntu@18.223.235.162:/opt/apache-tomcat-9.0.75/webapps' 
                    // }
                   
                }
            }
        }
    }
}