package gr.university.citizen.service.rest;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = "gr.university.citizen")
@EnableJpaRepositories(basePackages = "gr.university.citizen.service.core")
@EntityScan(basePackages = "gr.university.citizen.domain")
public class CitizenApplication {

    public static void main(String[] args) {
        SpringApplication.run(CitizenApplication.class, args);
    }
}
