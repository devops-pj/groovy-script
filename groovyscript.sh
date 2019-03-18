#!groovy
try{
  //http://localhost:8080/pipeline-syntax/globals#currentBuild
  //Getting the  env  global varibale values
 
  echo "GitHub BranhName ${env. BRANCH_NAME}"
  echo "Jenkins Job Number ${env.BUILD_NUMBER}"
  echo "Jenkins Node Name ${env.NODE_NAME}"
  
  echo "Jenkins Home ${env.JENKINS_HOME}"
  echo "Jenkins URL ${env.JENKINS_URL}"
  echo "JOB Name ${env.JOB_NAME}"
  
properties([
    buildDiscarder(logRotator(numToKeepStr: '3')),
    pipelineTriggers([
        pollSCM('* * * * *')
    ])
])
//properties([buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5'))])
//node('slave1') {
//node (label: 'slave1') {
//node('master'){
node {
  def mvnHome = tool name: 'M3_HOME', type: 'maven'
  cleanWs notFailBuild: true
  
  currentBuild.result = "SUCCESS"
  
  
 // stage('Checkout'){
 //  checkout scm
 // }
  
  
  stage('Checkout the code'){
     git branch: 'master', credentialsId: '4862c36a-cb75-4ad6-a7dc-dad0abf563c8', url: 'https://github.com/devopstrainingblr/Maven-Web-Project.git'
  }
  
  stage('Build'){
     if(isUnix()){
     sh "${mvnHome}/bin/mvn clean package"
      }
      else{
       bat "${mvnHome}/bin/mvn clean package"   
      }
  }
  
   
 
 
 stage('SonarqubeReport'){
     if(isUnix()){
     sh "${mvnHome}/bin/mvn  sonar:sonar"
      }
      else{
       bat "${mvnHome}/bin/mvn  sonar:sonar"  
      }
  }
  
  stage('Upload Artifacts into Nexus'){
     if(isUnix()){
     sh "${mvnHome}/bin/mvn clean deploy"
      }
      else{
       bat "${mvnHome}/bin/mvn clean deploy"   
      }
  }
  
  stage('DeployAppIntoTomcat'){
     if(isUnix()){
      sh 'echo "Starting deployment"'
      sh 'cp $WORKSPACE/target/*.war /Users/bhaskarreddyl/BhaskarReddyL/Softwares/Running/apache-tomcat-9.0.12/webapps/'
      sh 'echo "Deployment done successfully"'
      }
      else{
       bat 'echo windows'   
      }
  }
 
    stage('EmailNotification'){
        mail to: 'devopstrainingblr@gmail.com',
             subject: "Job '${JOB_NAME}' # ${BUILD_NUMBER} is success",
             body: "Please go to ${BUILD_URL} and verify the build \n"
       }
       
       stage('Send Slack Notification'){
           slackSend baseUrl: 'https://devops-team-bangalore.slack.com/services/hooks/jenkins-ci/', 
                     channel: 'build-notifcation', 
                     color: 'blue', 
                     message: 'Build done successfully ', 
                     tokenCredentialId: '193d10e7-9280-4629-84e8-5ec4a30b87b5',
                     teamDomain: 'https://devops-team-bangalore.slack.com/services/hooks/jenkins-ci/'
       }
      }
    
}catch(error){
     currentBuild.result = "FAILURE"
        mail to: 'devopstrainingblr@gmail.com',
             subject: "Job '${JOB_NAME}' # ${BUILD_NUMBER} is success",
             body: "Please go to ${BUILD_URL} and verify the build \n"
        
           slackSend baseUrl: 'https://devops-team-bangalore.slack.com/services/hooks/jenkins-ci/', 
                     channel: 'build-notifcation', 
                     color: 'red', 
                     message: 'Build done successfully ', 
                     tokenCredentialId: '193d10e7-9280-4629-84e8-5ec4a30b87b5',
                     teamDomain: 'https://devops-team-bangalore.slack.com/services/hooks/jenkins-ci/'
    
        throw error
      }
