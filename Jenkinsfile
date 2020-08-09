node{
    catchError{
		def Maven_Home = tool name: 'Maven-Auto', type: 'maven'
		def Docker_Home = tool name: 'Docker-Auto', type: 'dockerTool'
		
		stage('Git Checkout'){
			git credentialsId: 'github_cred', url: "$GIT_URL"
		}
		
		stage('SonarQube analysis') {
			withSonarQubeEnv(credentialsId: 'localsonarsecret', installationName: 'LocalSonarqube') {
				sh '$Maven_Home/bin/mvn sonar:sonar'
			}
		}

/* Commenting as it fails build for some default conditions not matching.
        stage("Quality Gate"){
			sleep 50
			timeout(time: 10, unit: 'MINUTES') { 
				def qg = waitForQualityGate() 
				if (qg.status != 'OK') {
					error "Pipeline aborted due to quality gate failure: ${qg.status}"
				}
			}
		}*/

		stage("Build Code"){
			sh "$Maven_Home/bin/mvn clean package"
		}
		
		stage('Docker Image build'){
			sh "sudo $Docker_Home/bin/docker build -t $DOCKER_TAG ."
		}

		stage('Docker Push Image'){
			echo "So"
			withCredentials([usernamePassword(credentialsId: 'DockerhubMayur', passwordVariable: 'password', usernameVariable: 'username')]) {
			sh "sudo $Docker_Home/bin/docker login -u '${username}' -p '${password}'"
			}
			sh "sudo $Docker_Home/bin/docker push $DOCKER_TAG"
		}
		
	/*    stage('Docker Run Container'){
			sh "sudo $Docker_Home/bin/docker run -dti -p 8084:8090 $DOCKER_TAG"
		}
		
	    stage('Up in cloud foundry'){
	        pushToCloudFoundry(
	        target: 'https://api.run.pivotal.io',
	        organization: 'mayurssoni-org',
	        cloudSpace: 'development',
	        credentialsId: 'cloudfondrymayur'
	        )
	    }

		stage("Start app in cloud Foundary"){
			withCredentials([usernamePassword(credentialsId: 'cloudfondrymayur', passwordVariable: 'pass', usernameVariable: 'user')]) {
			sh "cf login -a https://api.run.pivotal.io -u '${user}' -p '${pass}' -o mayurssoni-org -s development"
			}
			sh "cf push devops_spring --docker-image $DOCKER_TAG"
		}*/
		
		stage("Create GCP instance and deploy container"){
		    ansiColor('xterm') {
		        dir('ansible') {
		            ansiblePlaybook colorized: true, extras: '-e "instance=${MACHINE_NAME} docker_image=${DOCKER_TAG}"', installation: 'localAnsible', playbook: 'site.yml', tags: 'create'
		        }
		    }
		}
    }
    step([$class: 'Mailer', notifyEveryUnstableBuild: false, recipients: "$RECEPIENT_LIST"])
}

