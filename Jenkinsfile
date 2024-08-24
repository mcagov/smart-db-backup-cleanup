pipeline {

    agent {
        docker {
            image '009543623063.dkr.ecr.eu-west-2.amazonaws.com/jenkins-docker-ci:latest'
            alwaysPull true
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        DOCKER_REGISTRY = '009543623063.dkr.ecr.eu-west-2.amazonaws.com'
        DOCKER_OPTS = '--pull --compress --no-cache=true --force-rm=true --progress=plain '
        DOCKER_BUILDKIT = '1'
        //DOCKER_IMAGE_NAME = "${env.JOB_NAME.split('/')[-2]?.replace("docker-","")}"
        DOCKER_IMAGE_NAME ="smart-db-backup-cleanup"
        DOCKER_TAG = "${env.BRANCH_NAME == "master" ? "latest" : env.BRANCH_NAME}"
    }

    triggers{
        // run once a week between the hours of 1 and 6 on sunday
        cron('H H(1-6) * * 0')
    }

    options{
        ansiColor('xterm')
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds()
    }

    stages {

        stage('build'){
            steps{
                sh '''
                    docker build ${DOCKER_OPTS} -t "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}" .
                '''
            }
        }

        stage('publish') {
            steps{
                sh '''
                    docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
                '''
            }
        }
    }
}
