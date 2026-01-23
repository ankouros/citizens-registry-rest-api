package gr.university.citizen.service.rest;

import gr.university.citizen.domain.Citizen;
import gr.university.citizen.service.core.CitizenService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Spring REST controller for managing citizens.
 */
@RestController
@RequestMapping("/citizens")
public class CitizenResource {

    private final CitizenService citizenService;

    public CitizenResource(CitizenService citizenService) {
        this.citizenService = citizenService;
    }

    @GetMapping
    public List<Citizen> getAll() {
        return citizenService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Citizen> getById(@PathVariable("id") Long id) {
        try {
            Citizen citizen = citizenService.findById(id);
            return ResponseEntity.ok(citizen);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @PostMapping
    public ResponseEntity<Citizen> create(@RequestBody Citizen citizen) {
        try {
            Citizen created = citizenService.create(citizen);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<Citizen> update(
            @PathVariable("id") Long id,
            @RequestBody Citizen citizen
    ) {
        try {
            Citizen updated = citizenService.update(id, citizen);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException ex) {
            String msg = ex.getMessage();
            if (msg != null && msg.toLowerCase().contains("not found")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable("id") Long id) {
        try {
            citizenService.delete(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException ex) {
            String msg = ex.getMessage();
            if (msg != null && msg.toLowerCase().contains("not found")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }
}
