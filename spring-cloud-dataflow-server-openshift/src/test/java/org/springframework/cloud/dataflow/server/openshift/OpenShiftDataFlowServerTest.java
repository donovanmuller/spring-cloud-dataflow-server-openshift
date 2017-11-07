package org.springframework.cloud.dataflow.server.openshift;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.cloud.deployer.resource.docker.DockerResource;
import org.springframework.cloud.deployer.resource.maven.MavenResource;
import org.springframework.cloud.deployer.resource.support.DelegatingResourceLoader;
import org.springframework.cloud.deployer.spi.app.AppDeployer;
import org.springframework.cloud.deployer.spi.openshift.OpenShiftDeployerProperties;
import org.springframework.cloud.deployer.spi.openshift.ResourceAwareOpenShiftAppDeployer;
import org.springframework.context.ApplicationContext;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT, classes = OpenShiftDataFlowServer.class, properties = {
		"spring.cloud.deployer.openshift.forceBuild=true",
		"spring.cloud.deployer.openshift.limits.memory=128Mi"})
public class OpenShiftDataFlowServerTest {

	@Autowired
	private AppDeployer appDeployer;

	@Autowired
	private ApplicationContext context;

	@Test
	public void contextLoads() {
		assertThat(appDeployer).isInstanceOf(ResourceAwareOpenShiftAppDeployer.class);
	}

	@Test
	public void testDeployerProperties() {
		OpenShiftDeployerProperties properties = context.getBean(OpenShiftDeployerProperties.class);
		assertThat(properties.isForceBuild()).isTrue();
		assertThat(properties.getLimits().getMemory()).isEqualTo("128Mi");
	}

	@Test
	public void testDockerResource() {
		DelegatingResourceLoader resourceLoader = context.getBean(DelegatingResourceLoader.class);
		assertThat(resourceLoader
				.getResource("maven://org.springframework.cloud:spring-cloud-dataflow-server-core:1.2.3.RELEASE"))
						.isInstanceOf(MavenResource.class);
		assertThat(resourceLoader.getResource("docker://helloworld:latest")).isInstanceOf(DockerResource.class);
	}
}
