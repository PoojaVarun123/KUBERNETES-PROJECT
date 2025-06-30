pipeline {
    agent {
        label 'agent1'
    }

    stages {
        stage('Stage I : git checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-id', url: 'https://github.com/PoojaVarun123/springboot-petclinic.git'
                echo 'checkout success'
            }
        }
        
        stage('Stage II : Compile') {
            steps {
               sh 'mvn compile'
                echo 'Compilation success'
            }
        }
        stage('Stage III : Test') {
            steps {
               sh 'mvn test'
                echo 'Test success'
            }
        }
        
        stage('Stage IV: Code Coverage ') {
      steps {
	    echo "Running Code Coverage ..."
        sh "mvn jacoco:report"
      }
    }
        stage('Stage V: Trivy FS Scan ') {
      steps {
        sh "trivy fs --format table -o trivy_fs_report.txt ."
         echo "FS scan success"
      }
    }

        stage('Stage VI : Sonar analysis') {
            steps {
               withSonarQubeEnv('sonar-env-var') {
               sh ''' mvn sonar:sonar -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml -Dsonar.projectKey=springboot_project -Dsonar.projectName=springboot_project '''
                echo 'Analysis success'
            }
        }
        }
        stage('Stage VI : Quality gate') {
            steps {
               waitForQualityGate abortPipeline: false, credentialsId: 'sonar-id'
                echo 'Analysis success'
               }
         }
   
        stage('Stage VII : build ') {
            steps { 
                sh  'mvn package'
                sh 'cp -R target/petclinic.war petclinic.war'
                echo 'build success'
            }
        }
        stage('Stage VIII : upload war to jfrog'){
           steps{
               rtUpload (
               serverId: "jfrog-env-var",
                   spec: """{
                      "files": [
                                   {
                                       "pattern": "petclinic.war",
                                       "target": "libs-snapshot-local"
                                   }
                                ]
                            }"""
                )            
            echo 'upload success'
           }           
           }
            stage('Stage IX : Docker image creation ') {
            steps { 
                sh 'docker build -t varunpooja/springboot_app:V$BUILD_NUMBER .'
                echo 'Image creation success'
            }
            }
            
            stage('Stage X : Trivy Image Scan ') {
            steps {
                 sh "trivy image --format table -o trivy_image_report.txt varunpooja/springboot_app:V$BUILD_NUMBER"
                 echo "Image scan success"
      }
    } 
            stage('Stage IX : Docker image push ') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-id', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                sh "docker login -u ${USERNAME} -p ${PASSWORD}"
                sh 'docker push varunpooja/springboot_app:V${BUILD_NUMBER}'
                echo 'docker push success'
       }
            }
        }
            stage('Update Deployment File') {
                environment {
                    GIT_REPO_NAME = "springboot-petclinic"
                }
                    steps {
                withCredentials([usernamePassword(credentialsId: 'github-id', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME ')]) {
                sh '''
                    git config user.email "poojaas0711@gmail.com "
                    git config user.name "PoojaVarun123"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    sed -i "s|poojavarun/springboot_app:.*|varunpooja/springboot_app:V${BUILD_NUMBER}|g" manifest/deployment.yaml
                    git add manifest/deployment.yaml
                    git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                    git push https://${USERNAME}:${PASSWORD}@github.com/${USERNAME}/${GIT_REPO_NAME} HEAD:main
                '''
            }
        }
    }
  }
}
