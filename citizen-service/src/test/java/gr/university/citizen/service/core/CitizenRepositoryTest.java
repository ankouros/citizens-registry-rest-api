package gr.university.citizen.service.core;

import gr.university.citizen.domain.Citizen;
import gr.university.citizen.service.rest.CitizenApplication;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ContextConfiguration;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
@ContextConfiguration(classes = CitizenApplication.class)
class CitizenRepositoryTest {

    @Autowired
    private CitizenRepository repository;

    @Test
    void saveAndFind_shouldPersistCitizen() {
        Citizen c = new Citizen(
                "John", "Doe",
                "123456789", "12345678901",
                LocalDate.of(1990, 1, 1)
        );

        Citizen saved = repository.save(c);
        assertNotNull(saved.getId());

        Citizen found = repository.findById(saved.getId()).orElseThrow();
        assertEquals("John", found.getFirstName());
        assertEquals("Doe", found.getLastName());
    }

    @Test
    void delete_shouldRemoveCitizen() {
        Citizen c = repository.save(
                new Citizen("A", "B", "111111111", "11111111111", LocalDate.of(2001, 1, 1))
        );

        repository.deleteById(c.getId());
        assertTrue(repository.findById(c.getId()).isEmpty());
    }
}
