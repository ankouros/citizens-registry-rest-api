package gr.university.citizen.service.rest;

import org.glassfish.jersey.server.ResourceConfig;

/**
 * Jersey application configuration.
 * Registers REST resources under the specified package.
 */
public class CitizenApplication extends ResourceConfig {

    public CitizenApplication() {
        // Register REST resource package
        packages("gr.university.citizen.service.rest");
    }
}
