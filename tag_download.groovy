pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/your-username/your-repo'
        CREDENTIALS_ID = 'your-credentials-id'
        EMAIL_SUBJECT = "New Version Released: \${NEW_VERSION}"
        EMAIL_BODY = "A new version \${NEW_VERSION} has been released. Please find details in the release notes."
        EMAIL_TO = "team@example.com"
        ARTIFACT_DIR = '/path/to/your/artifact/directory' // Update with your specific directory path on the node machine
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', 
                          branches: [[name: '*/main']],
                          userRemoteConfigs: [[url: "${env.REPO_URL}.git", credentialsId: env.CREDENTIALS_ID]]
                ])
            }
        }

        stage('Determine Next Version') {
            steps {
                script {
                    // Fetch all tags to determine the latest version
                    sh "git fetch --tags"
                    def latestTag = sh(script: "git describe --tags `git rev-list --tags --max-count=1`", returnStdout: true).trim()
                    echo "Latest tag: ${latestTag}"

                    // Parse the latest semantic version
                    def major, minor, patch, preRelease
                    if (latestTag && latestTag =~ /^v(\d+)\.(\d+)\.(\d+)(-pre\.(\d+))?$/) {
                        major = Integer.parseInt(RegExp.$1)
                        minor = Integer.parseInt(RegExp.$2)
                        patch = Integer.parseInt(RegExp.$3)
                        preRelease = RegExp.$5 ? Integer.parseInt(RegExp.$5) : 0
                    } else {
                        echo "No valid semantic version tag found."
                        return
                    }

                    // Determine the next version
                    def newVersion
                    if (env.BRANCH_NAME == 'main') {
                        // Increment patch version for main branch (release)
                        patch++
                        newVersion = "v${major}.${minor}.${patch}"
                    } else {
                        // Increment pre-release version for other branches
                        preRelease++
                        newVersion = "v${major}.${minor}.${patch}-pre.${preRelease}"
                    }

                    echo "New version: ${newVersion}"
                    env.NEW_VERSION = newVersion
                }
            }
        }

        stage('Tag Repository') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Tag the repository with the new version
                    sh "git tag -a ${env.NEW_VERSION} -m 'Automated release ${env.NEW_VERSION}'"
                    sh "git push origin ${env.NEW_VERSION}"
                }
            }
        }

        stage('Download Artifacts') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Download .zip artifact from the tag
                    def downloadUrlZip = "${env.REPO_URL}/archive/refs/tags/${env.NEW_VERSION}.zip"
                    sh "curl -sSL -o ${env.WORKSPACE}/my-artifact-${env.NEW_VERSION}.zip ${downloadUrlZip}"

                    // Download .tar.gz artifact from the tag
                    def downloadUrlTar = "${env.REPO_URL}/archive/refs/tags/${env.NEW_VERSION}.tar.gz"
                    sh "curl -sSL -o ${env.WORKSPACE}/my-artifact-${env.NEW_VERSION}.tar.gz ${downloadUrlTar}"
                }
            }
        }

        stage('Store Artifacts') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Move downloaded artifacts to the desired directory on the node machine
                    sh "mv ${env.WORKSPACE}/my-artifact-${env.NEW_VERSION}.zip ${env.ARTIFACT_DIR}/"
                    sh "mv ${env.WORKSPACE}/my-artifact-${env.NEW_VERSION}.tar.gz ${env.ARTIFACT_DIR}/"
                }
            }
        }

        stage('Send Email Notification') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Send email notification about the artifacts download
                    emailext body: "${env.EMAIL_BODY}", subject: "${env.EMAIL_SUBJECT}", to: "${env.EMAIL_TO}"
                }
            }
        }
    }
}
