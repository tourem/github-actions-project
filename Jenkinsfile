job_pipeline.execute(
    jfrog: true,
    mavenWithNPM: true,
    npmFixConfig: false,
    projectType: 'awt',
    javaVersion: 17,
    mavenVersion: 3.9,
    jenkinsNodeLabel: 'ocs',
    mavenPom: 'pom.xml',
    CD: 'db-intranet-deploy',
    deployModule: 'dacgestion_backend',
     dockerBuilds: [
         backend_spring: [
             deployModule: 'dacgestion_backend',
             CD: 'db-intranet-deploy',
             imageTemplateRepo: [
                 url: 'https://sgithub.fr.world.socgen/X-Blocks/xbl.sofa.awt-docker-spring',
                 branch: 'main'
             ],
             buildArgs: [
                 JAVA_VERSION: '17',
                 ARTIFACT_REFERENCE: 'com.socgen.digital.agence:dacgestion_backend:jar:${version}',
                 CONF_REFERENCE: 'com.socgen.digital.agence:dacgestion_backend:zip:${version}:conf-secrets-dev'
             ],
             dockerOptions: '--no-cache --pull'
         ],// module à déployer (dacgestion_backend ou dacgestion_batch)
    batch_spring: [
        deployModule: 'dacgestion_batch',
        CD: 'db-intranet-deploy',
        imageTemplateRepo: [
            url: 'https://sgithub.fr.world.socgen/X-Blocks/xbl.sofa.awt-docker-spring',
            branch: 'main'
        ],
        buildArgs: [
            JAVA_VERSION: '17',
            ARTIFACT_REFERENCE: 'com.socgen.digital.agence:dacgestion_batch:jar:${version}',
            CONF_REFERENCE: 'com.socgen.digital.agence:dacgestion_batch:zip:${version}:conf-secrets-dev'
        ],
        dockerOptions: '--no-cache --pull'
    ]
]
