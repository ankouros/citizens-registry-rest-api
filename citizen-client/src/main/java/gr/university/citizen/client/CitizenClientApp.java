package gr.university.citizen.client;

import gr.university.citizen.domain.Citizen;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.time.LocalDate;
import java.util.List;
import java.util.Scanner;

/**
 * Spring Boot console client application.
 */
@SpringBootApplication
public class CitizenClientApp {

    public static void main(String[] args) {
        SpringApplication.run(CitizenClientApp.class, args);
    }

    @Bean
    CommandLineRunner run(CitizenRestClient client) {
        return args -> {
            Scanner scanner = new Scanner(System.in);

            while (true) {
                System.out.println("\n=== Citizen Registry Client ===");
                System.out.println("1. List citizens");
                System.out.println("2. Create sample citizen");
                System.out.println("Other: Exit");
                System.out.print("Choice: ");

                String choice = scanner.nextLine();

                if ("1".equals(choice)) {
                    List<Citizen> citizens = client.getAll();
                    citizens.forEach(c ->
                            System.out.println(
                                    c.getId() + " - " +
                                    c.getFirstName() + " " +
                                    c.getLastName()
                            )
                    );
                } else if ("2".equals(choice)) {
                    Citizen citizen = new Citizen(
                            "John",
                            "Doe",
                            "12345678",
                            "123456789",
                            LocalDate.now()
                    );

                    Citizen created = client.create(citizen);
                    System.out.println("Created citizen with id: " + created.getId());
                } else {
                    System.out.println("Exiting.");
                    break;
                }
            }
        };
    }
}
