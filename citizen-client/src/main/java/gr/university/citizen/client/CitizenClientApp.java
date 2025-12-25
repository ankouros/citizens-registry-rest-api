package gr.university.citizen.client;

import gr.university.citizen.domain.Citizen;

import java.time.LocalDate;
import java.util.List;
import java.util.Scanner;

/**
 * Simple console menu client.
 * Extend this according to the assignment's menu requirements.
 */
public class CitizenClientApp {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        CitizenRestClient client = new CitizenRestClient("http://localhost:8080/citizen-service/api");

        while (true) {
            System.out.println("1. List citizens");
            System.out.println("2. Create sample citizen");
            System.out.println("Other: Exit");
            System.out.print("Choice: ");
            String choice = scanner.nextLine();

            if ("1".equals(choice)) {
                List<Citizen> citizens = client.getAll();
                citizens.forEach(c -> System.out.println(c.getId() + " - " + c.getFirstName() + " " + c.getLastName()));
            } else if ("2".equals(choice)) {
                Citizen citizen = new Citizen("John", "Doe", "AFM123", "AMKA123", LocalDate.now());
                Citizen created = client.create(citizen);
                System.out.println("Created citizen with id: " + created.getId());
            } else {
                System.out.println("Exiting.");
                break;
            }
        }
    }
}
