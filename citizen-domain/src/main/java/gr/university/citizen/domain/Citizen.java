package gr.university.citizen.domain;

import jakarta.persistence.*;
import java.time.LocalDate;

/**
 * Domain entity representing a citizen.
 */
@Entity
@Table(name = "citizens")
public class Citizen {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    @Column(nullable = false, length = 9)
    private String afm;  // tax id

    @Column(nullable = false, length = 11)
    private String amka; // social security id

    @Column(nullable = false)
    private LocalDate birthDate;

    /* ===== Constructors ===== */

    public Citizen() {
    }

    public Citizen(
            String firstName,
            String lastName,
            String afm,
            String amka,
            LocalDate birthDate
    ) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.afm = afm;
        this.amka = amka;
        this.birthDate = birthDate;
    }

    /* ===== Getters & Setters ===== */

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getAfm() {
        return afm;
    }

    public void setAfm(String afm) {
        this.afm = afm;
    }

    public String getAmka() {
        return amka;
    }

    public void setAmka(String amka) {
        this.amka = amka;
    }

    public LocalDate getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(LocalDate birthDate) {
        this.birthDate = birthDate;
    }
}
