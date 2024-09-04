pipeline {
    agent any
    stages {
        stage('Scan Jobs for Sonar Quality Check') {
            steps {
                script {
                    def jobsWithSonar = []
                    def jobsWithoutSonar = []

                    // Iterate through all Jenkins jobs
                    Jenkins.instance.allItems(Job).each { job ->
                        def hasSonar = false

                        // Check if it's a Pipeline job (Pipeline script)
                        if (job instanceof WorkflowJob) {
                            // Get the pipeline definition/script
                            def definition = job.getDefinition().getScript()

                            // Check for the "sonar-quality" stage in both declarative and scripted pipelines
                            if (definition.contains("sonar-quality")) {
                                hasSonar = true
                            }
                        }

                        // Classify the job based on the presence of the sonar-quality stage
                        if (hasSonar) {
                            jobsWithSonar.add(job.fullName)
                        } else {
                            jobsWithoutSonar.add(job.fullName)
                        }
                    }

                    // Print the results to the console
                    echo "Jobs with Sonar Quality Check stage:"
                    jobsWithSonar.each { echo it }

                    echo "\nJobs without Sonar Quality Check stage:"
                    jobsWithoutSonar.each { echo it }
                }
            }
        }

        stage('Generate Report File') {
            steps {
                script {
                    def reportFile = 'sonar_quality_check_report.txt'

                    // Write the results to a file
                    writeFile file: reportFile, text: """
                        Jobs with Sonar Quality Check stage:
                        -----------------------------------
                        ${jobsWithSonar.join('\n')}

                        Jobs without Sonar Quality Check stage:
                        --------------------------------------
                        ${jobsWithoutSonar.join('\n')}
                    """

                    // Archive the file as an artifact (optional)
                    archiveArtifacts artifacts: reportFile, allowEmptyArchive: true

                    // Print the file location
                    echo "Report generated: ${reportFile}"
                }
            }
        }
    }
}
