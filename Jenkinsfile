node {
    def app

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace*/
        checkout scm
    }

    stage('Build image') {
        /* This builds the actual image; synonymous to
        * docker build on the command line */
        app = docker.build("marvinok26/DevOps-Prac-Docker1")
    }

    stage('Test image') {
        /* Ideally, we would run a test framework against our image,
        * for this example we're using a volkswagen type approach. */
        app.inside {
            sh 'echo "Tests passed"'
        }
    }

    stage('Push image') {
        /* Finally, we'll push the image with two tags:
        * First, the incremental build number from Jenkins
        * Second, the 'latest' tag changes.
        * Pushing multiple tags is cheap, as all the layers are reused
        * between build steps */
        docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
}