package org.springframework.cloud.dataflow.server.kubernetes;

import org.springframework.boot.SpringApplication;
import org.springframework.cloud.dataflow.server.EnableDataFlowServer;

/**
 * Bootstrap class for the OpenShift 3 Spring Cloud Data Flow Server.
 *
 * @author Donovan Muller
 */
@EnableDataFlowServer
public class OpenShiftDataFlowServer {

    public static void main(String[] args) {
        SpringApplication.run(OpenShiftDataFlowServer.class, args);
    }
}
