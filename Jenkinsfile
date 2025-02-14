pipeline {
  agent any
  environment {
		      DOCKERHUB_CREDENTIALS=credentials('dockerhub')
	      }
   stages {
    stage ('Build') {
      steps {
        sh '''#!/bin/bash
        python3 -m venv test3
        source test3/bin/activate
        pip install pip --upgrade
        pip install -r requirements.txt
        export FLASK_APP=application
        flask run &
        '''
     }
   }
     
    stage ('test') {
      steps {
        sh '''#!/bin/bash
        source test3/bin/activate
        py.test --verbose --junit-xml test-reports/results.xml
        ''' 
      }
    
      post{
        always {
          junit 'test-reports/results.xml'
        }
       }
    }

      stage('Create_image') {
        agent{label 'docker_agent'}
        steps{
          sh '''#!/bin/bash
	  sudo usermod -a -G docker jenkins	  
          docker build -t deployment5:latest .
          '''
        }
      }
     
     stage('Push') {
        agent{label 'docker_agent'}
        steps{
          sh '''#!/bin/bash
          echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
	  docker tag deployment5:latest nasiryork/deployment5:latest
          docker push nasiryork/deployment5:latest
          '''
        }
      }   
     
     stage('Init') {
       agent{label 'terra_agent'}
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                              sh 'terraform init' 
                            }
         }
    }
   }
      stage('Plan') {
        agent{label 'terra_agent'}
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                              sh 'terraform plan -out plan.tfplan -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"' 
                            }
         }
    }
   }
      stage('Destroy') {
        agent{label 'terra_agent'}
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                              sh 'terraform destroy -auto-approve -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"' 
                            }
         }
       }
      } 
   }
}
