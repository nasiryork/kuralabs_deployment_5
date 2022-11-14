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
	  git clone https://github.com/nasiryork/kuralabs_deployment_5.git	  
          docker build -t nasiryork/deployment5:latest .
          '''
        }
      }
     
     stage('Push') {
        agent{label 'docker_agent'}
        steps{
          sh '''#!/bin/bash
          echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
          sudo docker push nasiryork/deployment5:latest
          '''
        }
      }   
     
     
   }
}
