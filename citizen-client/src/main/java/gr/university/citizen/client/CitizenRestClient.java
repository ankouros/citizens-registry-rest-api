package gr.university.citizen.client;

import gr.university.citizen.domain.Citizen;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.Arrays;
import java.util.List;

/**
 * Spring RestTemplate-based client for Citizen REST API.
 */
@Component
public class CitizenRestClient {

    private final RestTemplate restTemplate;
    private final String baseUrl;

    public CitizenRestClient(
            RestTemplate restTemplate,
            @Value("${citizen.service.base-url}") String baseUrl
    ) {
        this.restTemplate = restTemplate;
        this.baseUrl = baseUrl;
    }

    public List<Citizen> getAll() {
        Citizen[] response =
                restTemplate.getForObject(baseUrl + "/citizens", Citizen[].class);
        return Arrays.asList(response);
    }

    public Citizen getById(Long id) {
        return restTemplate.getForObject(
                baseUrl + "/citizens/" + id,
                Citizen.class
        );
    }

    public Citizen create(Citizen citizen) {
        return restTemplate.postForObject(
                baseUrl + "/citizens",
                citizen,
                Citizen.class
        );
    }

    public Citizen update(Long id, Citizen citizen) {
        restTemplate.put(baseUrl + "/citizens/" + id, citizen);
        return getById(id);
    }

    public void delete(Long id) {
        restTemplate.delete(baseUrl + "/citizens/" + id);
    }
}
