package gr.university.citizen.service;

import gr.university.citizen.service.core.CitizenRepository;
import gr.university.citizen.service.core.CitizenService;
import gr.university.citizen.service.rest.CitizenApplication;
import gr.university.citizen.service.rest.CitizenResource;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(classes = CitizenApplication.class)
class ConfigurationTest {

    @Autowired
    private CitizenService citizenService;

    @Autowired
    private CitizenRepository citizenRepository;

    @Autowired
    private CitizenResource citizenResource;

    @Test
    void contextLoads_andBeansAreCreated() {
        assertNotNull(citizenService);
        assertNotNull(citizenRepository);
        assertNotNull(citizenResource);
    }
}
