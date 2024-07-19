#!/usr/bin/env groovy

def call(Map params) {
    if (env.GIT_Branch_Tag != "") {
        env.mailList = "${params.AD_Group}"
        def emailBody = ''
        def emailSubject = ''
        def emailRecipients = ''

        if (params.SubAccount == "UAT") {
            emailBody = '${SCRIPT, template="groovy-html.template"}'
            emailSubject = "${currentBuild.projectName} for object ${params.module} from ${env.GIT_Branch_Tag} #${currentBuild.number}-${currentBuild.currentResult}"
            emailRecipients = "${env.mailList}, your_personal_email@example.com"
        } else {
            emailBody = '${SCRIPT, template="groovy-html.template"}'
            emailSubject = "${currentBuild.projectName} for object ${params.module} from ${env.GIT_Branch_Tag} #${currentBuild.number}-${currentBuild.currentResult}"
            emailRecipients = env.mailList
        }

        emailext(
            to: emailRecipients,
            attachLog: true,
            body: emailBody,
            subject: emailSubject
        )
    }
}
