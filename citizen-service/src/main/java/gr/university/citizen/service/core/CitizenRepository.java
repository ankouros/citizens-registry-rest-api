package gr.university.citizen.service.core;

import gr.university.citizen.domain.Citizen;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CitizenRepository extends JpaRepository<Citizen, Long> {
}
