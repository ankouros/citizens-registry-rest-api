package gr.university.citizen.domain;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class CitizenTest {

    @Test
    void constructor_shouldSetFields() {
        LocalDate birth = LocalDate.of(1990, 1, 1);
        Citizen c = new Citizen("John", "Doe", "123456789", "12345678901", birth);

        assertEquals("John", c.getFirstName());
        assertEquals("Doe", c.getLastName());
        assertEquals("123456789", c.getAfm());
        assertEquals("12345678901", c.getAmka());
        assertEquals(birth, c.getBirthDate());
    }

    @Test
    void settersAndGetters_shouldWork() {
        Citizen c = new Citizen();
        LocalDate birth = LocalDate.of(2000, 12, 31);

        c.setId(10L);
        c.setFirstName("Alice");
        c.setLastName("Smith");
        c.setAfm("987654321");
        c.setAmka("10987654321");
        c.setBirthDate(birth);

        assertEquals(10L, c.getId());
        assertEquals("Alice", c.getFirstName());
        assertEquals("Smith", c.getLastName());
        assertEquals("987654321", c.getAfm());
        assertEquals("10987654321", c.getAmka());
        assertEquals(birth, c.getBirthDate());
    }

    @Test
    void id_canBeNullBeforePersist() {
        Citizen c = new Citizen("A", "B", "123456789", "12345678901", LocalDate.now());
        assertNull(c.getId(), "Before persistence, id should be null");
    }
}
