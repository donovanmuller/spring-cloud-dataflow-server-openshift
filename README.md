# Spring Cloud Data Flow Server for OpenShift

This project provides a Spring Cloud Data Flow server for deployments to OpenShift 3, using the 
[Spring Cloud Deployer OpenShift](https://github.com/donovanmuller/spring-cloud-deployer-openshift) 
implementation of the [Spring Cloud Deployer](https://github.com/spring-cloud/spring-cloud-deployer) SPI.

## Building

You must clone and build the `spring-cloud-deployer-openshift` and
 `spring-cloud-dataflow-server-openshift` projects:

```
$ git clone https://github.com/donovanmuller/spring-cloud-deployer-openshift.git && \
  cd spring-cloud-deployer-openshift && \
  ./mvnw install
  
$ git clone https://github.com/donovanmuller/spring-cloud-dataflow-server-openshift.git && \
  cd spring-cloud-dataflow-server-openshift && \
  ./mvnw package
```

## Running

The Data Flow OpenShift server requires a running OpenShift 3 instance.
To start the Spring Cloud Data Flow OpenShift server, provide the following properties at a minimum:

```
$ cd spring-cloud-deployer-openshift/target
$ java -Dopenshift.url=https://172.28.128.4:8443 \
  -Dkubernetes.master=https://172.28.128.4:8443 \
  -Dkubernetes.trust.certificates=true \
  -Dkubernetes.auth.basic.username=admin \
  -Dkubernetes.auth.basic.password=admin \
  -jar spring-cloud-dataflow-server-openshift-1.1.0.BUILD-SNAPSHOT.jar \
  --spring.cloud.deployer.kubernetes.namespace=scdf-apps \
  --maven.resolvePom=true \
  --maven.remote-repositories.spring.url=http://repo.spring.io/snapshots
```

where `https://172.28.128.4:8443` is the URL of your OpenShift master instance.
The `--spring.cloud.deployer.kubernetes.namespace` property is optional and indicates the project to deploy applications too.
The `default` project is used in this properties absence.

## Deploying

You can follow either the [Local](http://docs.spring.io/spring-cloud-dataflow/docs/current-SNAPSHOT/reference/htmlsingle/#spring-cloud-dataflow-register-apps) 
or [Kubernetes](http://docs.spring.io/spring-cloud-dataflow-server-kubernetes/docs/current-SNAPSHOT/reference/htmlsingle/#_deploying_streams_on_kubernetes) 
documentation on registering and app, creating a stream/task definition and deploying the apps.

## Further Reading

Please see the following posts for more information:

* [Spring Cloud Deployer OpenShift](http://blog.switchbit.io/spring-cloud-deployer-openshift)
* [SCDF OpenShift: Deploying Maven artifacts with custom Dockerfile](http://blog.switchbit.io/scdf-openshift-deploying-maven-artifacts-with-custom-dockerfile)
