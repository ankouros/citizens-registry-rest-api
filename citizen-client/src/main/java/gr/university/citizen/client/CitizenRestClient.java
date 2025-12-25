package gr.university.citizen.client;

import gr.university.citizen.domain.Citizen;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.Entity;
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.GenericType;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.util.List;

/**
 * Simple Jersey client wrapper for the citizen REST API.
 */
public class CitizenRestClient {

    private final Client client;
    private final WebTarget baseTarget;

    public CitizenRestClient(String baseUrl) {
        this.client = ClientBuilder.newClient();
        this.baseTarget = client.target(baseUrl).path("citizens");
    }

    public List<Citizen> getAll() {
        return baseTarget
                .request(MediaType.APPLICATION_JSON)
                .get(new GenericType<List<Citizen>>() {});
    }

    public Citizen getById(Long id) {
        return baseTarget
                .path(String.valueOf(id))
                .request(MediaType.APPLICATION_JSON)
                .get(Citizen.class);
    }

    public Citizen create(Citizen citizen) {
        Response response = baseTarget
                .request(MediaType.APPLICATION_JSON)
                .post(Entity.entity(citizen, MediaType.APPLICATION_JSON));
        return response.readEntity(Citizen.class);
    }

    public Citizen update(Long id, Citizen citizen) {
        Response response = baseTarget
                .path(String.valueOf(id))
                .request(MediaType.APPLICATION_JSON)
                .put(Entity.entity(citizen, MediaType.APPLICATION_JSON));
        return response.readEntity(Citizen.class);
    }

    public void delete(Long id) {
        baseTarget
                .path(String.valueOf(id))
                .request()
                .delete();
    }
}
