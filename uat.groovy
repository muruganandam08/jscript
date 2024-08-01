#!/usr/bin/env groovy
def call(Map params) {

    def subaccount = params.subaccount ?: 'DEV'  // Default to 'DEV' if subaccount is not provided
    def mailList

    // Determine the mailList based on the subaccount value
    switch (subaccount) {
        case 'UAT':
            mailList = "${AD_Group}, uat@notification@gmail.com"
            break
        case 'IT':
        case 'PROD':
        case 'DEV':
        default:
            mailList = "${AD_Group}"
            break
    }

    // Send notifications based on the build result
    if (currentBuild.currentResult == "SUCCESS") {
        echo "mail: ${mailList}"
        emailext(
            attachLog: true,
            body: "${SCRIPT, template='groovy-html.template'}",
            subject: "${currentBuild.projectName} for object ${module} from ${GIT_BRANCH} #${currentBuild.number} - ${currentBuild.currentResult}",
            to: "${mailList}"
        )
    } else if (currentBuild.currentResult == "FAILURE") {
        echo "mail: ${mailList}"
        emailext(
            attachLog: true,
            body: "${SCRIPT, template='groovy-html.template'}",
            subject: "${currentBuild.projectName} for object ${module} from ${GIT_BRANCH} #${currentBuild.number} - ${currentBuild.currentResult}",
            to: "${mailList}"
        )
    } else if (currentBuild.currentResult == "ABORTED") {
        echo "mail: ${mailList}"
        emailext(
            attachLog: true,
            body: "${SCRIPT, template='groovy-html.template'}",
            subject: "${currentBuild.projectName} for object ${module} from ${GIT_BRANCH} #${currentBuild.number} - ${currentBuild.currentResult}",
            to: "${mailList}"
        )
    } else {
        echo "Unknown build result: ${currentBuild.currentResult}"
    }
}
