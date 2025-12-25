package gr.university.citizen.service.core;

import gr.university.citizen.domain.Citizen;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Basic unit test skeleton for CitizenService.
 * Extend these tests to cover all internal classes as required.
 */
class CitizenServiceTest {

    private final CitizenService service = new CitizenService();

    @Test
    void createCitizen_shouldReturnCitizen() {
        Citizen citizen = new Citizen("John", "Doe", "AFM123", "AMKA123", LocalDate.now());
        Citizen created = service.create(citizen);

        assertNotNull(created);
        assertEquals("John", created.getFirstName());
    }
}
