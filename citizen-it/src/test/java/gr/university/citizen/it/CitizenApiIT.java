package gr.university.citizen.it;

import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * Basic Rest-Assured integration test skeleton.
 * You must ensure the citizen-service WAR is deployed and running
 * (e.g. via Cargo) before these tests are executed.
 */
class CitizenApiIT {

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost";
        RestAssured.port = 8080;
        RestAssured.basePath = "/citizen-service/api/citizens";
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
