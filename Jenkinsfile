node {
    // Configuration variables
    def apiEndpoint = 'https://<your-xs-api-endpoint>'
    def adminUser = '<your-admin-user>'
    def adminPassword = '<your-admin-password>'
    def targetUser = '<your-target-user>'
    def jenkinsUrl = 'http://<your-jenkins-url>'
    def jenkinsUsername = '<your-jenkins-username>'
    def jenkinsToken = '<your-jenkins-api-token>'
    def credentialId = '<your-jenkins-credential-id>'

    // Generate a new password function
    def generatePassword = { length ->
        def chars = ('a'..'z') + ('A'..'Z') + ('0'..'9') + '!@#$%^&*()_-+='
        def random = new Random()
        return (1..length).collect { chars[random.nextInt(chars.size())] }.join()
    }

    // Generate a new secure password
    def newPassword = generatePassword(16)
    echo "Generated new password."

    stage('Update XSA User Password') {
        try {
            // Login to SAP HANA XSA
            sh """
                xs login -a ${apiEndpoint} -u ${adminUser} -p ${adminPassword} --skip-ssl-validation
            """

            // Update the deploy user's password
            sh """
                xs set-user-password ${targetUser} ${newPassword}
            """
            echo "Password updated successfully in XSA."
        } catch (Exception e) {
            error "Failed to update XSA user password: ${e.getMessage()}"
        }
    }

    stage('Update Jenkins Credentials') {
        try {
            // Use Jenkins REST API to update the credentials
            def credentialsXml = """
                <com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
                    <scope>GLOBAL</scope>
                    <id>${credentialId}</id>
                    <description>Updated deploy user password</description>
                    <username>${targetUser}</username>
                    <password>${newPassword}</password>
                </com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
            """

            def response = sh(
                script: """
                    curl -X POST "${jenkinsUrl}/credentials/store/system/domain/_/credential/${credentialId}/config.xml" \\
                        --user "${jenkinsUsername}:${jenkinsToken}" \\
                        -H "Content-Type: application/xml" \\
                        --data '${credentialsXml}'
                """,
                returnStatus: true
            )

            if (response == 0) {
                echo "Jenkins credentials updated successfully."
            } else {
                error "Failed to update Jenkins credentials."
            }
        } catch (Exception e) {
            error "Failed to update Jenkins credentials: ${e.getMessage()}"
        }
    }
}
