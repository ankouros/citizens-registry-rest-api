package gr.university.citizen.service.core;

import gr.university.citizen.domain.Citizen;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Internal service responsible for the business logic of the citizen registry.
 * This class is a key target for JUnit unit tests in the second basic requirement.
 */
@Service
public class CitizenService {

    private final Map<Long, Citizen> citizens = new ConcurrentHashMap<>();
    private final AtomicLong idSequence = new AtomicLong(1);

    public List<Citizen> findAll() {
        return new ArrayList<>(citizens.values());
    }

    public Citizen findById(Long id) {
        validateId(id);
        Citizen citizen = citizens.get(id);
        if (citizen == null) {
            throw new IllegalArgumentException("Citizen not found: " + id);
        }
        return citizen;
    }

    public Citizen create(Citizen citizen) {
        if (citizen == null) {
            throw new IllegalArgumentException("Citizen must not be null");
        }
        long id = idSequence.getAndIncrement();
        citizen.setId(id);
        citizens.put(id, citizen);
        return citizen;
    }

    public Citizen update(Long id, Citizen citizen) {
        validateId(id);
        if (citizen == null) {
            throw new IllegalArgumentException("Citizen must not be null");
        }
        if (!citizens.containsKey(id)) {
            throw new IllegalArgumentException("Citizen not found: " + id);
        }
        citizen.setId(id);
        citizens.put(id, citizen);
        return citizen;
    }

    public void delete(Long id) {
        validateId(id);
        Citizen removed = citizens.remove(id);
        if (removed == null) {
            throw new IllegalArgumentException("Citizen not found: " + id);
        }
    }

    private void validateId(Long id) {
        if (id == null || id <= 0) {
            throw new IllegalArgumentException("Id must be a positive number");
        }
    }
}
