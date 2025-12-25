package gr.university.citizen.it;

import gr.university.citizen.service.rest.CitizenApplication;
import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import static io.restassured.RestAssured.given;

@SpringBootTest(
        classes = CitizenApplication.class,
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT
)
class CitizenApiIT {

    @LocalServerPort
    private int port;

    @BeforeEach
    void setup() {
        RestAssured.port = port;
        RestAssured.basePath = "/citizens";
    }

    @Test
    void getAllCitizens_shouldReturnOk() {
        given()
        .when()
            .get()
        .then()
            .statusCode(200);
    }
}
